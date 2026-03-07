/**
 * @file    task_modbus_master.c
 * @author  Yukikaze
 * @brief   Modbus 主站轮询任务实现
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - 本任务固定轮询 3 个 F103 从站，并把整轮快照压入 uplink 队列。
 * - 总线上始终只存在一个未完成事务，避免并发请求导致 RTU 时序错误。
 */

#include "task_modbus_master.h"

#include "app_data.h"
#include "bsp_rs485.h"
#include "modbus_master.h"
#include "modbus_trace.h"
#include "modbus_timebase.h"
#include "task_uplink.h"

#include <stdio.h>
#include <string.h>

#define MODBUS_SLAVE1_ADDR 1U
#define MODBUS_SLAVE2_ADDR 2U
#define MODBUS_SLAVE3_ADDR 3U

#define MODBUS_REG_LIGHT_ADC 0U
#define MODBUS_REG_TEMPERATURE 10U
#define MODBUS_REG_MQ2_PPM 20U

TaskHandle_t Task_ModbusMaster_Handle = NULL;

static AppDataError_TypeDef Task_ModbusMaster_MapError(ModbusMasterStatus_TypeDef status)
{
    switch (status)
    {
    case MODBUS_MASTER_STATUS_TIMEOUT:
        return APP_DATA_ERROR_TIMEOUT;

    case MODBUS_MASTER_STATUS_CRC_ERROR:
        return APP_DATA_ERROR_CRC;

    case MODBUS_MASTER_STATUS_EXCEPTION:
        return APP_DATA_ERROR_EXCEPTION;

    case MODBUS_MASTER_STATUS_PORT_ERROR:
        return APP_DATA_ERROR_PORT;

    default:
        return APP_DATA_ERROR_PROTOCOL;
    }
}

static void Task_ModbusMaster_EnqueueSnapshot(uint32_t cycle_id)
{
    AppDataSnapshot_TypeDef snapshot;
    char payload[UPLINK_MAX_PAYLOAD_LEN];
    int written;

    AppData_GetSnapshot(&snapshot);

    written = snprintf(payload,
                       sizeof(payload),
                       "{\"cycleId\":%lu,"
                       "\"slave1\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"lightAdc\":%u},"
                       "\"slave2\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"temperature\":%u,\"humidity\":%u},"
                       "\"slave3\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"mq2Ppm\":%u}}",
                       (unsigned long)cycle_id,
                       (unsigned)snapshot.slave1.online,
                       (unsigned)snapshot.slave1.valid,
                       AppData_ErrorToString(snapshot.slave1.last_error),
                       (unsigned long)snapshot.slave1.last_update_ms,
                       (unsigned)snapshot.slave1.light_adc,
                       (unsigned)snapshot.slave2.online,
                       (unsigned)snapshot.slave2.valid,
                       AppData_ErrorToString(snapshot.slave2.last_error),
                       (unsigned long)snapshot.slave2.last_update_ms,
                       (unsigned)snapshot.slave2.temperature,
                       (unsigned)snapshot.slave2.humidity,
                       (unsigned)snapshot.slave3.online,
                       (unsigned)snapshot.slave3.valid,
                       AppData_ErrorToString(snapshot.slave3.last_error),
                       (unsigned long)snapshot.slave3.last_update_ms,
                       (unsigned)snapshot.slave3.mq2_ppm);

    if ((written <= 0) || ((size_t)written >= sizeof(payload)))
    {
        return;
    }

    (void)uplink_enqueue_latest_json(&g_uplink, "MODBUS_SNAPSHOT", payload);
}

static void Task_ModbusMaster_PollSlave1(void)
{
    uint16_t value = 0U;
    uint8_t exception_code = 0U;
    ModbusMasterStatus_TypeDef status;

    status = ModbusMaster_ReadHoldingRegisters(MODBUS_SLAVE1_ADDR,
                                               MODBUS_REG_LIGHT_ADC,
                                               1U,
                                               &value,
                                               &exception_code);
    if (status == MODBUS_MASTER_STATUS_OK)
    {
        AppData_UpdateSlave1(value, ModbusTimebase_GetMs());
        ModbusTrace_Value1(MODBUS_SLAVE1_ADDR, "lightAdc", value);
    }
    else
    {
        (void)exception_code;
        AppData_SetSlaveError(MODBUS_SLAVE1_ADDR, Task_ModbusMaster_MapError(status));
    }
}

static void Task_ModbusMaster_PollSlave2(void)
{
    uint16_t values[2] = {0U, 0U};
    uint8_t exception_code = 0U;
    ModbusMasterStatus_TypeDef status;

    status = ModbusMaster_ReadHoldingRegisters(MODBUS_SLAVE2_ADDR,
                                               MODBUS_REG_TEMPERATURE,
                                               2U,
                                               values,
                                               &exception_code);
    if (status == MODBUS_MASTER_STATUS_OK)
    {
        AppData_UpdateSlave2(values[0], values[1], ModbusTimebase_GetMs());
        ModbusTrace_Value2(MODBUS_SLAVE2_ADDR, "temperature", values[0], "humidity", values[1]);
    }
    else
    {
        (void)exception_code;
        AppData_SetSlaveError(MODBUS_SLAVE2_ADDR, Task_ModbusMaster_MapError(status));
    }
}

static void Task_ModbusMaster_PollSlave3(void)
{
    uint16_t value = 0U;
    uint8_t exception_code = 0U;
    ModbusMasterStatus_TypeDef status;

    status = ModbusMaster_ReadHoldingRegisters(MODBUS_SLAVE3_ADDR,
                                               MODBUS_REG_MQ2_PPM,
                                               1U,
                                               &value,
                                               &exception_code);
    if (status == MODBUS_MASTER_STATUS_OK)
    {
        AppData_UpdateSlave3(value, ModbusTimebase_GetMs());
        ModbusTrace_Value1(MODBUS_SLAVE3_ADDR, "mq2Ppm", value);
    }
    else
    {
        (void)exception_code;
        AppData_SetSlaveError(MODBUS_SLAVE3_ADDR, Task_ModbusMaster_MapError(status));
    }
}

BaseType_t Task_ModbusMaster_Init(void)
{
    ModbusMasterConfig_TypeDef config;

    if (BspRs485_Init() != pdPASS)
    {
        return pdFAIL;
    }

    config.response_timeout_ms = TASK_MODBUS_MASTER_TIMEOUT_MS;
    config.retry_count = TASK_MODBUS_MASTER_RETRY_COUNT;
    config.inter_request_gap_ms = TASK_MODBUS_MASTER_REQUEST_GAP_MS;

    if (ModbusMaster_Init(&config) != pdPASS)
    {
        return pdFAIL;
    }

    return pdPASS;
}

BaseType_t Task_ModbusMaster_Create(void)
{
    return xTaskCreate((TaskFunction_t)Task_ModbusMaster,
                       (const char *)TASK_MODBUS_MASTER_NAME,
                       (uint16_t)TASK_MODBUS_MASTER_STACK_SIZE,
                       (void *)NULL,
                       (UBaseType_t)TASK_MODBUS_MASTER_PRIORITY,
                       (TaskHandle_t *)&Task_ModbusMaster_Handle);
}

void Task_ModbusMaster(void *pvParameters)
{
    TickType_t xLastWakeTime;
    uint32_t cycle_id = 0U;

    (void)pvParameters;

    ModbusMaster_BindTask(Task_ModbusMaster_Handle);
    xLastWakeTime = xTaskGetTickCount();

    for (;;)
    {
        cycle_id++;
        ModbusTrace_CycleBegin(cycle_id);

        Task_ModbusMaster_PollSlave1();
        ModbusTimebase_SleepMs(TASK_MODBUS_MASTER_REQUEST_GAP_MS);

        Task_ModbusMaster_PollSlave2();
        ModbusTimebase_SleepMs(TASK_MODBUS_MASTER_REQUEST_GAP_MS);

        Task_ModbusMaster_PollSlave3();

        Task_ModbusMaster_EnqueueSnapshot(cycle_id);
        ModbusTrace_CycleEnd(cycle_id);
        vTaskDelayUntil(&xLastWakeTime, pdMS_TO_TICKS(TASK_MODBUS_MASTER_PERIOD_MS));
    }
}
