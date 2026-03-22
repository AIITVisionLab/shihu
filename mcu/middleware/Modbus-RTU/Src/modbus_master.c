/**
 * @file    modbus_master.c
 * @author  Yukikaze
 * @brief   Modbus 主站事务接口实现
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - 一个事务对应一条请求和一条目标响应。
 * - 错误重试、超时等待和协议校验全部在任务上下文完成。
 */

#include <stddef.h>

#include "modbus_master.h"

#include "modbus_protocol.h"
#include "modbus_rtu_link.h"
#include "modbus_trace.h"
#include "modbus_timebase.h"

static uint8_t g_inited = 0U;
static TaskHandle_t g_task_handle = NULL;
static ModbusMasterConfig_TypeDef g_config;

static TickType_t ModbusMaster_GetRemainingTicks(TickType_t deadline)
{
    TickType_t now = xTaskGetTickCount();
    int32_t diff = (int32_t)(deadline - now);

    if (diff <= 0)
    {
        return 0U;
    }

    return (TickType_t)diff;
}

static ModbusMasterStatus_TypeDef ModbusMaster_MapLinkStatus(ModbusRtuLinkStatus_TypeDef status)
{
    switch (status)
    {
    case MODBUS_RTU_LINK_STATUS_CRC_ERROR:
        return MODBUS_MASTER_STATUS_CRC_ERROR;

    case MODBUS_RTU_LINK_STATUS_OVERFLOW:
    case MODBUS_RTU_LINK_STATUS_FRAME_ERROR:
        return MODBUS_MASTER_STATUS_PROTOCOL_ERROR;

    default:
        return MODBUS_MASTER_STATUS_PROTOCOL_ERROR;
    }
}

BaseType_t ModbusMaster_Init(const ModbusMasterConfig_TypeDef *config)
{
    if (config == NULL)
    {
        return pdFAIL;
    }

    if ((config->response_timeout_ms == 0U) || (config->inter_request_gap_ms == 0U))
    {
        return pdFAIL;
    }

    g_config = *config;

    if (ModbusRtuLink_Init() != pdPASS)
    {
        return pdFAIL;
    }

    g_task_handle = NULL;
    g_inited = 1U;
    return pdPASS;
}

void ModbusMaster_BindTask(TaskHandle_t task_handle)
{
    g_task_handle = task_handle;
    ModbusRtuLink_BindTask(task_handle);
}

ModbusMasterStatus_TypeDef ModbusMaster_ReadHoldingRegisters(uint8_t slave_addr,
                                                             uint16_t start_addr,
                                                             uint16_t quantity,
                                                             uint16_t *out_registers,
                                                             uint8_t *out_exception_code)
{
    uint8_t request_adu[6];
    uint8_t response_adu[MODBUS_RTU_LINK_MAX_ADU_LENGTH];
    uint16_t response_length = 0U;
    uint8_t attempt;
    ModbusMasterStatus_TypeDef last_status = MODBUS_MASTER_STATUS_PROTOCOL_ERROR;

    if ((g_inited == 0U) || (g_task_handle == NULL))
    {
        return MODBUS_MASTER_STATUS_NOT_READY;
    }

    if ((slave_addr == 0U) || (quantity == 0U) || (quantity > 125U) || (out_registers == NULL))
    {
        return MODBUS_MASTER_STATUS_INVALID_ARG;
    }

    if (out_exception_code != NULL)
    {
        *out_exception_code = 0U;
    }

    request_adu[0] = slave_addr;
    request_adu[1] = MODBUS_FUNCTION_READ_HOLDING_REGISTERS;
    request_adu[2] = (uint8_t)((start_addr >> 8U) & 0x00FFU);
    request_adu[3] = (uint8_t)(start_addr & 0x00FFU);
    request_adu[4] = (uint8_t)((quantity >> 8U) & 0x00FFU);
    request_adu[5] = (uint8_t)(quantity & 0x00FFU);

    for (attempt = 0U; attempt <= g_config.retry_count; ++attempt)
    {
        TickType_t deadline;

        ModbusTrace_TransactionStart(slave_addr, start_addr, quantity, attempt);
        (void)ulTaskNotifyTake(pdTRUE, 0U);
        ModbusRtuLink_PrepareForRequest();

        if (ModbusRtuLink_SendAdu(request_adu, sizeof(request_adu)) != pdPASS)
        {
            last_status = MODBUS_MASTER_STATUS_SEND_FAIL;
            ModbusTrace_TransactionResult(slave_addr,
                                         start_addr,
                                         quantity,
                                         attempt,
                                         ModbusMaster_StatusToString(last_status),
                                         0U);
        }
        else
        {
            deadline = xTaskGetTickCount() + ModbusTimebase_MsToTicks(g_config.response_timeout_ms);

            for (;;)
            {
                TickType_t remaining_ticks = ModbusMaster_GetRemainingTicks(deadline);
                ModbusRtuLinkStatus_TypeDef link_status;
                ModbusProtocolStatus_TypeDef protocol_status;

                if (remaining_ticks == 0U)
                {
                    uint32_t port_errors = ModbusRtuLink_GetAndClearPortErrors();
                    last_status = (port_errors != 0U) ? MODBUS_MASTER_STATUS_PORT_ERROR : MODBUS_MASTER_STATUS_TIMEOUT;
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                if (ulTaskNotifyTake(pdTRUE, remaining_ticks) == 0U)
                {
                    uint32_t port_errors = ModbusRtuLink_GetAndClearPortErrors();
                    last_status = (port_errors != 0U) ? MODBUS_MASTER_STATUS_PORT_ERROR : MODBUS_MASTER_STATUS_TIMEOUT;
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                link_status = ModbusRtuLink_FetchAdu(response_adu, sizeof(response_adu), &response_length);
                if (link_status == MODBUS_RTU_LINK_STATUS_EMPTY)
                {
                    continue;
                }

                if (link_status != MODBUS_RTU_LINK_STATUS_OK)
                {
                    last_status = ModbusMaster_MapLinkStatus(link_status);
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                protocol_status = ModbusProtocol_ParseReadHoldingResponse(response_adu,
                                                                          response_length,
                                                                          slave_addr,
                                                                          quantity,
                                                                          out_registers,
                                                                          out_exception_code);
                if (protocol_status == MODBUS_PROTOCOL_STATUS_OK)
                {
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(MODBUS_MASTER_STATUS_OK),
                                                 0U);
                    (void)ModbusRtuLink_GetAndClearPortErrors();
                    return MODBUS_MASTER_STATUS_OK;
                }

                if (protocol_status == MODBUS_PROTOCOL_STATUS_EXCEPTION)
                {
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(MODBUS_MASTER_STATUS_EXCEPTION),
                                                 (out_exception_code != NULL) ? *out_exception_code : 0U);
                    (void)ModbusRtuLink_GetAndClearPortErrors();
                    return MODBUS_MASTER_STATUS_EXCEPTION;
                }

                if (protocol_status == MODBUS_PROTOCOL_STATUS_RESPONSE_MISMATCH)
                {
                    ModbusTrace_LinkStatus("RESPONSE_MISMATCH");
                    continue;
                }

                last_status = MODBUS_MASTER_STATUS_PROTOCOL_ERROR;
                ModbusTrace_TransactionResult(slave_addr,
                                             start_addr,
                                             quantity,
                                             attempt,
                                             ModbusMaster_StatusToString(last_status),
                                             0U);
                break;
            }
        }

        (void)ModbusRtuLink_GetAndClearPortErrors();

        if (attempt < g_config.retry_count)
        {
            ModbusTimebase_SleepMs(g_config.inter_request_gap_ms);
        }
    }

    return last_status;
}

ModbusMasterStatus_TypeDef ModbusMaster_WriteMultipleRegisters(uint8_t slave_addr,
                                                               uint16_t start_addr,
                                                               uint16_t quantity,
                                                               const uint16_t *registers,
                                                               uint8_t *out_exception_code)
{
    uint8_t request_adu[MODBUS_RTU_LINK_MAX_ADU_LENGTH];
    uint8_t response_adu[MODBUS_RTU_LINK_MAX_ADU_LENGTH];
    uint16_t response_length = 0U;
    uint16_t request_length;
    uint8_t attempt;
    uint16_t i;
    ModbusMasterStatus_TypeDef last_status = MODBUS_MASTER_STATUS_PROTOCOL_ERROR;

    if ((g_inited == 0U) || (g_task_handle == NULL))
    {
        return MODBUS_MASTER_STATUS_NOT_READY;
    }

    if ((slave_addr == 0U) || (quantity == 0U) || (quantity > 123U) || (registers == NULL))
    {
        return MODBUS_MASTER_STATUS_INVALID_ARG;
    }

    if (out_exception_code != NULL)
    {
        *out_exception_code = 0U;
    }

    request_length = (uint16_t)(7U + (uint16_t)(quantity * 2U));
    if (request_length > (uint16_t)sizeof(request_adu))
    {
        return MODBUS_MASTER_STATUS_INVALID_ARG;
    }

    request_adu[0] = slave_addr;
    request_adu[1] = MODBUS_FUNCTION_WRITE_MULTIPLE_REGISTERS;
    request_adu[2] = (uint8_t)((start_addr >> 8U) & 0x00FFU);
    request_adu[3] = (uint8_t)(start_addr & 0x00FFU);
    request_adu[4] = (uint8_t)((quantity >> 8U) & 0x00FFU);
    request_adu[5] = (uint8_t)(quantity & 0x00FFU);
    request_adu[6] = (uint8_t)(quantity * 2U);

    for (i = 0U; i < quantity; ++i)
    {
        request_adu[7U + (2U * i)] = (uint8_t)((registers[i] >> 8U) & 0x00FFU);
        request_adu[8U + (2U * i)] = (uint8_t)(registers[i] & 0x00FFU);
    }

    for (attempt = 0U; attempt <= g_config.retry_count; ++attempt)
    {
        TickType_t deadline;

        ModbusTrace_TransactionStart(slave_addr, start_addr, quantity, attempt);
        (void)ulTaskNotifyTake(pdTRUE, 0U);
        ModbusRtuLink_PrepareForRequest();

        if (ModbusRtuLink_SendAdu(request_adu, request_length) != pdPASS)
        {
            last_status = MODBUS_MASTER_STATUS_SEND_FAIL;
            ModbusTrace_TransactionResult(slave_addr,
                                         start_addr,
                                         quantity,
                                         attempt,
                                         ModbusMaster_StatusToString(last_status),
                                         0U);
        }
        else
        {
            deadline = xTaskGetTickCount() + ModbusTimebase_MsToTicks(g_config.response_timeout_ms);

            for (;;)
            {
                TickType_t remaining_ticks = ModbusMaster_GetRemainingTicks(deadline);
                ModbusRtuLinkStatus_TypeDef link_status;
                ModbusProtocolStatus_TypeDef protocol_status;

                if (remaining_ticks == 0U)
                {
                    uint32_t port_errors = ModbusRtuLink_GetAndClearPortErrors();
                    last_status = (port_errors != 0U) ? MODBUS_MASTER_STATUS_PORT_ERROR : MODBUS_MASTER_STATUS_TIMEOUT;
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                if (ulTaskNotifyTake(pdTRUE, remaining_ticks) == 0U)
                {
                    uint32_t port_errors = ModbusRtuLink_GetAndClearPortErrors();
                    last_status = (port_errors != 0U) ? MODBUS_MASTER_STATUS_PORT_ERROR : MODBUS_MASTER_STATUS_TIMEOUT;
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                link_status = ModbusRtuLink_FetchAdu(response_adu, sizeof(response_adu), &response_length);
                if (link_status == MODBUS_RTU_LINK_STATUS_EMPTY)
                {
                    continue;
                }

                if (link_status != MODBUS_RTU_LINK_STATUS_OK)
                {
                    last_status = ModbusMaster_MapLinkStatus(link_status);
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(last_status),
                                                 0U);
                    break;
                }

                protocol_status = ModbusProtocol_ParseWriteMultipleRegistersResponse(response_adu,
                                                                                     response_length,
                                                                                     slave_addr,
                                                                                     start_addr,
                                                                                     quantity,
                                                                                     out_exception_code);
                if (protocol_status == MODBUS_PROTOCOL_STATUS_OK)
                {
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(MODBUS_MASTER_STATUS_OK),
                                                 0U);
                    (void)ModbusRtuLink_GetAndClearPortErrors();
                    return MODBUS_MASTER_STATUS_OK;
                }

                if (protocol_status == MODBUS_PROTOCOL_STATUS_EXCEPTION)
                {
                    ModbusTrace_TransactionResult(slave_addr,
                                                 start_addr,
                                                 quantity,
                                                 attempt,
                                                 ModbusMaster_StatusToString(MODBUS_MASTER_STATUS_EXCEPTION),
                                                 (out_exception_code != NULL) ? *out_exception_code : 0U);
                    (void)ModbusRtuLink_GetAndClearPortErrors();
                    return MODBUS_MASTER_STATUS_EXCEPTION;
                }

                if (protocol_status == MODBUS_PROTOCOL_STATUS_RESPONSE_MISMATCH)
                {
                    ModbusTrace_LinkStatus("RESPONSE_MISMATCH");
                    continue;
                }

                last_status = MODBUS_MASTER_STATUS_PROTOCOL_ERROR;
                ModbusTrace_TransactionResult(slave_addr,
                                             start_addr,
                                             quantity,
                                             attempt,
                                             ModbusMaster_StatusToString(last_status),
                                             0U);
                break;
            }
        }

        (void)ModbusRtuLink_GetAndClearPortErrors();

        if (attempt < g_config.retry_count)
        {
            ModbusTimebase_SleepMs(g_config.inter_request_gap_ms);
        }
    }

    return last_status;
}

const char *ModbusMaster_StatusToString(ModbusMasterStatus_TypeDef status)
{
    switch (status)
    {
    case MODBUS_MASTER_STATUS_OK:
        return "OK";
    case MODBUS_MASTER_STATUS_INVALID_ARG:
        return "INVALID_ARG";
    case MODBUS_MASTER_STATUS_NOT_READY:
        return "NOT_READY";
    case MODBUS_MASTER_STATUS_SEND_FAIL:
        return "SEND_FAIL";
    case MODBUS_MASTER_STATUS_TIMEOUT:
        return "TIMEOUT";
    case MODBUS_MASTER_STATUS_CRC_ERROR:
        return "CRC_ERROR";
    case MODBUS_MASTER_STATUS_PROTOCOL_ERROR:
        return "PROTOCOL_ERROR";
    case MODBUS_MASTER_STATUS_EXCEPTION:
        return "EXCEPTION";
    case MODBUS_MASTER_STATUS_PORT_ERROR:
        return "PORT_ERROR";
    default:
        return "UNKNOWN";
    }
}
