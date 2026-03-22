/**
 * @file    task_modbus_master.c
 * @author  Yukikaze
 * @brief   Modbus 主站轮询任务实现
 * @version 0.2
 * @date    2026-03-17
 *
 * @note
 * - 本任务固定轮询 3 个 F103 从站和 1 个 PLC 从站。
 * - PLC 控制命令来自 uplink HTTP 响应中的 `pendingCommand`，由本任务串行写入 slave4。
 * - 总线上始终只存在一个未完成事务，避免并发请求导致 RTU 时序错误。
 */

#include "task_modbus_master.h"

#include "app_control.h"
#include "app_data.h"
#include "bsp_rs485.h"
#include "modbus_master.h"
#include "modbus_timebase.h"
#include "modbus_trace.h"
#include "task_uplink.h"

#include <stdio.h>
#include <string.h>

#define MODBUS_SLAVE1_ADDR 1U
#define MODBUS_SLAVE2_ADDR 2U
#define MODBUS_SLAVE3_ADDR 3U
#define MODBUS_SLAVE4_ADDR 4U

#define MODBUS_REG_LIGHT_ADC 0U
#define MODBUS_REG_TEMPERATURE 10U
#define MODBUS_REG_MQ2_PPM 20U
#define MODBUS_REG_PLC_STATUS 30U
#define MODBUS_REG_PLC_COMMAND 100U

#define MODBUS_PLC_STATUS_QTY 8U
#define MODBUS_PLC_COMMAND_QTY 8U
#define MODBUS_PLC_COMMAND_CONTROL_WORD 0xA55AU

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

    written = snprintf(
        payload,
        sizeof(payload),
        "{\"cycleId\":%lu,"
        "\"slave1\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"lightAdc\":%u},"
        "\"slave2\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"temperature\":%u,\"humidity\":%u},"
        "\"slave3\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"mq2Ppm\":%u},"
        "\"slave4\":{\"online\":%u,\"valid\":%u,\"lastError\":\"%s\",\"lastUpdateMs\":%lu,\"homed\":%u,\"busy\":%u,\"pumpOn\":%u,"
        "\"statusWord\":%u,\"faultWord\":%u,\"pumpState\":%u,\"stepperState\":\"%s\",\"positionPulse\":%ld,"
        "\"lastCommandSeq\":%u,\"lastCommandResult\":\"%s\",\"lastCommandResultCode\":%u}}",
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
        (unsigned)snapshot.slave3.mq2_ppm,
        (unsigned)snapshot.slave4.online,
        (unsigned)snapshot.slave4.valid,
        AppData_ErrorToString(snapshot.slave4.last_error),
        (unsigned long)snapshot.slave4.last_update_ms,
        (unsigned)snapshot.slave4.homed,
        (unsigned)snapshot.slave4.busy,
        (unsigned)snapshot.slave4.pump_on,
        (unsigned)snapshot.slave4.status_word,
        (unsigned)snapshot.slave4.fault_word,
        (unsigned)snapshot.slave4.pump_state,
        AppControl_StepperStateToString(snapshot.slave4.stepper_state),
        (long)snapshot.slave4.position_pulse,
        (unsigned)snapshot.slave4.last_command_seq,
        AppControl_ResultCodeToString(snapshot.slave4.last_command_result_code),
        (unsigned)snapshot.slave4.last_command_result_code);

    if ((written <= 0) || ((size_t)written >= sizeof(payload)))
    {
        return;
    }

    (void)uplink_enqueue_latest_json(&g_uplink, "MODBUS_SNAPSHOT", payload);
}

static uint8_t Task_ModbusMaster_TryDispatchPlcCommand(void)
{
    AppControlCommand_TypeDef command;
    uint16_t regs[MODBUS_PLC_COMMAND_QTY];
    uint8_t exception_code = 0U;

    if (AppControl_PeekPendingCommand(&command) == 0U)
    {
        return 0U;
    }

    regs[0] = command.seq;
    regs[1] = command.code;
    regs[2] = (uint16_t)(((uint32_t)command.arg1 >> 16U) & 0xFFFFU);
    regs[3] = (uint16_t)((uint32_t)command.arg1 & 0xFFFFU);
    regs[4] = (uint16_t)(((uint32_t)command.arg2 >> 16U) & 0xFFFFU);
    regs[5] = (uint16_t)((uint32_t)command.arg2 & 0xFFFFU);
    regs[6] = command.arg3;
    regs[7] = MODBUS_PLC_COMMAND_CONTROL_WORD;

    if (ModbusMaster_WriteMultipleRegisters(MODBUS_SLAVE4_ADDR,
                                            MODBUS_REG_PLC_COMMAND,
                                            MODBUS_PLC_COMMAND_QTY,
                                            regs,
                                            &exception_code) == MODBUS_MASTER_STATUS_OK)
    {
        AppControl_MarkCommandCommitted(command.seq);
    }
    else
    {
        (void)exception_code;
    }

    return 1U;
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

static void Task_ModbusMaster_PollSlave4(void)
{
    uint16_t values[MODBUS_PLC_STATUS_QTY] = {0U};
    uint8_t exception_code = 0U;
    int32_t position_pulse;
    ModbusMasterStatus_TypeDef status;

    status = ModbusMaster_ReadHoldingRegisters(MODBUS_SLAVE4_ADDR,
                                               MODBUS_REG_PLC_STATUS,
                                               MODBUS_PLC_STATUS_QTY,
                                               values,
                                               &exception_code);
    if (status == MODBUS_MASTER_STATUS_OK)
    {
        position_pulse = (int32_t)(((uint32_t)values[6] << 16U) | (uint32_t)values[7]);
        AppData_UpdateSlave4(values[0],
                             values[1],
                             values[2],
                             values[3],
                             values[4],
                             values[5],
                             position_pulse,
                             ModbusTimebase_GetMs());
    }
    else
    {
        (void)exception_code;
        AppData_SetSlaveError(MODBUS_SLAVE4_ADDR, Task_ModbusMaster_MapError(status));
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

        if (Task_ModbusMaster_TryDispatchPlcCommand() != 0U)
        {
            ModbusTimebase_SleepMs(TASK_MODBUS_MASTER_REQUEST_GAP_MS);
        }

        Task_ModbusMaster_PollSlave4();
        ModbusTimebase_SleepMs(TASK_MODBUS_MASTER_REQUEST_GAP_MS);

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
