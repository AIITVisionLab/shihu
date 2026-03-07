package com.aurora.iotonenet.application.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class DeviceIntegrationService {

    private static final Logger logger = LoggerFactory.getLogger(DeviceIntegrationService.class);
    private final DeviceStateService deviceStateService;
    private final OperationRegistryService operationRegistryService;

    public DeviceIntegrationService(DeviceStateService deviceStateService,
                                    OperationRegistryService operationRegistryService) {
        this.deviceStateService = deviceStateService;
        this.operationRegistryService = operationRegistryService;
    }

    public void handleDeviceData(String deviceId, String deviceName,
                                 Double temperature, Double humidity,
                                 Double light, Double mq2, Integer error, Boolean led) {
        long timestamp = System.currentTimeMillis();
        deviceStateService.updateState(deviceId, deviceName, temperature, humidity, light, mq2, error, led, timestamp);
        logger.info("处理设备数据: deviceId={}, deviceName={}, temp={}, hum={}, light={}, mq2={}, error={}, led={}",
                deviceId, deviceName, temperature, humidity, light, mq2, error, led);
    }

    public void handleSetReply(String deviceId, String requestId, boolean success, String message) {
        if (requestId != null) {
            operationRegistryService.complete(deviceId, requestId, success, message);
            logger.info("处理set_reply: deviceId={}, requestId={}, success={}, message={}",
                    deviceId, requestId, success, message);
        }
    }

    public void handleSetReplyByRequestId(String requestId, boolean success, String message) {
        if (requestId != null) {
            operationRegistryService.completeByRequestId(requestId, success, message);
            logger.info("通过requestId处理set_reply: requestId={}, success={}, message={}",
                    requestId, success, message);
        }
    }
}
