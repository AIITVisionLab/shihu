/**
 * @file    modbus_protocol.c
 * @author  Yukikaze
 * @brief   Modbus 协议解析实现
 * @version 0.1
 * @date    2026-03-07
 */

#include <stddef.h>

#include "modbus_protocol.h"

ModbusProtocolStatus_TypeDef ModbusProtocol_ParseReadHoldingResponse(const uint8_t *adu,
                                                                    uint16_t adu_length,
                                                                    uint8_t expected_slave,
                                                                    uint16_t expected_quantity,
                                                                    uint16_t *out_registers,
                                                                    uint8_t *out_exception_code)
{
    uint16_t expected_bytes;
    uint16_t i;

    if ((adu == NULL) || (out_registers == NULL) || (expected_quantity == 0U))
    {
        return MODBUS_PROTOCOL_STATUS_INVALID_ARG;
    }

    if (out_exception_code != NULL)
    {
        *out_exception_code = 0U;
    }

    if (adu_length < 3U)
    {
        return MODBUS_PROTOCOL_STATUS_LENGTH_ERROR;
    }

    if (adu[0] != expected_slave)
    {
        return MODBUS_PROTOCOL_STATUS_RESPONSE_MISMATCH;
    }

    if (adu[1] == (uint8_t)(MODBUS_FUNCTION_READ_HOLDING_REGISTERS | 0x80U))
    {
        if ((adu_length >= 3U) && (out_exception_code != NULL))
        {
            *out_exception_code = adu[2];
        }
        return MODBUS_PROTOCOL_STATUS_EXCEPTION;
    }

    if (adu[1] != MODBUS_FUNCTION_READ_HOLDING_REGISTERS)
    {
        return MODBUS_PROTOCOL_STATUS_FUNCTION_ERROR;
    }

    expected_bytes = (uint16_t)(expected_quantity * 2U);
    if ((adu[2] != (uint8_t)expected_bytes) || (adu_length != (uint16_t)(3U + expected_bytes)))
    {
        return MODBUS_PROTOCOL_STATUS_LENGTH_ERROR;
    }

    for (i = 0U; i < expected_quantity; ++i)
    {
        out_registers[i] = (uint16_t)(((uint16_t)adu[3U + (2U * i)] << 8U) |
                                      (uint16_t)adu[4U + (2U * i)]);
    }

    return MODBUS_PROTOCOL_STATUS_OK;
}
