/**
 * @file    uplink_types.h
 * @author  Yukikaze
 * @brief   Uplink 公共类型与编译期参数定义
 * @version 0.2
 * @date    2026-03-07
 */

#ifndef __UPLINK_TYPES_H
#define __UPLINK_TYPES_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stddef.h>
#include <stdint.h>

#ifndef UPLINK_MAX_HOST_LEN
#define UPLINK_MAX_HOST_LEN 64
#endif

#ifndef UPLINK_MAX_PATH_LEN
#define UPLINK_MAX_PATH_LEN 96
#endif

#ifndef UPLINK_MAX_DEVICE_ID_LEN
#define UPLINK_MAX_DEVICE_ID_LEN 32
#endif

#ifndef UPLINK_MAX_TYPE_LEN
#define UPLINK_MAX_TYPE_LEN 32
#endif

#ifndef UPLINK_MAX_PAYLOAD_LEN
#define UPLINK_MAX_PAYLOAD_LEN 512
#endif

#ifndef UPLINK_MAX_EVENT_JSON_LEN
#define UPLINK_MAX_EVENT_JSON_LEN 1024
#endif

#ifndef UPLINK_MAX_HTTP_BODY_LEN
#define UPLINK_MAX_HTTP_BODY_LEN 512
#endif

#ifndef UPLINK_QUEUE_MAX_LEN
#define UPLINK_QUEUE_MAX_LEN 8
#endif

typedef enum
{
    UPLINK_OK = 0,
    UPLINK_ERR_INVALID_ARG = 1,
    UPLINK_ERR_NOT_INIT = 2,
    UPLINK_ERR_QUEUE_FULL = 3,
    UPLINK_ERR_QUEUE_EMPTY = 4,
    UPLINK_ERR_BUFFER_TOO_SMALL = 5,
    UPLINK_ERR_UNSUPPORTED = 6,
    UPLINK_ERR_TRANSPORT = 7,
    UPLINK_ERR_CODEC = 8,
    UPLINK_ERR_INTERNAL = 9
} uplink_err_t;

typedef enum
{
    UPLINK_SCHEME_HTTP = 0,
    UPLINK_SCHEME_HTTPS = 1
} uplink_scheme_t;

typedef enum
{
    UPLINK_LOG_ERROR = 0,
    UPLINK_LOG_WARN = 1,
    UPLINK_LOG_INFO = 2,
    UPLINK_LOG_DEBUG = 3
} uplink_log_level_t;

typedef struct
{
    uplink_scheme_t scheme;
    char host[UPLINK_MAX_HOST_LEN];
    uint16_t port;
    char path[UPLINK_MAX_PATH_LEN];
    uint8_t use_dns;
} uplink_endpoint_t;

#define UPLINK_APP_CODE_UNKNOWN ((int32_t)0x7fffffff)

typedef struct
{
    uint16_t http_status;
    int32_t app_code;
} uplink_ack_t;

typedef struct
{
    uint32_t base_delay_ms;
    uint32_t max_delay_ms;
    uint16_t max_attempts;
    uint8_t jitter_pct;
} uplink_retry_policy_t;

typedef struct
{
    uint32_t message_id;
    uint32_t created_ms;
    char type[UPLINK_MAX_TYPE_LEN];
    char payload_json[UPLINK_MAX_PAYLOAD_LEN];
    uint16_t attempt;
    uint32_t next_retry_ms;
} uplink_msg_t;

#ifdef __cplusplus
}
#endif

#endif /* __UPLINK_TYPES_H */
