/**
 * @file    modbus_timebase.h
 * @author  Yukikaze
 * @brief   Modbus 时间基准头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __MODBUS_TIMEBASE_H
#define __MODBUS_TIMEBASE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"

#include <stdint.h>

uint32_t ModbusTimebase_GetMs(void);
TickType_t ModbusTimebase_MsToTicks(uint32_t time_ms);
void ModbusTimebase_SleepMs(uint32_t time_ms);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_TIMEBASE_H */
