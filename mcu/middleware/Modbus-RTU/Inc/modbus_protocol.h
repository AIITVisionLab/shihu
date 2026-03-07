/**
 * @file    modbus_protocol.h
 * @author  Yukikaze
 * @brief   Modbus 协议解析头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __MODBUS_PROTOCOL_H
#define __MODBUS_PROTOCOL_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

typedef enum
{
    MODBUS_PROTOCOL_STATUS_OK = 0,
    MODBUS_PROTOCOL_STATUS_INVALID_ARG = 1,
    MODBUS_PROTOCOL_STATUS_RESPONSE_MISMATCH = 2,
    MODBUS_PROTOCOL_STATUS_EXCEPTION = 3,
    MODBUS_PROTOCOL_STATUS_LENGTH_ERROR = 4,
    MODBUS_PROTOCOL_STATUS_FUNCTION_ERROR = 5
} ModbusProtocolStatus_TypeDef;

#define MODBUS_FUNCTION_READ_HOLDING_REGISTERS 0x03U

ModbusProtocolStatus_TypeDef ModbusProtocol_ParseReadHoldingResponse(const uint8_t *adu,
                                                                    uint16_t adu_length,
                                                                    uint8_t expected_slave,
                                                                    uint16_t expected_quantity,
                                                                    uint16_t *out_registers,
                                                                    uint8_t *out_exception_code);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_PROTOCOL_H */
