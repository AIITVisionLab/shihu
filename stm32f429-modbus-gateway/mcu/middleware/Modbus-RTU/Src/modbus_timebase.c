/**
 * @file    modbus_timebase.c
 * @author  Yukikaze
 * @brief   Modbus 时间基准实现
 * @version 0.1
 * @date    2026-03-07
 */

#include "modbus_timebase.h"

#include "task.h"

uint32_t ModbusTimebase_GetMs(void)
{
    return (uint32_t)(xTaskGetTickCount() * (TickType_t)portTICK_PERIOD_MS);
}

TickType_t ModbusTimebase_MsToTicks(uint32_t time_ms)
{
    TickType_t ticks = pdMS_TO_TICKS(time_ms);

    if ((time_ms != 0U) && (ticks == 0U))
    {
        ticks = 1U;
    }

    return ticks;
}

void ModbusTimebase_SleepMs(uint32_t time_ms)
{
    TickType_t ticks = ModbusTimebase_MsToTicks(time_ms);

    if (ticks == 0U)
    {
        return;
    }

    vTaskDelay(ticks);
}
