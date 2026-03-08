/**
 * @file    uplink.c
 * @author  Yukikaze
 * @brief   Uplink 核心实现（队列管理 + HTTP 发送状态机）
 * @version 0.2
 * @date    2026-03-07
 */

#include "uplink.h"

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

static uint32_t uplink_default_now_ms(void *user_ctx)
{
    (void)user_ctx;
    return (uint32_t)sys_now();
}

static uint32_t uplink_default_rand_u32(void *user_ctx)
{
    static uint32_t s_state = 0U;
    (void)user_ctx;

    if (s_state == 0U)
    {
        s_state = (uint32_t)sys_now() ^ 0xA5A5A5A5U;
    }

    s_state ^= (s_state << 13);
    s_state ^= (s_state >> 17);
    s_state ^= (s_state << 5);
    return s_state;
}

static void uplink_logf(uplink_t *u, uplink_log_level_t level, const char *fmt, ...)
{
    char buf[200];
    va_list args;

    if ((u == NULL) || (u->platform.log == NULL))
    {
        return;
    }

    va_start(args, fmt);
    (void)vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);

    u->platform.log(u->platform.user_ctx, level, buf);
}

static uint8_t uplink_copy_str_checked(char *dst, size_t dst_size, const char *src)
{
    size_t src_len;

    if ((dst == NULL) || (dst_size == 0U))
    {
        return 1U;
    }

    if (src == NULL)
    {
        dst[0] = '\0';
        return 0U;
    }

    src_len = strlen(src);
    (void)strncpy(dst, src, dst_size - 1U);
    dst[dst_size - 1U] = '\0';
    return (src_len >= dst_size) ? 1U : 0U;
}

static uint8_t uplink_time_is_due(uint32_t now, uint32_t due)
{
    return ((int32_t)(now - due) >= 0) ? 1U : 0U;
}

static uint16_t uplink_queue_next_index(const uplink_queue_t *q, uint16_t index)
{
    index++;
    if (index >= q->capacity)
    {
        index = 0U;
    }
    return index;
}

static uplink_err_t uplink_build_msg(uplink_t *u,
                                     const char *type,
                                     const char *payload_json,
                                     uplink_msg_t *out_msg)
{
    uint32_t now_ms;

    if ((u == NULL) || (type == NULL) || (out_msg == NULL))
    {
        return UPLINK_ERR_INVALID_ARG;
    }

    now_ms = u->platform.now_ms(u->platform.user_ctx);

    (void)memset(out_msg, 0, sizeof(*out_msg));
    out_msg->created_ms = now_ms;
    out_msg->attempt = 0U;
    out_msg->next_retry_ms = now_ms;

    if (uplink_copy_str_checked(out_msg->type, sizeof(out_msg->type), type) != 0U)
    {
        return UPLINK_ERR_BUFFER_TOO_SMALL;
    }

    if (uplink_copy_str_checked(out_msg->payload_json, sizeof(out_msg->payload_json), payload_json) != 0U)
    {
        return UPLINK_ERR_BUFFER_TOO_SMALL;
    }

    return UPLINK_OK;
}

static uplink_msg_t *uplink_find_replace_slot(uplink_t *u, const char *type)
{
    uint16_t index;
    uint16_t i;

    if ((u == NULL) || (type == NULL) || (u->queue.count == 0U))
    {
        return NULL;
    }

    index = u->queue.head;
    for (i = 0U; i < u->queue.count; ++i)
    {
        uplink_msg_t *item = &u->queue.items[index];
        if ((strcmp(item->type, type) == 0) &&
            (item->message_id != u->sending_message_id))
        {
            return item;
        }
        index = uplink_queue_next_index(&u->queue, index);
    }

    return NULL;
}

static uplink_err_t uplink_enqueue_internal(uplink_t *u,
                                            const char *type,
                                            const char *payload_json,
                                            uint8_t replace_existing)
{
    uplink_err_t r;
    uplink_msg_t msg;

    if ((u == NULL) || (type == NULL))
    {
        return UPLINK_ERR_INVALID_ARG;
    }

    if (u->inited == 0U)
    {
        return UPLINK_ERR_NOT_INIT;
    }

    r = uplink_build_msg(u, type, payload_json, &msg);
    if (r != UPLINK_OK)
    {
        return r;
    }

    sys_mutex_lock(&u->mutex);

    msg.message_id = u->next_message_id++;

    if (replace_existing != 0U)
    {
        uplink_msg_t *slot = uplink_find_replace_slot(u, type);
        if (slot != NULL)
        {
            *slot = msg;
            sys_mutex_unlock(&u->mutex);
            return UPLINK_OK;
        }
    }

    r = uplink_queue_push(&u->queue, &msg);
    sys_mutex_unlock(&u->mutex);

    return r;
}

uplink_err_t uplink_init(uplink_t *u, const uplink_config_t *cfg, const uplink_platform_t *platform)
{
    uplink_config_t local_cfg;

    if (u == NULL)
    {
        return UPLINK_ERR_INVALID_ARG;
    }

    (void)memset(u, 0, sizeof(*u));

    if (cfg == NULL)
    {
        uplink_config_set_defaults(&local_cfg);
        cfg = &local_cfg;
    }

    {
        uplink_err_t vr = uplink_config_validate(cfg);
        if (vr != UPLINK_OK)
        {
            return vr;
        }
    }

    u->cfg = *cfg;

    if (platform != NULL)
    {
        u->platform = *platform;
    }
    else
    {
        (void)memset(&u->platform, 0, sizeof(u->platform));
    }

    if (u->platform.now_ms == NULL)
    {
        u->platform.now_ms = uplink_default_now_ms;
    }

    if (u->platform.rand_u32 == NULL)
    {
        u->platform.rand_u32 = uplink_default_rand_u32;
    }

    if (sys_mutex_new(&u->mutex) != ERR_OK)
    {
        return UPLINK_ERR_INTERNAL;
    }

    uplink_queue_init(&u->queue, u->cfg.queue_len);
    u->next_message_id = 1U;
    u->sending_message_id = 0U;

    if (u->cfg.endpoint.scheme == UPLINK_SCHEME_HTTP)
    {
        uplink_transport_http_netconn_bind(&u->transport, &u->http_ctx);
    }
    else
    {
        return UPLINK_ERR_UNSUPPORTED;
    }

    u->inited = 1U;
    return UPLINK_OK;
}

uplink_err_t uplink_enqueue_json(uplink_t *u, const char *type, const char *payload_json)
{
    return uplink_enqueue_internal(u, type, payload_json, 0U);
}

uplink_err_t uplink_enqueue_latest_json(uplink_t *u, const char *type, const char *payload_json)
{
    return uplink_enqueue_internal(u, type, payload_json, 1U);
}

void uplink_poll(uplink_t *u)
{
    uplink_msg_t *head = NULL;
    uplink_msg_t msg_copy;
    uplink_ack_t ack;
    uplink_err_t tr;
    uint32_t now_ms;
    uint16_t next_attempt;
    size_t body_len = 0U;
    size_t event_len = 0U;

    if ((u == NULL) || (u->inited == 0U))
    {
        return;
    }

    now_ms = u->platform.now_ms(u->platform.user_ctx);

    sys_mutex_lock(&u->mutex);

    if (u->sending != 0U)
    {
        sys_mutex_unlock(&u->mutex);
        return;
    }

    if ((uplink_queue_peek(&u->queue, &head) != UPLINK_OK) || (head == NULL))
    {
        sys_mutex_unlock(&u->mutex);
        return;
    }

    if (uplink_time_is_due(now_ms, head->next_retry_ms) == 0U)
    {
        sys_mutex_unlock(&u->mutex);
        return;
    }

    next_attempt = (uint16_t)(head->attempt + 1U);
    if (uplink_retry_is_attempt_allowed(&u->cfg.retry, next_attempt) == 0U)
    {
        (void)uplink_queue_pop(&u->queue);
        sys_mutex_unlock(&u->mutex);
        return;
    }

    head->attempt = next_attempt;
    msg_copy = *head;
    u->sending = 1U;
    u->sending_message_id = msg_copy.message_id;

    sys_mutex_unlock(&u->mutex);

    if (uplink_codec_json_build_event(u->event_json,
                                      sizeof(u->event_json),
                                      u->cfg.device_id,
                                      msg_copy.message_id,
                                      msg_copy.created_ms,
                                      msg_copy.type,
                                      msg_copy.payload_json,
                                      &event_len) != UPLINK_OK)
    {
        sys_mutex_lock(&u->mutex);
        u->sending = 0U;
        u->sending_message_id = 0U;
        if ((uplink_queue_peek(&u->queue, &head) == UPLINK_OK) && (head != NULL) &&
            (head->message_id == msg_copy.message_id))
        {
            uint32_t delay = uplink_retry_calc_delay_ms(&u->cfg.retry,
                                                        msg_copy.attempt,
                                                        u->platform.rand_u32(u->platform.user_ctx));
            head->next_retry_ms = u->platform.now_ms(u->platform.user_ctx) + delay;
        }
        sys_mutex_unlock(&u->mutex);
        return;
    }

    (void)memset(&ack, 0, sizeof(ack));
    ack.app_code = UPLINK_APP_CODE_UNKNOWN;
    (void)memset(u->response_body, 0, sizeof(u->response_body));

    tr = u->transport.post_json(u->transport.ctx,
                                &u->cfg.endpoint,
                                &u->platform,
                                u->event_json,
                                event_len,
                                u->cfg.send_timeout_ms,
                                u->cfg.recv_timeout_ms,
                                &ack,
                                u->response_body,
                                sizeof(u->response_body),
                                &body_len);

    if (tr != UPLINK_OK)
    {
        ack.http_status = 0U;
    }

    {
        int32_t code = UPLINK_APP_CODE_UNKNOWN;
        (void)uplink_codec_json_parse_app_code(u->response_body, body_len, &code);
        ack.app_code = code;
    }

    {
        uint8_t http_ok = ((ack.http_status >= 200U) && (ack.http_status < 300U)) ? 1U : 0U;
        uint8_t app_ok = ((ack.app_code == 0) || (ack.app_code == UPLINK_APP_CODE_UNKNOWN)) ? 1U : 0U;
        uint8_t success = ((http_ok != 0U) && (app_ok != 0U)) ? 1U : 0U;

        sys_mutex_lock(&u->mutex);
        u->sending = 0U;
        u->sending_message_id = 0U;

        if ((uplink_queue_peek(&u->queue, &head) == UPLINK_OK) && (head != NULL) &&
            (head->message_id == msg_copy.message_id))
        {
            if (success != 0U)
            {
                (void)uplink_queue_pop(&u->queue);
            }
            else
            {
                uint32_t delay = uplink_retry_calc_delay_ms(&u->cfg.retry,
                                                            msg_copy.attempt,
                                                            u->platform.rand_u32(u->platform.user_ctx));
                head->next_retry_ms = u->platform.now_ms(u->platform.user_ctx) + delay;

                uplink_logf(u,
                            UPLINK_LOG_WARN,
                            "[uplink] send failed: http=%u code=%ld attempt=%u next_delay=%lu ms\r\n",
                            (unsigned)ack.http_status,
                            (long)ack.app_code,
                            (unsigned)msg_copy.attempt,
                            (unsigned long)delay);
            }
        }

        sys_mutex_unlock(&u->mutex);
    }
}

uint16_t uplink_get_queue_depth(uplink_t *u)
{
    uint16_t depth = 0U;

    if ((u == NULL) || (u->inited == 0U))
    {
        return 0U;
    }

    sys_mutex_lock(&u->mutex);
    depth = uplink_queue_size(&u->queue);
    sys_mutex_unlock(&u->mutex);

    return depth;
}
