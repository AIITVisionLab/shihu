/**
 * @file    main.c
 * @author  Yukikaze
 * @brief   主函数入口（系统初始化 + 创建应用任务）
 * @version 0.2
 * @date    2026-03-07
 *
 * @note
 * - 当前工程仅保留两类应用任务：Modbus 主站轮询任务与 HTTP 上报任务。
 * - LwIP_Init 必须在调度器启动后调用（当前 NO_SYS=0，依赖 tcpip_thread）。
 */

#include "FreeRTOS.h"
#include "task.h"
#include <stdio.h>
#include "stm32f4xx.h"
#include "stm32f4xx_conf.h"

#include "bsp_led.h"
#include "bsp_usart.h"

#include "app_data.h"
#include "app_control.h"
#include "task_modbus_master.h"
#include "task_uplink.h"

#include "netconf.h"

static TaskHandle_t AppTaskCreate_Handle = NULL;

static void BSP_Init(void);
static void AppTaskCreate(void *pvParameters);
static void SystemClock_Config(void);

int main(void)
{
    BaseType_t xReturn = pdPASS;

    SystemClock_Config();
    BSP_Init();

    xReturn = xTaskCreate((TaskFunction_t)AppTaskCreate,
                          (const char *)"AppTaskCreate",
                          (uint16_t)512,
                          (void *)NULL,
                          (UBaseType_t)1,
                          (TaskHandle_t *)&AppTaskCreate_Handle);

    if (pdPASS == xReturn)
    {
        vTaskStartScheduler();
    }
    else
    {
        LED_RED;
        while (1)
        {
        }
    }

    while (1)
    {
    }
}

static void BSP_Init(void)
{
    uint32_t i;

    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);

    LED_GPIO_Config();
    LED_BLUE;

    USARTx_Config();

    for (i = 0; i < 1800000U; i++)
    {
        __NOP();
    }
    LED_RGBOFF;
}

static void AppTaskCreate(void *pvParameters)
{
    BaseType_t xReturn = pdPASS;
    BaseType_t critical_entered = pdFALSE;

    (void)pvParameters;

    LwIP_Init();

    xReturn = AppData_Init();
    if (pdPASS != xReturn)
    {
        goto error_no_critical;
    }

    xReturn = AppControl_Init();
    if (pdPASS != xReturn)
    {
        goto error_no_critical;
    }

    xReturn = Task_Uplink_Init();
    if (pdPASS != xReturn)
    {
        goto error_no_critical;
    }

    xReturn = Task_ModbusMaster_Init();
    if (pdPASS != xReturn)
    {
        goto error_no_critical;
    }

    taskENTER_CRITICAL();
    critical_entered = pdTRUE;

    xReturn = Task_Uplink_Create();
    if (pdPASS != xReturn)
    {
        goto error;
    }

    xReturn = Task_ModbusMaster_Create();
    if (pdPASS != xReturn)
    {
        goto error;
    }

    if (critical_entered == pdTRUE)
    {
        taskEXIT_CRITICAL();
        critical_entered = pdFALSE;
    }

    vTaskDelete(AppTaskCreate_Handle);
    return;

error_no_critical:
    LED_RED;
    vTaskDelete(AppTaskCreate_Handle);
    return;

error:
    LED_RED;
    if (critical_entered == pdTRUE)
    {
        taskEXIT_CRITICAL();
        critical_entered = pdFALSE;
    }
    vTaskDelete(AppTaskCreate_Handle);
}

void vApplicationStackOverflowHook(TaskHandle_t xTask, char *pcTaskName)
{
    (void)xTask;
    (void)pcTaskName;

    taskDISABLE_INTERRUPTS();

    for (;;)
    {
        LED_RED;
        for (volatile uint32_t i = 0; i < 800000U; ++i)
        {
            __NOP();
        }
        LED_RGBOFF;
        for (volatile uint32_t i = 0; i < 800000U; ++i)
        {
            __NOP();
        }
    }
}

void vApplicationMallocFailedHook(void)
{
    taskDISABLE_INTERRUPTS();
    LED_RED;
    for (;;)
    {
    }
}

static void SystemClock_Config(void)
{
    RCC_DeInit();
    RCC_HSEConfig(RCC_HSE_ON);
    if (RCC_WaitForHSEStartUp() == SUCCESS)
    {
        RCC_APB1PeriphClockCmd(RCC_APB1Periph_PWR, ENABLE);
        PWR_MainRegulatorModeConfig(PWR_Regulator_Voltage_Scale1);
        RCC_HCLKConfig(RCC_SYSCLK_Div1);
        RCC_PCLK2Config(RCC_HCLK_Div2);
        RCC_PCLK1Config(RCC_HCLK_Div4);
        RCC_PLLConfig(RCC_PLLSource_HSE, 25, 360, 2, 7);
        RCC_PLLCmd(ENABLE);
        while (RCC_GetFlagStatus(RCC_FLAG_PLLRDY) == RESET)
        {
        }
        FLASH_SetLatency(FLASH_Latency_5);
        FLASH_PrefetchBufferCmd(ENABLE);
        FLASH_InstructionCacheCmd(ENABLE);
        FLASH_DataCacheCmd(ENABLE);
        RCC_SYSCLKConfig(RCC_SYSCLKSource_PLLCLK);
        while (RCC_GetSYSCLKSource() != 0x08)
        {
        }
    }
    else
    {
        while (1)
        {
        }
    }

    SystemCoreClockUpdate();
}
