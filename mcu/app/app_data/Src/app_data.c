/**
 * @file    app_data.c
 * @author  Yukikaze
 * @brief   采集快照共享数据模块实现
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - 本模块保存 3 个 Modbus 从站的最近一次采集结果。
 * - `online` 表示最近一轮采集是否成功；`valid` 表示是否至少收到过一次有效数据。
 */

#include "app_data.h"

#include "semphr.h"

#include <string.h>

static SemaphoreHandle_t g_xDataMutex = NULL;
static AppDataSnapshot_TypeDef g_snapshot;

static void AppData_ResetSnapshot(void)
{
    (void)memset(&g_snapshot, 0, sizeof(g_snapshot));
    g_snapshot.slave1.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave2.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave3.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave4.last_error = APP_DATA_ERROR_NONE;
}

BaseType_t AppData_Init(void)
{
    g_xDataMutex = xSemaphoreCreateMutex();
    if (g_xDataMutex == NULL)
    {
        return pdFAIL;
    }

    AppData_ResetSnapshot();
    return pdPASS;
}

void AppData_UpdateSlave1(uint16_t light_adc, uint32_t now_ms)
{
    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    g_snapshot.slave1.online = 1U;
    g_snapshot.slave1.valid = 1U;
    g_snapshot.slave1.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave1.last_update_ms = now_ms;
    g_snapshot.slave1.light_adc = light_adc;

    xSemaphoreGive(g_xDataMutex);
}

void AppData_UpdateSlave2(uint16_t temperature, uint16_t humidity, uint32_t now_ms)
{
    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    g_snapshot.slave2.online = 1U;
    g_snapshot.slave2.valid = 1U;
    g_snapshot.slave2.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave2.last_update_ms = now_ms;
    g_snapshot.slave2.temperature = temperature;
    g_snapshot.slave2.humidity = humidity;

    xSemaphoreGive(g_xDataMutex);
}

void AppData_UpdateSlave3(uint16_t mq2_ppm, uint32_t now_ms)
{
    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    g_snapshot.slave3.online = 1U;
    g_snapshot.slave3.valid = 1U;
    g_snapshot.slave3.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave3.last_update_ms = now_ms;
    g_snapshot.slave3.mq2_ppm = mq2_ppm;

    xSemaphoreGive(g_xDataMutex);
}

void AppData_UpdateSlave4(uint16_t status_word,
                          uint16_t fault_word,
                          uint16_t last_command_seq,
                          uint16_t last_command_result_code,
                          uint16_t pump_state,
                          uint16_t stepper_state,
                          int32_t position_pulse,
                          uint32_t now_ms)
{
    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    g_snapshot.slave4.online = 1U;
    g_snapshot.slave4.valid = 1U;
    g_snapshot.slave4.last_error = APP_DATA_ERROR_NONE;
    g_snapshot.slave4.last_update_ms = now_ms;
    g_snapshot.slave4.status_word = status_word;
    g_snapshot.slave4.fault_word = fault_word;
    g_snapshot.slave4.last_command_seq = last_command_seq;
    g_snapshot.slave4.last_command_result_code = last_command_result_code;
    g_snapshot.slave4.pump_state = pump_state;
    g_snapshot.slave4.stepper_state = stepper_state;
    g_snapshot.slave4.position_pulse = position_pulse;
    g_snapshot.slave4.homed = ((status_word & (1U << 0)) != 0U) ? 1U : 0U;
    g_snapshot.slave4.busy = ((status_word & (1U << 1)) != 0U) ? 1U : 0U;
    g_snapshot.slave4.pump_on = ((status_word & (1U << 2)) != 0U) ? 1U : 0U;

    xSemaphoreGive(g_xDataMutex);
}

void AppData_SetSlaveError(uint8_t slave_addr, AppDataError_TypeDef error_code)
{
    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    switch (slave_addr)
    {
    case 1U:
        g_snapshot.slave1.online = 0U;
        g_snapshot.slave1.last_error = error_code;
        break;

    case 2U:
        g_snapshot.slave2.online = 0U;
        g_snapshot.slave2.last_error = error_code;
        break;

    case 3U:
        g_snapshot.slave3.online = 0U;
        g_snapshot.slave3.last_error = error_code;
        break;

    case 4U:
        g_snapshot.slave4.online = 0U;
        g_snapshot.slave4.last_error = error_code;
        break;

    default:
        break;
    }

    xSemaphoreGive(g_xDataMutex);
}

void AppData_GetSnapshot(AppDataSnapshot_TypeDef *pSnapshot)
{
    if (pSnapshot == NULL)
    {
        return;
    }

    (void)memset(pSnapshot, 0, sizeof(*pSnapshot));

    if (xSemaphoreTake(g_xDataMutex, pdMS_TO_TICKS(100U)) != pdTRUE)
    {
        return;
    }

    *pSnapshot = g_snapshot;
    xSemaphoreGive(g_xDataMutex);
}

const char *AppData_ErrorToString(AppDataError_TypeDef error_code)
{
    switch (error_code)
    {
    case APP_DATA_ERROR_NONE:
        return "NONE";
    case APP_DATA_ERROR_TIMEOUT:
        return "TIMEOUT";
    case APP_DATA_ERROR_CRC:
        return "CRC";
    case APP_DATA_ERROR_PROTOCOL:
        return "PROTOCOL";
    case APP_DATA_ERROR_EXCEPTION:
        return "EXCEPTION";
    case APP_DATA_ERROR_PORT:
        return "PORT";
    default:
        return "UNKNOWN";
    }
}
