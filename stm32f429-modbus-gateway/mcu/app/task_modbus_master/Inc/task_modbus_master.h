/**
 * @file    task_modbus_master.h
 * @author  Yukikaze
 * @brief   Modbus 主站轮询任务头文件
 * @version 0.1
 * @date    2026-03-07
 */

#ifndef __TASK_MODBUS_MASTER_H
#define __TASK_MODBUS_MASTER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"
#include "task.h"

#define TASK_MODBUS_MASTER_NAME "Task_Modbus"
#define TASK_MODBUS_MASTER_STACK_SIZE 1024
#define TASK_MODBUS_MASTER_PRIORITY 2
#define TASK_MODBUS_MASTER_PERIOD_MS 1000U
#define TASK_MODBUS_MASTER_REQUEST_GAP_MS 10U
#define TASK_MODBUS_MASTER_TIMEOUT_MS 1000U
#define TASK_MODBUS_MASTER_RETRY_COUNT 2U

extern TaskHandle_t Task_ModbusMaster_Handle;

BaseType_t Task_ModbusMaster_Init(void);
BaseType_t Task_ModbusMaster_Create(void);
void Task_ModbusMaster(void *pvParameters);

#ifdef __cplusplus
}
#endif

#endif /* __TASK_MODBUS_MASTER_H */
