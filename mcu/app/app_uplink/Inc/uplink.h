/**
 * @file    uplink.h
 * @author  Yukikaze
 * @brief   Uplink 对外 API
 * @version 0.2
 * @date    2026-03-07
 */

#ifndef __UPLINK_H
#define __UPLINK_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "uplink_codec_json.h"
#include "uplink_config.h"
#include "uplink_platform.h"
#include "uplink_queue.h"
#include "uplink_retry.h"
#include "uplink_transport_http_netconn.h"

#include "err.h"
#include "sys.h"

typedef struct
{
    uint8_t inited;
    uint8_t sending;

    sys_mutex_t mutex;

    uplink_config_t cfg;
    uplink_platform_t platform;
    uplink_queue_t queue;

    uplink_transport_t transport;
    uplink_transport_http_netconn_ctx_t http_ctx;

    uint32_t next_message_id;
    uint32_t sending_message_id;

    char event_json[UPLINK_MAX_EVENT_JSON_LEN];
    char response_body[UPLINK_MAX_HTTP_BODY_LEN];
} uplink_t;

uplink_err_t uplink_init(uplink_t *u, const uplink_config_t *cfg, const uplink_platform_t *platform);
uplink_err_t uplink_enqueue_json(uplink_t *u, const char *type, const char *payload_json);
uplink_err_t uplink_enqueue_latest_json(uplink_t *u, const char *type, const char *payload_json);
void uplink_poll(uplink_t *u);
uint16_t uplink_get_queue_depth(uplink_t *u);

#ifdef __cplusplus
}
#endif

#endif /* __UPLINK_H */
