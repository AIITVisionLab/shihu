/**
 ******************************************************************************
 * @file    netconf.h
 * @author  MCD Application Team / Yukikaze
 * @brief   LwIP 网络配置头文件
 ******************************************************************************
 */

#ifndef __NETCONF_H
#define __NETCONF_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "stm32f4xx.h"

#define DHCP_START 1
#define DHCP_WAIT_ADDRESS 2
#define DHCP_ADDRESS_ASSIGNED 3
#define DHCP_TIMEOUT 4
#define DHCP_LINK_DOWN 5

/* #define USE_DHCP */
/* #define SERIAL_DEBUG */

/* F429 与 RK3568 直连场景使用静态地址。 */
#define MAC_ADDR0 0x02
#define MAC_ADDR1 0x00
#define MAC_ADDR2 0x00
#define MAC_ADDR3 0x12
#define MAC_ADDR4 0x34
#define MAC_ADDR5 0x56

#define IP_ADDR0 192
#define IP_ADDR1 168
#define IP_ADDR2 50
#define IP_ADDR3 240

#define NETMASK_ADDR0 255
#define NETMASK_ADDR1 255
#define NETMASK_ADDR2 255
#define NETMASK_ADDR3 0

#define GW_ADDR0 192
#define GW_ADDR1 168
#define GW_ADDR2 50
#define GW_ADDR3 1

#ifndef LINK_TIMER_INTERVAL
#define LINK_TIMER_INTERVAL 1000
#endif

#define RMII_MODE
/* #define MII_MODE */

#ifdef MII_MODE
#define PHY_CLOCK_MCO
#endif

void LwIP_Init(void);
void LwIP_Pkt_Handle(void);
void LwIP_Periodic_Handle(__IO uint32_t localtime);

#ifdef __cplusplus
}
#endif

#endif /* __NETCONF_H */
