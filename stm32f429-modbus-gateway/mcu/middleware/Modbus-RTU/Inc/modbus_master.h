/**
 * @file    modbus_master.h
 * @author  Yukikaze
 * @brief   Modbus 主站事务接口头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __MODBUS_MASTER_H
#define __MODBUS_MASTER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"
#include "task.h"

#include <stdint.h>

typedef struct
{
    uint32_t response_timeout_ms;
    uint8_t retry_count;
    uint32_t inter_request_gap_ms;
} ModbusMasterConfig_TypeDef;

typedef enum
{
    MODBUS_MASTER_STATUS_OK = 0,
    MODBUS_MASTER_STATUS_INVALID_ARG = 1,
    MODBUS_MASTER_STATUS_NOT_READY = 2,
    MODBUS_MASTER_STATUS_SEND_FAIL = 3,
    MODBUS_MASTER_STATUS_TIMEOUT = 4,
    MODBUS_MASTER_STATUS_CRC_ERROR = 5,
    MODBUS_MASTER_STATUS_PROTOCOL_ERROR = 6,
    MODBUS_MASTER_STATUS_EXCEPTION = 7,
    MODBUS_MASTER_STATUS_PORT_ERROR = 8
} ModbusMasterStatus_TypeDef;

BaseType_t ModbusMaster_Init(const ModbusMasterConfig_TypeDef *config);
void ModbusMaster_BindTask(TaskHandle_t task_handle);
ModbusMasterStatus_TypeDef ModbusMaster_ReadHoldingRegisters(uint8_t slave_addr,
                                                             uint16_t start_addr,
                                                             uint16_t quantity,
                                                             uint16_t *out_registers,
                                                             uint8_t *out_exception_code);
const char *ModbusMaster_StatusToString(ModbusMasterStatus_TypeDef status);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_MASTER_H */
