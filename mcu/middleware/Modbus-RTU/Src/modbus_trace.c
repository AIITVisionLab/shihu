/**
 * @file    modbus_trace.c
 * @author  Yukikaze
 * @brief   Modbus 联调日志实现
 * @version 0.1
 * @date    2026-03-08
 */

#include "modbus_trace.h"

#include <stddef.h>
#include <stdio.h>

#if MODBUS_TRACE_ENABLE

static const char *ModbusTrace_SafeStr(const char *str)
{
    return (str != NULL) ? str : "";
}

static void ModbusTrace_PrintFrame(const char *tag, const uint8_t *frame, uint16_t length)
{
    uint16_t i;

    if ((frame == NULL) || (length == 0U))
    {
        return;
    }

    printf("[mb][%s]", ModbusTrace_SafeStr(tag));
    for (i = 0U; i < length; ++i)
    {
        printf("%s%02X", (i == 0U) ? " " : " ", frame[i]);
    }
    printf("\r\n");
}

void ModbusTrace_CycleBegin(uint32_t cycle_id)
{
    printf("[mb][cycle] begin id=%lu\r\n", (unsigned long)cycle_id);
}

void ModbusTrace_CycleEnd(uint32_t cycle_id)
{
    printf("[mb][cycle] end id=%lu\r\n", (unsigned long)cycle_id);
}

void ModbusTrace_TxFrame(const uint8_t *frame, uint16_t length)
{
    ModbusTrace_PrintFrame("tx", frame, length);
}

void ModbusTrace_RxFrame(const uint8_t *frame, uint16_t length)
{
    ModbusTrace_PrintFrame("rx", frame, length);
}

void ModbusTrace_LinkStatus(const char *status)
{
    printf("[mb][link] %s\r\n", ModbusTrace_SafeStr(status));
}

void ModbusTrace_TransactionStart(uint8_t slave_addr, uint16_t start_addr, uint16_t quantity, uint8_t attempt)
{
    printf("[mb][txn] start slave=%u addr=%u qty=%u attempt=%u\r\n",
           (unsigned)slave_addr,
           (unsigned)start_addr,
           (unsigned)quantity,
           (unsigned)(attempt + 1U));
}

void ModbusTrace_TransactionResult(uint8_t slave_addr,
                                   uint16_t start_addr,
                                   uint16_t quantity,
                                   uint8_t attempt,
                                   const char *result,
                                   uint8_t exception_code)
{
    printf("[mb][txn] result slave=%u addr=%u qty=%u attempt=%u status=%s",
           (unsigned)slave_addr,
           (unsigned)start_addr,
           (unsigned)quantity,
           (unsigned)(attempt + 1U),
           ModbusTrace_SafeStr(result));

    if (exception_code != 0U)
    {
        printf(" exception=0x%02X", exception_code);
    }

    printf("\r\n");
}

void ModbusTrace_Value1(uint8_t slave_addr, const char *name0, uint16_t value0)
{
    printf("[mb][value] slave=%u %s=%u\r\n",
           (unsigned)slave_addr,
           ModbusTrace_SafeStr(name0),
           (unsigned)value0);
}

void ModbusTrace_Value2(uint8_t slave_addr,
                        const char *name0,
                        uint16_t value0,
                        const char *name1,
                        uint16_t value1)
{
    printf("[mb][value] slave=%u %s=%u %s=%u\r\n",
           (unsigned)slave_addr,
           ModbusTrace_SafeStr(name0),
           (unsigned)value0,
           ModbusTrace_SafeStr(name1),
           (unsigned)value1);
}

#else

void ModbusTrace_CycleBegin(uint32_t cycle_id)
{
    (void)cycle_id;
}

void ModbusTrace_CycleEnd(uint32_t cycle_id)
{
    (void)cycle_id;
}

void ModbusTrace_TxFrame(const uint8_t *frame, uint16_t length)
{
    (void)frame;
    (void)length;
}

void ModbusTrace_RxFrame(const uint8_t *frame, uint16_t length)
{
    (void)frame;
    (void)length;
}

void ModbusTrace_LinkStatus(const char *status)
{
    (void)status;
}

void ModbusTrace_TransactionStart(uint8_t slave_addr, uint16_t start_addr, uint16_t quantity, uint8_t attempt)
{
    (void)slave_addr;
    (void)start_addr;
    (void)quantity;
    (void)attempt;
}

void ModbusTrace_TransactionResult(uint8_t slave_addr,
                                   uint16_t start_addr,
                                   uint16_t quantity,
                                   uint8_t attempt,
                                   const char *result,
                                   uint8_t exception_code)
{
    (void)slave_addr;
    (void)start_addr;
    (void)quantity;
    (void)attempt;
    (void)result;
    (void)exception_code;
}

void ModbusTrace_Value1(uint8_t slave_addr, const char *name0, uint16_t value0)
{
    (void)slave_addr;
    (void)name0;
    (void)value0;
}

void ModbusTrace_Value2(uint8_t slave_addr,
                        const char *name0,
                        uint16_t value0,
                        const char *name1,
                        uint16_t value1)
{
    (void)slave_addr;
    (void)name0;
    (void)value0;
    (void)name1;
    (void)value1;
}

#endif
