import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

void main() {
  test('DeviceStatusViewData maps safe state to user-facing copy', () {
    final viewData = DeviceStatusViewData.fromState(
      const DeviceStatus(
        deviceId: 'dev_1',
        deviceName: '石斛培育柜',
        temperature: 24.5,
        humidity: 82.0,
        light: 1500,
        mq2: 18,
        errorCode: 0,
        ledOn: true,
        updatedAt: 1741399200000,
      ),
      referenceTime: DateTime.fromMillisecondsSinceEpoch(1741399205000),
    );

    expect(viewData.deviceLabel, '石斛培育柜');
    expect(viewData.alertLevel, DeviceAlertLevel.safe);
    expect(viewData.alertTitle, '系统运行正常');
    expect(viewData.alertDescription, contains('正常区间'));
    expect(viewData.freshnessLabel, '数据已同步');
    expect(viewData.ledLabel, '已开启');
    expect(viewData.temperatureLabel, '24.5 °C');
    expect(viewData.lightLabel, '1500 Lux');
  });

  test('DeviceStatusViewData falls back for unknown state values', () {
    final viewData = DeviceStatusViewData.fromState(
      const DeviceStatus(
        deviceId: '',
        deviceName: '',
        temperature: null,
        humidity: null,
        light: null,
        mq2: null,
        errorCode: 99,
        ledOn: null,
        updatedAt: 0,
      ),
    );

    expect(viewData.deviceLabel, '当前设备');
    expect(viewData.alertLevel, DeviceAlertLevel.unknown);
    expect(viewData.alertTitle, '状态来源待确认');
    expect(viewData.freshnessLabel, '未收到设备上报');
    expect(viewData.ledLabel, '未知');
    expect(viewData.temperatureLabel, '--');
  });
}
