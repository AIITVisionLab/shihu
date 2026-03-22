/**
 * @file    app_control.c
 * @author  Yukikaze
 * @brief   云控命令共享状态模块实现
 * @version 0.1
 * @date    2026-03-17
 */

#include "app_control.h"

#include "semphr.h"

#include <ctype.h>
#include <limits.h>
#include <string.h>

typedef struct
{
    uint8_t pending_valid;
    uint16_t last_committed_seq;
    AppControlCommand_TypeDef pending_command;
} AppControlState_TypeDef;

static SemaphoreHandle_t g_app_control_mutex = NULL;
static AppControlState_TypeDef g_app_control_state;

static const char *AppControl_FindKey(const char *text, size_t text_len, const char *key)
{
    size_t i;
    size_t key_len;

    if ((text == NULL) || (key == NULL))
    {
        return NULL;
    }

    key_len = strlen(key);
    if ((key_len == 0U) || (text_len < key_len))
    {
        return NULL;
    }

    for (i = 0U; i + key_len <= text_len; ++i)
    {
        if (memcmp(&text[i], key, key_len) == 0)
        {
            return &text[i];
        }
    }

    return NULL;
}

static uint8_t AppControl_ParseInt32Field(const char *text,
                                          size_t text_len,
                                          const char *quoted_key,
                                          int32_t *out_value)
{
    const char *key_pos;
    const char *cursor;
    const char *limit;
    int sign = 1;
    int64_t value = 0;
    uint8_t has_digit = 0U;

    if ((text == NULL) || (quoted_key == NULL) || (out_value == NULL))
    {
        return 0U;
    }

    key_pos = AppControl_FindKey(text, text_len, quoted_key);
    if (key_pos == NULL)
    {
        return 0U;
    }

    cursor = key_pos + strlen(quoted_key);
    limit = text + text_len;

    while ((cursor < limit) && isspace((unsigned char)*cursor))
    {
        cursor++;
    }

    if ((cursor >= limit) || (*cursor != ':'))
    {
        return 0U;
    }

    cursor++;
    while ((cursor < limit) && isspace((unsigned char)*cursor))
    {
        cursor++;
    }

    if (cursor >= limit)
    {
        return 0U;
    }

    if (*cursor == '-')
    {
        sign = -1;
        cursor++;
    }

    while ((cursor < limit) && (*cursor >= '0') && (*cursor <= '9'))
    {
        has_digit = 1U;
        value = (value * 10) + (int64_t)(*cursor - '0');
        if (value > (int64_t)INT32_MAX)
        {
            value = INT32_MAX;
        }
        cursor++;
    }

    if (has_digit == 0U)
    {
        return 0U;
    }

    *out_value = (int32_t)((sign > 0) ? value : -value);
    return 1U;
}

static uint8_t AppControl_ParsePendingCommand(const char *body,
                                              size_t body_len,
                                              AppControlCommand_TypeDef *out_command)
{
    const char *key_pos;
    const char *cursor;
    const char *limit;
    const char *obj_begin = NULL;
    const char *obj_end = NULL;
    int32_t value = 0;
    int depth = 0;

    if ((body == NULL) || (out_command == NULL))
    {
        return 0U;
    }

    key_pos = AppControl_FindKey(body, body_len, "\"pendingCommand\"");
    if (key_pos == NULL)
    {
        return 0U;
    }

    cursor = key_pos + strlen("\"pendingCommand\"");
    limit = body + body_len;

    while ((cursor < limit) && isspace((unsigned char)*cursor))
    {
        cursor++;
    }

    if ((cursor >= limit) || (*cursor != ':'))
    {
        return 0U;
    }

    cursor++;
    while ((cursor < limit) && isspace((unsigned char)*cursor))
    {
        cursor++;
    }

    if ((cursor >= limit) || (*cursor != '{'))
    {
        return 0U;
    }

    obj_begin = cursor;

    while (cursor < limit)
    {
        if (*cursor == '{')
        {
            depth++;
        }
        else if (*cursor == '}')
        {
            depth--;
            if (depth == 0)
            {
                obj_end = cursor + 1;
                break;
            }
        }
        cursor++;
    }

    if ((obj_begin == NULL) || (obj_end == NULL) || (obj_end <= obj_begin))
    {
        return 0U;
    }

    (void)memset(out_command, 0, sizeof(*out_command));

    if (AppControl_ParseInt32Field(obj_begin, (size_t)(obj_end - obj_begin), "\"seq\"", &value) == 0U)
    {
        return 0U;
    }
    out_command->seq = (uint16_t)value;

    if (AppControl_ParseInt32Field(obj_begin, (size_t)(obj_end - obj_begin), "\"code\"", &value) == 0U)
    {
        return 0U;
    }
    out_command->code = (uint16_t)value;

    if (AppControl_ParseInt32Field(obj_begin, (size_t)(obj_end - obj_begin), "\"arg1\"", &value) != 0U)
    {
        out_command->arg1 = value;
    }

    if (AppControl_ParseInt32Field(obj_begin, (size_t)(obj_end - obj_begin), "\"arg2\"", &value) != 0U)
    {
        out_command->arg2 = value;
    }

    if (AppControl_ParseInt32Field(obj_begin, (size_t)(obj_end - obj_begin), "\"arg3\"", &value) != 0U)
    {
        out_command->arg3 = (uint16_t)value;
    }

    return (out_command->seq != 0U) ? 1U : 0U;
}

BaseType_t AppControl_Init(void)
{
    g_app_control_mutex = xSemaphoreCreateMutex();
    if (g_app_control_mutex == NULL)
    {
        return pdFAIL;
    }

    (void)memset(&g_app_control_state, 0, sizeof(g_app_control_state));
    return pdPASS;
}

void AppControl_HandleUplinkResponse(const char *body, size_t body_len, uint16_t http_status)
{
    AppControlCommand_TypeDef command;

    if ((http_status < 200U) || (http_status >= 300U))
    {
        return;
    }

    if (AppControl_ParsePendingCommand(body, body_len, &command) == 0U)
    {
        return;
    }

    if (xSemaphoreTake(g_app_control_mutex, pdMS_TO_TICKS(50U)) != pdTRUE)
    {
        return;
    }

    if (command.seq > g_app_control_state.last_committed_seq)
    {
        g_app_control_state.pending_command = command;
        g_app_control_state.pending_valid = 1U;
    }

    xSemaphoreGive(g_app_control_mutex);
}

uint8_t AppControl_PeekPendingCommand(AppControlCommand_TypeDef *out_command)
{
    uint8_t has_pending = 0U;

    if (out_command == NULL)
    {
        return 0U;
    }

    (void)memset(out_command, 0, sizeof(*out_command));

    if (xSemaphoreTake(g_app_control_mutex, pdMS_TO_TICKS(50U)) != pdTRUE)
    {
        return 0U;
    }

    if (g_app_control_state.pending_valid != 0U)
    {
        *out_command = g_app_control_state.pending_command;
        has_pending = 1U;
    }

    xSemaphoreGive(g_app_control_mutex);
    return has_pending;
}

void AppControl_MarkCommandCommitted(uint16_t seq)
{
    if (seq == 0U)
    {
        return;
    }

    if (xSemaphoreTake(g_app_control_mutex, pdMS_TO_TICKS(50U)) != pdTRUE)
    {
        return;
    }

    if (seq > g_app_control_state.last_committed_seq)
    {
        g_app_control_state.last_committed_seq = seq;
    }

    if ((g_app_control_state.pending_valid != 0U) &&
        (g_app_control_state.pending_command.seq == seq))
    {
        g_app_control_state.pending_valid = 0U;
        (void)memset(&g_app_control_state.pending_command, 0, sizeof(g_app_control_state.pending_command));
    }

    xSemaphoreGive(g_app_control_mutex);
}

const char *AppControl_ResultCodeToString(uint16_t result_code)
{
    switch (result_code)
    {
    case APP_CONTROL_RESULT_NONE:
        return "NONE";
    case APP_CONTROL_RESULT_ACCEPTED:
        return "ACCEPTED";
    case APP_CONTROL_RESULT_RUNNING:
        return "RUNNING";
    case APP_CONTROL_RESULT_DONE:
        return "DONE";
    case APP_CONTROL_RESULT_STOPPED:
        return "STOPPED";
    case APP_CONTROL_RESULT_NOT_HOMED:
        return "NOT_HOMED";
    case APP_CONTROL_RESULT_LIMIT_REJECT:
        return "LIMIT_REJECT";
    case APP_CONTROL_RESULT_PARAM_INVALID:
        return "PARAM_INVALID";
    case APP_CONTROL_RESULT_HOME_TIMEOUT:
        return "HOME_TIMEOUT";
    case APP_CONTROL_RESULT_BUSY_REJECT:
        return "BUSY_REJECT";
    default:
        return "UNKNOWN";
    }
}

const char *AppControl_StepperStateToString(uint16_t state_code)
{
    switch (state_code)
    {
    case APP_CONTROL_STEPPER_IDLE:
        return "IDLE";
    case APP_CONTROL_STEPPER_HOMING_CLEAR:
        return "HOMING_CLEAR";
    case APP_CONTROL_STEPPER_HOMING_SEARCH:
        return "HOMING_SEARCH";
    case APP_CONTROL_STEPPER_MOVING:
        return "MOVING";
    case APP_CONTROL_STEPPER_STOPPING:
        return "STOPPING";
    case APP_CONTROL_STEPPER_FAULT:
        return "FAULT";
    default:
        return "UNKNOWN";
    }
}
