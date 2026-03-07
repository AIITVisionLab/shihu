/**
 * @file    bsp_rs485.h
 * @author  Yukikaze
 * @brief   RS485 硬件驱动头文件（USART2 + PB8 + TIM6）
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __BSP_RS485_H
#define __BSP_RS485_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"
#include "stm32f4xx.h"

#include <stdint.h>

typedef void (*BspRs485RxByteCallback_TypeDef)(uint8_t byte);
typedef void (*BspRs485TimerCallback_TypeDef)(void);

#define BSP_RS485_ERROR_NONE    0U
#define BSP_RS485_ERROR_PE      USART_SR_PE
#define BSP_RS485_ERROR_FE      USART_SR_FE
#define BSP_RS485_ERROR_NE      USART_SR_NE
#define BSP_RS485_ERROR_ORE     USART_SR_ORE

BaseType_t BspRs485_Init(void);
void BspRs485_RegisterRxByteCallback(BspRs485RxByteCallback_TypeDef callback);
void BspRs485_RegisterT35Callback(BspRs485TimerCallback_TypeDef callback);
BaseType_t BspRs485_Transmit(const uint8_t *data, uint16_t length);
void BspRs485_RestartT35TimerUs(uint16_t timeout_us);
void BspRs485_StopT35Timer(void);
uint8_t BspRs485_IsBusy(void);
uint32_t BspRs485_GetAndClearErrorFlags(void);

void USART2_IRQHandler(void);
void TIM6_DAC_IRQHandler(void);

#ifdef __cplusplus
}
#endif

#endif /* __BSP_RS485_H */
