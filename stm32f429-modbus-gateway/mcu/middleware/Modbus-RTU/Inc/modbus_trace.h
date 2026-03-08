/**
 * @file    modbus_trace.h
 * @author  Yukikaze
 * @brief   Modbus 联调日志接口
 * @version 0.1
 * @date    2026-03-08
 *
 * @note
 * - 本模块仅用于主从联调阶段观察 RTU 请求/响应与事务状态。
 * - 通过编译期开关统一裁剪，接入 RK3568 后可整体关闭。
 */

#ifndef __MODBUS_TRACE_H
#define __MODBUS_TRACE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>

#ifndef MODBUS_TRACE_ENABLE
#define MODBUS_TRACE_ENABLE 0
#endif

void ModbusTrace_CycleBegin(uint32_t cycle_id);
void ModbusTrace_CycleEnd(uint32_t cycle_id);
void ModbusTrace_TxFrame(const uint8_t *frame, uint16_t length);
void ModbusTrace_RxFrame(const uint8_t *frame, uint16_t length);
void ModbusTrace_LinkStatus(const char *status);
void ModbusTrace_TransactionStart(uint8_t slave_addr, uint16_t start_addr, uint16_t quantity, uint8_t attempt);
void ModbusTrace_TransactionResult(uint8_t slave_addr,
                                   uint16_t start_addr,
                                   uint16_t quantity,
                                   uint8_t attempt,
                                   const char *result,
                                   uint8_t exception_code);
void ModbusTrace_Value1(uint8_t slave_addr, const char *name0, uint16_t value0);
void ModbusTrace_Value2(uint8_t slave_addr,
                        const char *name0,
                        uint16_t value0,
                        const char *name1,
                        uint16_t value1);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_TRACE_H */
