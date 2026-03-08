/**
 * @file    modbus_crc.c
 * @author  Yukikaze
 * @brief   Modbus CRC16 计算实现
 * @version 0.1
 * @date    2026-03-07
 */

#include <stddef.h>

#include "modbus_crc.h"

uint16_t ModbusCrc16_Calculate(const uint8_t *data, uint16_t length)
{
    uint16_t crc = 0xFFFFU;
    uint16_t i;
    uint8_t j;

    if (data == NULL)
    {
        return 0U;
    }

    for (i = 0U; i < length; ++i)
    {
        crc ^= (uint16_t)data[i];
        for (j = 0U; j < 8U; ++j)
        {
            if ((crc & 0x0001U) != 0U)
            {
                crc = (uint16_t)((crc >> 1U) ^ 0xA001U);
            }
            else
            {
                crc >>= 1U;
            }
        }
    }

    return crc;
}
