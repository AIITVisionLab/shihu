/**
 * @file    uplink_platform.h
 * @author  Yukikaze
 * @brief   Uplink 平台适配接口
 * @version 0.2
 * @date    2026-03-17
 */

#ifndef __UPLINK_PLATFORM_H
#define __UPLINK_PLATFORM_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "uplink_types.h"

typedef uint32_t (*uplink_now_ms_fn)(void *user_ctx);
typedef uint32_t (*uplink_rand_u32_fn)(void *user_ctx);
typedef void (*uplink_log_fn)(void *user_ctx, uplink_log_level_t level, const char *message);
typedef void (*uplink_http_response_fn)(void *user_ctx,
                                        const char *body,
                                        size_t body_len,
                                        uint16_t http_status);

typedef struct
{
    void *user_ctx;
    uplink_now_ms_fn now_ms;
    uplink_rand_u32_fn rand_u32;
    uplink_log_fn log;
    uplink_http_response_fn on_http_response;
} uplink_platform_t;

#ifdef __cplusplus
}
#endif

#endif /* __UPLINK_PLATFORM_H */
