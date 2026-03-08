/**
 * @file    modbus_crc.h
 * @author  Yukikaze
 * @brief   Modbus CRC16 计算头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __MODBUS_CRC_H
#define __MODBUS_CRC_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

uint16_t ModbusCrc16_Calculate(const uint8_t *data, uint16_t length);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_CRC_H */
