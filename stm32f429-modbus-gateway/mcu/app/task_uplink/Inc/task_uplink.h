/**
 * @file    task_uplink.h
 * @author  Yukikaze
 * @brief   异步上报调度任务头文件（周期驱动 uplink_poll）
 * @version 0.3
 * @date    2026-03-07
 *
 * @note
 * - 本任务只负责周期调用 uplink_poll()，发送异步队列中的消息。
 * - 当前业务上报内容为 `MODBUS_SNAPSHOT` 采集快照。
 */

#ifndef __TASK_UPLINK_H
#define __TASK_UPLINK_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "FreeRTOS.h"
#include "task.h"

#include "uplink.h"

#define TASK_UPLINK_NAME "Task_Uplink"
#define TASK_UPLINK_STACK_SIZE 1024
#define TASK_UPLINK_PRIORITY 3
#define TASK_UPLINK_PERIOD_MS 100

#ifndef TASK_UPLINK_SERVER_HOST
#define TASK_UPLINK_SERVER_HOST "192.168.50.1"
#endif

#ifndef TASK_UPLINK_SERVER_PORT
#define TASK_UPLINK_SERVER_PORT 8080
#endif

#ifndef TASK_UPLINK_SERVER_PATH
#define TASK_UPLINK_SERVER_PATH "/api/uplink"
#endif

extern uplink_t g_uplink;
extern TaskHandle_t Task_Uplink_Handle;

BaseType_t Task_Uplink_Init(void);
BaseType_t Task_Uplink_Create(void);
void Task_Uplink(void *pvParameters);

#ifdef __cplusplus
}
#endif

#endif /* __TASK_UPLINK_H */
