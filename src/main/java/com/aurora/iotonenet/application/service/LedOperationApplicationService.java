package com.aurora.iotonenet.application.service;

import com.aurora.iotonenet.api.dto.LedOperationRequest;
import com.aurora.iotonenet.api.dto.LedOperationResponse;
import com.aurora.iotonenet.api.dto.OneNetApiResult;
import com.aurora.iotonenet.infrastructure.onenet.OneNetApiService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class LedOperationApplicationService {

    private static final Logger logger = LoggerFactory.getLogger(LedOperationApplicationService.class);
    private final DeviceStateService deviceStateService;
    private final OneNetApiService oneNetApiService;
    private final OperationRegistryService operationRegistryService;

    public LedOperationApplicationService(DeviceStateService deviceStateService,
                                          OneNetApiService oneNetApiService,
                                          OperationRegistryService operationRegistryService) {
        this.deviceStateService = deviceStateService;
        this.oneNetApiService = oneNetApiService;
        this.operationRegistryService = operationRegistryService;
    }

    public LedOperationResponse setLed(LedOperationRequest request) {
        String deviceId = request.getDeviceId();
        String effectiveDeviceName = resolveDeviceName(request);
        Boolean led = request.getLed();

        logger.info("执行LED操作: deviceId={}, deviceName={}, led={}", deviceId, effectiveDeviceName, led);
        OneNetApiResult apiResult = oneNetApiService.setLedProperty(effectiveDeviceName, led);

        String requestId;
        String status;
        String message;

        if (apiResult != null && apiResult.isSuccess() && apiResult.getOperationId() != null) {
            requestId = apiResult.getOperationId();
            status = "accepted";
            message = "已通过OneNET API下发LED指令";
            operationRegistryService.registerWith(deviceId, led, requestId);
        } else {
            requestId = operationRegistryService.register(deviceId, led);
            status = "pending";
            message = "OneNET API调用失败,已登记到待处理队列: " +
                    (apiResult != null ? apiResult.getBody() : "未知错误");
            logger.warn("OneNET API调用失败: httpCode={}, body={}",
                    apiResult != null ? apiResult.getHttpCode() : -1,
                    apiResult != null ? apiResult.getBody() : "null");
        }

        return new LedOperationResponse(status, requestId, message);
    }

    private String resolveDeviceName(LedOperationRequest request) {
        String deviceName = request.getDeviceName();
        if (deviceName == null || deviceName.trim().isEmpty()) {
            deviceName = deviceStateService.getCurrentDeviceName();
        }
        if (deviceName == null || deviceName.trim().isEmpty()) {
            deviceName = request.getDeviceId();
        }
        return deviceName;
    }
}
