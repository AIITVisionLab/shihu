/**
 * @file    modbus_rtu_link.h
 * @author  Yukikaze
 * @brief   Modbus RTU 链路层头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __MODBUS_RTU_LINK_H
#define __MODBUS_RTU_LINK_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"
#include "task.h"

#include <stdint.h>

#define MODBUS_RTU_LINK_MAX_ADU_LENGTH 256U

typedef enum
{
    MODBUS_RTU_LINK_STATUS_OK = 0,
    MODBUS_RTU_LINK_STATUS_EMPTY = 1,
    MODBUS_RTU_LINK_STATUS_OVERFLOW = 2,
    MODBUS_RTU_LINK_STATUS_CRC_ERROR = 3,
    MODBUS_RTU_LINK_STATUS_FRAME_ERROR = 4
} ModbusRtuLinkStatus_TypeDef;

BaseType_t ModbusRtuLink_Init(void);
void ModbusRtuLink_BindTask(TaskHandle_t task_handle);
void ModbusRtuLink_PrepareForRequest(void);
BaseType_t ModbusRtuLink_SendAdu(const uint8_t *adu, uint16_t adu_length);
ModbusRtuLinkStatus_TypeDef ModbusRtuLink_FetchAdu(uint8_t *out_adu,
                                                   uint16_t out_adu_size,
                                                   uint16_t *out_adu_length);
uint32_t ModbusRtuLink_GetAndClearPortErrors(void);

#ifdef __cplusplus
}
#endif

#endif /* __MODBUS_RTU_LINK_H */
