/**
 * @file    bsp_rs485.c
 * @author  Yukikaze
 * @brief   RS485 硬件驱动实现（USART2 + PB8 + TIM6）
 * @version 0.1
 * @date    2026-03-07
 *
 * @note
 * - PD5: USART2_TX，PD6: USART2_RX，PB8: DE/RE。
 * - USART2 使用 9600 8E1，TIM6 用于检测 RTU 帧间隔 T3.5。
 */

#include "bsp_rs485.h"

#include "stm32f4xx.h"
#include "stm32f4xx_conf.h"
#include "task.h"

#include <string.h>

#define BSP_RS485_USART USART2
#define BSP_RS485_USART_CLK RCC_APB1Periph_USART2
#define BSP_RS485_USART_IRQn USART2_IRQn

#define BSP_RS485_GPIO_PORT GPIOD
#define BSP_RS485_GPIO_CLK RCC_AHB1Periph_GPIOD
#define BSP_RS485_TX_PIN GPIO_Pin_5
#define BSP_RS485_RX_PIN GPIO_Pin_6
#define BSP_RS485_TX_SOURCE GPIO_PinSource5
#define BSP_RS485_RX_SOURCE GPIO_PinSource6
#define BSP_RS485_GPIO_AF GPIO_AF_USART2

#define BSP_RS485_DIR_GPIO_PORT GPIOB
#define BSP_RS485_DIR_GPIO_CLK RCC_AHB1Periph_GPIOB
#define BSP_RS485_DIR_PIN GPIO_Pin_8

#define BSP_RS485_TIMER TIM6
#define BSP_RS485_TIMER_CLK RCC_APB1Periph_TIM6
#define BSP_RS485_TIMER_IRQn TIM6_DAC_IRQn

#define BSP_RS485_BAUDRATE 9600U
#define BSP_RS485_TX_BUFFER_LEN 260U
#define BSP_RS485_DEFAULT_T35_US 4100U

static volatile uint8_t g_inited = 0U;
static volatile uint8_t g_tx_busy = 0U;
static volatile uint16_t g_tx_length = 0U;
static volatile uint16_t g_tx_index = 0U;
static volatile uint32_t g_error_flags = 0U;

static uint8_t g_tx_buffer[BSP_RS485_TX_BUFFER_LEN];
static BspRs485RxByteCallback_TypeDef g_rx_byte_callback = NULL;
static BspRs485TimerCallback_TypeDef g_t35_callback = NULL;

static void BspRs485_SetDirectionTx(void)
{
    GPIO_SetBits(BSP_RS485_DIR_GPIO_PORT, BSP_RS485_DIR_PIN);
}

static void BspRs485_SetDirectionRx(void)
{
    GPIO_ResetBits(BSP_RS485_DIR_GPIO_PORT, BSP_RS485_DIR_PIN);
}

BaseType_t BspRs485_Init(void)
{
    GPIO_InitTypeDef gpio_init;
    USART_InitTypeDef usart_init;
    TIM_TimeBaseInitTypeDef tim_init;
    NVIC_InitTypeDef nvic_init;

    if (g_inited != 0U)
    {
        return pdPASS;
    }

    RCC_AHB1PeriphClockCmd(BSP_RS485_GPIO_CLK | BSP_RS485_DIR_GPIO_CLK, ENABLE);
    RCC_APB1PeriphClockCmd(BSP_RS485_USART_CLK | BSP_RS485_TIMER_CLK, ENABLE);

    GPIO_PinAFConfig(BSP_RS485_GPIO_PORT, BSP_RS485_TX_SOURCE, BSP_RS485_GPIO_AF);
    GPIO_PinAFConfig(BSP_RS485_GPIO_PORT, BSP_RS485_RX_SOURCE, BSP_RS485_GPIO_AF);

    GPIO_StructInit(&gpio_init);
    gpio_init.GPIO_Mode = GPIO_Mode_AF;
    gpio_init.GPIO_OType = GPIO_OType_PP;
    gpio_init.GPIO_PuPd = GPIO_PuPd_UP;
    gpio_init.GPIO_Speed = GPIO_Speed_50MHz;
    gpio_init.GPIO_Pin = BSP_RS485_TX_PIN | BSP_RS485_RX_PIN;
    GPIO_Init(BSP_RS485_GPIO_PORT, &gpio_init);

    gpio_init.GPIO_Mode = GPIO_Mode_OUT;
    gpio_init.GPIO_OType = GPIO_OType_PP;
    gpio_init.GPIO_PuPd = GPIO_PuPd_NOPULL;
    gpio_init.GPIO_Pin = BSP_RS485_DIR_PIN;
    GPIO_Init(BSP_RS485_DIR_GPIO_PORT, &gpio_init);
    BspRs485_SetDirectionRx();

    USART_StructInit(&usart_init);
    usart_init.USART_BaudRate = BSP_RS485_BAUDRATE;
    usart_init.USART_WordLength = USART_WordLength_9b;
    usart_init.USART_StopBits = USART_StopBits_1;
    usart_init.USART_Parity = USART_Parity_Even;
    usart_init.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
    usart_init.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
    USART_Init(BSP_RS485_USART, &usart_init);

    USART_ClearFlag(BSP_RS485_USART, USART_FLAG_TC);
    USART_ITConfig(BSP_RS485_USART, USART_IT_RXNE, ENABLE);
    USART_ITConfig(BSP_RS485_USART, USART_IT_TXE, DISABLE);
    USART_ITConfig(BSP_RS485_USART, USART_IT_TC, DISABLE);
    USART_Cmd(BSP_RS485_USART, ENABLE);

    TIM_TimeBaseStructInit(&tim_init);
    tim_init.TIM_Prescaler = 89U;
    tim_init.TIM_Period = (uint16_t)(BSP_RS485_DEFAULT_T35_US - 1U);
    tim_init.TIM_CounterMode = TIM_CounterMode_Up;
    tim_init.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseInit(BSP_RS485_TIMER, &tim_init);
    TIM_ClearITPendingBit(BSP_RS485_TIMER, TIM_IT_Update);
    TIM_ITConfig(BSP_RS485_TIMER, TIM_IT_Update, DISABLE);
    TIM_Cmd(BSP_RS485_TIMER, DISABLE);

    nvic_init.NVIC_IRQChannel = BSP_RS485_USART_IRQn;
    nvic_init.NVIC_IRQChannelPreemptionPriority = 6;
    nvic_init.NVIC_IRQChannelSubPriority = 0;
    nvic_init.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&nvic_init);

    nvic_init.NVIC_IRQChannel = BSP_RS485_TIMER_IRQn;
    nvic_init.NVIC_IRQChannelPreemptionPriority = 6;
    nvic_init.NVIC_IRQChannelSubPriority = 0;
    nvic_init.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&nvic_init);

    g_tx_busy = 0U;
    g_tx_length = 0U;
    g_tx_index = 0U;
    g_error_flags = 0U;
    g_inited = 1U;
    return pdPASS;
}

void BspRs485_RegisterRxByteCallback(BspRs485RxByteCallback_TypeDef callback)
{
    g_rx_byte_callback = callback;
}

void BspRs485_RegisterT35Callback(BspRs485TimerCallback_TypeDef callback)
{
    g_t35_callback = callback;
}

BaseType_t BspRs485_Transmit(const uint8_t *data, uint16_t length)
{
    if ((data == NULL) || (length == 0U) || (length > BSP_RS485_TX_BUFFER_LEN) || (g_inited == 0U))
    {
        return pdFAIL;
    }

    taskENTER_CRITICAL();

    if (g_tx_busy != 0U)
    {
        taskEXIT_CRITICAL();
        return pdFAIL;
    }

    (void)memcpy(g_tx_buffer, data, length);
    g_tx_length = length;
    g_tx_index = 0U;
    g_tx_busy = 1U;

    BspRs485_StopT35Timer();
    USART_ClearFlag(BSP_RS485_USART, USART_FLAG_TC);
    BspRs485_SetDirectionTx();
    USART_ITConfig(BSP_RS485_USART, USART_IT_TC, DISABLE);
    USART_ITConfig(BSP_RS485_USART, USART_IT_TXE, ENABLE);

    taskEXIT_CRITICAL();
    return pdPASS;
}

void BspRs485_RestartT35TimerUs(uint16_t timeout_us)
{
    if (timeout_us == 0U)
    {
        timeout_us = 1U;
    }

    TIM_SetAutoreload(BSP_RS485_TIMER, (uint16_t)(timeout_us - 1U));
    TIM_SetCounter(BSP_RS485_TIMER, 0U);
    TIM_ClearITPendingBit(BSP_RS485_TIMER, TIM_IT_Update);
    TIM_ITConfig(BSP_RS485_TIMER, TIM_IT_Update, ENABLE);
    TIM_Cmd(BSP_RS485_TIMER, ENABLE);
}

void BspRs485_StopT35Timer(void)
{
    TIM_ITConfig(BSP_RS485_TIMER, TIM_IT_Update, DISABLE);
    TIM_Cmd(BSP_RS485_TIMER, DISABLE);
    TIM_ClearITPendingBit(BSP_RS485_TIMER, TIM_IT_Update);
}

uint8_t BspRs485_IsBusy(void)
{
    return g_tx_busy;
}

uint32_t BspRs485_GetAndClearErrorFlags(void)
{
    uint32_t error_flags;

    taskENTER_CRITICAL();
    error_flags = g_error_flags;
    g_error_flags = 0U;
    taskEXIT_CRITICAL();

    return error_flags;
}

void USART2_IRQHandler(void)
{
    uint32_t sr = BSP_RS485_USART->SR;
    uint32_t cr1 = BSP_RS485_USART->CR1;

    if ((sr & (USART_SR_PE | USART_SR_FE | USART_SR_NE | USART_SR_ORE)) != 0U)
    {
        g_error_flags |= (sr & (USART_SR_PE | USART_SR_FE | USART_SR_NE | USART_SR_ORE));
    }

    if (((sr & USART_SR_RXNE) != 0U) && ((cr1 & USART_CR1_RXNEIE) != 0U))
    {
        uint8_t byte = (uint8_t)USART_ReceiveData(BSP_RS485_USART);
        if (g_rx_byte_callback != NULL)
        {
            g_rx_byte_callback(byte);
        }
    }
    else if ((sr & (USART_SR_PE | USART_SR_FE | USART_SR_NE | USART_SR_ORE)) != 0U)
    {
        volatile uint16_t dummy = USART_ReceiveData(BSP_RS485_USART);
        (void)dummy;
    }

    sr = BSP_RS485_USART->SR;
    cr1 = BSP_RS485_USART->CR1;

    if (((sr & USART_SR_TXE) != 0U) && ((cr1 & USART_CR1_TXEIE) != 0U))
    {
        if ((g_tx_busy != 0U) && (g_tx_index < g_tx_length))
        {
            USART_SendData(BSP_RS485_USART, g_tx_buffer[g_tx_index]);
            g_tx_index++;

            if (g_tx_index >= g_tx_length)
            {
                USART_ITConfig(BSP_RS485_USART, USART_IT_TXE, DISABLE);
                USART_ITConfig(BSP_RS485_USART, USART_IT_TC, ENABLE);
            }
        }
        else
        {
            USART_ITConfig(BSP_RS485_USART, USART_IT_TXE, DISABLE);
            USART_ITConfig(BSP_RS485_USART, USART_IT_TC, ENABLE);
        }
    }

    sr = BSP_RS485_USART->SR;
    cr1 = BSP_RS485_USART->CR1;

    if (((sr & USART_SR_TC) != 0U) && ((cr1 & USART_CR1_TCIE) != 0U))
    {
        USART_ITConfig(BSP_RS485_USART, USART_IT_TC, DISABLE);
        BspRs485_SetDirectionRx();
        g_tx_busy = 0U;
    }
}

void TIM6_DAC_IRQHandler(void)
{
    if (TIM_GetITStatus(BSP_RS485_TIMER, TIM_IT_Update) != RESET)
    {
        TIM_ClearITPendingBit(BSP_RS485_TIMER, TIM_IT_Update);
        TIM_ITConfig(BSP_RS485_TIMER, TIM_IT_Update, DISABLE);
        TIM_Cmd(BSP_RS485_TIMER, DISABLE);

        if (g_t35_callback != NULL)
        {
            g_t35_callback();
        }
    }
}
