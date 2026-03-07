/**
 * @file    uplink_codec_json.h
 * @author  Yukikaze
 * @brief   Uplink JSON 编解码接口
 * @version 0.2
 * @date    2026-03-07
 *
 * @note
 * - 编码职责：把内部消息封装成统一事件 JSON。
 * - 解码职责：从响应 body 中解析业务 `code` 字段。
 * - 当前事件类型以 `MODBUS_SNAPSHOT` 为主。
 */

#ifndef __UPLINK_CODEC_JSON_H
#define __UPLINK_CODEC_JSON_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "uplink_types.h"

uplink_err_t uplink_codec_json_build_event(char *out_json,
                                           size_t out_json_len,
                                           const char *device_id,
                                           uint32_t message_id,
                                           uint32_t ts_ms,
                                           const char *type,
                                           const char *payload_json,
                                           size_t *out_written);

uplink_err_t uplink_codec_json_parse_app_code(const char *body,
                                              size_t body_len,
                                              int32_t *out_code);

#ifdef __cplusplus
}
#endif

#endif /* __UPLINK_CODEC_JSON_H */
