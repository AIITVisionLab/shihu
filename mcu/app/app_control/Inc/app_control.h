/**
 * @file    app_control.h
 * @author  Yukikaze
 * @brief   云控命令共享状态模块头文件
 * @version 0.1
 * @date    2026-03-17
 *
 * @note
 * - 本模块负责保存 RK3568 通过 uplink HTTP 响应下发的待执行命令。
 * - 命令以 `seq` 去重；同一序号只会被成功提交到 PLC 一次。
 */

#ifndef __APP_CONTROL_H
#define __APP_CONTROL_H

#include "FreeRTOS.h"

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

typedef enum
{
    APP_CONTROL_COMMAND_NONE = 0,
    APP_CONTROL_COMMAND_HOME = 1,
    APP_CONTROL_COMMAND_MOVE_REL = 2,
    APP_CONTROL_COMMAND_STOP = 3,
    APP_CONTROL_COMMAND_PUMP_ON = 4,
    APP_CONTROL_COMMAND_PUMP_OFF = 5
} AppControlCommandCode_TypeDef;

typedef enum
{
    APP_CONTROL_STEPPER_IDLE = 0,
    APP_CONTROL_STEPPER_HOMING_CLEAR = 1,
    APP_CONTROL_STEPPER_HOMING_SEARCH = 2,
    APP_CONTROL_STEPPER_MOVING = 3,
    APP_CONTROL_STEPPER_STOPPING = 4,
    APP_CONTROL_STEPPER_FAULT = 5
} AppControlStepperState_TypeDef;

typedef enum
{
    APP_CONTROL_RESULT_NONE = 0,
    APP_CONTROL_RESULT_ACCEPTED = 1,
    APP_CONTROL_RESULT_RUNNING = 2,
    APP_CONTROL_RESULT_DONE = 3,
    APP_CONTROL_RESULT_STOPPED = 4,
    APP_CONTROL_RESULT_NOT_HOMED = 40,
    APP_CONTROL_RESULT_LIMIT_REJECT = 41,
    APP_CONTROL_RESULT_PARAM_INVALID = 42,
    APP_CONTROL_RESULT_HOME_TIMEOUT = 43,
    APP_CONTROL_RESULT_BUSY_REJECT = 44
} AppControlResultCode_TypeDef;

typedef struct
{
    uint16_t seq;
    uint16_t code;
    int32_t arg1;
    int32_t arg2;
    uint16_t arg3;
} AppControlCommand_TypeDef;

BaseType_t AppControl_Init(void);
void AppControl_HandleUplinkResponse(const char *body, size_t body_len, uint16_t http_status);
uint8_t AppControl_PeekPendingCommand(AppControlCommand_TypeDef *out_command);
void AppControl_MarkCommandCommitted(uint16_t seq);
const char *AppControl_ResultCodeToString(uint16_t result_code);
const char *AppControl_StepperStateToString(uint16_t state_code);

#ifdef __cplusplus
}
#endif

#endif /* __APP_CONTROL_H */
