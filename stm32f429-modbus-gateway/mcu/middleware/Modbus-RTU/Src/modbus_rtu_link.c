/**
 * @file    modbus_rtu_link.c
 * @author  Yukikaze
 * @brief   Modbus RTU 链路层实现
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - ISR 只负责收字节、启动 T3.5 定时和通知任务。
 * - 帧缓存、CRC 校验和 ADU 提取全部在任务上下文完成。
 */

#include <stddef.h>

#include "modbus_rtu_link.h"

#include "bsp_rs485.h"
#include "modbus_crc.h"
#include "modbus_trace.h"

#include <string.h>

#define MODBUS_RTU_LINK_T35_US 4100U

static TaskHandle_t g_bound_task_handle = NULL;
static volatile uint8_t g_frame_ready = 0U;
static volatile uint8_t g_frame_overflow = 0U;
static volatile uint16_t g_rx_length = 0U;
static volatile uint8_t g_rx_buffer[MODBUS_RTU_LINK_MAX_ADU_LENGTH + 2U];

static void ModbusRtuLink_OnRxByte(uint8_t byte)
{
    if (g_rx_length < sizeof(g_rx_buffer))
    {
        g_rx_buffer[g_rx_length] = byte;
        g_rx_length++;
    }
    else
    {
        g_frame_overflow = 1U;
    }

    BspRs485_RestartT35TimerUs(MODBUS_RTU_LINK_T35_US);
}

static void ModbusRtuLink_OnT35Expired(void)
{
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    if ((g_rx_length == 0U) && (g_frame_overflow == 0U))
    {
        return;
    }

    g_frame_ready = 1U;

    if (g_bound_task_handle != NULL)
    {
        vTaskNotifyGiveFromISR(g_bound_task_handle, &xHigherPriorityTaskWoken);
        portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
    }
}

BaseType_t ModbusRtuLink_Init(void)
{
    BspRs485_RegisterRxByteCallback(ModbusRtuLink_OnRxByte);
    BspRs485_RegisterT35Callback(ModbusRtuLink_OnT35Expired);
    ModbusRtuLink_PrepareForRequest();
    return pdPASS;
}

void ModbusRtuLink_BindTask(TaskHandle_t task_handle)
{
    g_bound_task_handle = task_handle;
}

void ModbusRtuLink_PrepareForRequest(void)
{
    taskENTER_CRITICAL();
    g_frame_ready = 0U;
    g_frame_overflow = 0U;
    g_rx_length = 0U;
    (void)memset((void *)g_rx_buffer, 0, sizeof(g_rx_buffer));
    taskEXIT_CRITICAL();

    BspRs485_StopT35Timer();
    (void)BspRs485_GetAndClearErrorFlags();
}

BaseType_t ModbusRtuLink_SendAdu(const uint8_t *adu, uint16_t adu_length)
{
    uint8_t frame[MODBUS_RTU_LINK_MAX_ADU_LENGTH + 2U];
    uint16_t crc;

    if ((adu == NULL) || (adu_length == 0U) || (adu_length > MODBUS_RTU_LINK_MAX_ADU_LENGTH))
    {
        return pdFAIL;
    }

    (void)memcpy(frame, adu, adu_length);
    crc = ModbusCrc16_Calculate(adu, adu_length);
    frame[adu_length] = (uint8_t)(crc & 0x00FFU);
    frame[adu_length + 1U] = (uint8_t)((crc >> 8U) & 0x00FFU);
    ModbusTrace_TxFrame(frame, (uint16_t)(adu_length + 2U));

    return BspRs485_Transmit(frame, (uint16_t)(adu_length + 2U));
}

ModbusRtuLinkStatus_TypeDef ModbusRtuLink_FetchAdu(uint8_t *out_adu,
                                                   uint16_t out_adu_size,
                                                   uint16_t *out_adu_length)
{
    uint8_t frame[MODBUS_RTU_LINK_MAX_ADU_LENGTH + 2U];
    uint16_t frame_length;
    uint8_t overflow;
    uint16_t crc_expected;
    uint16_t crc_received;

    if ((out_adu == NULL) || (out_adu_length == NULL) || (out_adu_size == 0U))
    {
        return MODBUS_RTU_LINK_STATUS_FRAME_ERROR;
    }

    *out_adu_length = 0U;

    taskENTER_CRITICAL();

    if (g_frame_ready == 0U)
    {
        taskEXIT_CRITICAL();
        return MODBUS_RTU_LINK_STATUS_EMPTY;
    }

    frame_length = g_rx_length;
    overflow = g_frame_overflow;
    if (frame_length > sizeof(frame))
    {
        frame_length = sizeof(frame);
    }
    (void)memcpy(frame, (const void *)g_rx_buffer, frame_length);

    g_frame_ready = 0U;
    g_frame_overflow = 0U;
    g_rx_length = 0U;

    taskEXIT_CRITICAL();

    if (frame_length != 0U)
    {
        ModbusTrace_RxFrame(frame, frame_length);
    }

    if (overflow != 0U)
    {
        ModbusTrace_LinkStatus("OVERFLOW");
        return MODBUS_RTU_LINK_STATUS_OVERFLOW;
    }

    if ((frame_length < 4U) || (frame_length > (uint16_t)(out_adu_size + 2U)))
    {
        ModbusTrace_LinkStatus("FRAME_ERROR");
        return MODBUS_RTU_LINK_STATUS_FRAME_ERROR;
    }

    crc_expected = ModbusCrc16_Calculate(frame, (uint16_t)(frame_length - 2U));
    crc_received = (uint16_t)((uint16_t)frame[frame_length - 2U] |
                              ((uint16_t)frame[frame_length - 1U] << 8U));
    if (crc_expected != crc_received)
    {
        ModbusTrace_LinkStatus("CRC_ERROR");
        return MODBUS_RTU_LINK_STATUS_CRC_ERROR;
    }

    (void)memcpy(out_adu, frame, (size_t)(frame_length - 2U));
    *out_adu_length = (uint16_t)(frame_length - 2U);
    return MODBUS_RTU_LINK_STATUS_OK;
}

uint32_t ModbusRtuLink_GetAndClearPortErrors(void)
{
    return BspRs485_GetAndClearErrorFlags();
}
