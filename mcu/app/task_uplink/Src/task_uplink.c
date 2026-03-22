/**
 * @file    task_uplink.c
 * @author  Yukikaze
 * @brief   异步上报调度任务实现（周期驱动 uplink_poll）
 * @version 0.3
 * @date    2026-03-07
 *
 * @note
 * - 本任务不采集业务数据，只负责发送 uplink 队列中的消息。
 * - Modbus 轮询任务通过 `uplink_enqueue_latest_json()` 投递最新快照。
 */

#include "task_uplink.h"

#include "app_control.h"

#include <string.h>

uplink_t g_uplink;
TaskHandle_t Task_Uplink_Handle = NULL;

static void Task_Uplink_Log(void *user_ctx, uplink_log_level_t level, const char *message)
{
    (void)user_ctx;
    (void)level;
    (void)message;
}

static void Task_Uplink_OnHttpResponse(void *user_ctx,
                                       const char *body,
                                       size_t body_len,
                                       uint16_t http_status)
{
    (void)user_ctx;
    AppControl_HandleUplinkResponse(body, body_len, http_status);
}

static void Task_Uplink_SetStr(char *dst, size_t dst_size, const char *src)
{
    if ((dst == NULL) || (dst_size == 0U))
    {
        return;
    }

    if (src == NULL)
    {
        dst[0] = '\0';
        return;
    }

    (void)strncpy(dst, src, dst_size - 1U);
    dst[dst_size - 1U] = '\0';
}

BaseType_t Task_Uplink_Init(void)
{
    uplink_config_t cfg;
    uplink_platform_t platform;
    uplink_err_t err;

    uplink_config_set_defaults(&cfg);

    Task_Uplink_SetStr(cfg.endpoint.host, sizeof(cfg.endpoint.host), TASK_UPLINK_SERVER_HOST);
    cfg.endpoint.port = (uint16_t)TASK_UPLINK_SERVER_PORT;
    Task_Uplink_SetStr(cfg.endpoint.path, sizeof(cfg.endpoint.path), TASK_UPLINK_SERVER_PATH);

    (void)memset(&platform, 0, sizeof(platform));
    platform.user_ctx = NULL;
    platform.log = Task_Uplink_Log;
    platform.on_http_response = Task_Uplink_OnHttpResponse;

    err = uplink_init(&g_uplink, &cfg, &platform);
    if (err != UPLINK_OK)
    {
        return pdFAIL;
    }

    return pdPASS;
}

BaseType_t Task_Uplink_Create(void)
{
    return xTaskCreate((TaskFunction_t)Task_Uplink,
                       (const char *)TASK_UPLINK_NAME,
                       (uint16_t)TASK_UPLINK_STACK_SIZE,
                       (void *)NULL,
                       (UBaseType_t)TASK_UPLINK_PRIORITY,
                       (TaskHandle_t *)&Task_Uplink_Handle);
}

void Task_Uplink(void *pvParameters)
{
    TickType_t xLastWakeTime;
    const TickType_t xPeriod = pdMS_TO_TICKS(TASK_UPLINK_PERIOD_MS);

    (void)pvParameters;

    xLastWakeTime = xTaskGetTickCount();

    for (;;)
    {
        uplink_poll(&g_uplink);
        vTaskDelayUntil(&xLastWakeTime, xPeriod);
    }
}
