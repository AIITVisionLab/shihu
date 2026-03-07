/**
 * @file    app_data.h
 * @author  Yukikaze
 * @brief   采集快照共享数据模块头文件
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - 本模块用于在 Modbus 采集任务与上报任务之间共享三路从站快照。
 * - 所有读写接口均通过互斥量保护，避免多任务并发竞争。
 */

#ifndef __APP_DATA_H
#define __APP_DATA_H

#include "FreeRTOS.h"

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

typedef enum
{
    APP_DATA_ERROR_NONE = 0,
    APP_DATA_ERROR_TIMEOUT = 1,
    APP_DATA_ERROR_CRC = 2,
    APP_DATA_ERROR_PROTOCOL = 3,
    APP_DATA_ERROR_EXCEPTION = 4,
    APP_DATA_ERROR_PORT = 5
} AppDataError_TypeDef;

typedef struct
{
    uint8_t online;
    uint8_t valid;
    AppDataError_TypeDef last_error;
    uint32_t last_update_ms;
    uint16_t light_adc;
} AppDataSlave1Snapshot_TypeDef;

typedef struct
{
    uint8_t online;
    uint8_t valid;
    AppDataError_TypeDef last_error;
    uint32_t last_update_ms;
    uint16_t temperature;
    uint16_t humidity;
} AppDataSlave2Snapshot_TypeDef;

typedef struct
{
    uint8_t online;
    uint8_t valid;
    AppDataError_TypeDef last_error;
    uint32_t last_update_ms;
    uint16_t mq2_ppm;
} AppDataSlave3Snapshot_TypeDef;

typedef struct
{
    AppDataSlave1Snapshot_TypeDef slave1;
    AppDataSlave2Snapshot_TypeDef slave2;
    AppDataSlave3Snapshot_TypeDef slave3;
} AppDataSnapshot_TypeDef;

BaseType_t AppData_Init(void);
void AppData_UpdateSlave1(uint16_t light_adc, uint32_t now_ms);
void AppData_UpdateSlave2(uint16_t temperature, uint16_t humidity, uint32_t now_ms);
void AppData_UpdateSlave3(uint16_t mq2_ppm, uint32_t now_ms);
void AppData_SetSlaveError(uint8_t slave_addr, AppDataError_TypeDef error_code);
void AppData_GetSnapshot(AppDataSnapshot_TypeDef *pSnapshot);
const char *AppData_ErrorToString(AppDataError_TypeDef error_code);

#ifdef __cplusplus
}
#endif

#endif /* __APP_DATA_H */
