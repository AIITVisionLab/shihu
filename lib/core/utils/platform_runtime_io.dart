import 'dart:io' as io;

/// 通过运行时操作系统标识判断当前是否为 OpenHarmony / 鸿蒙。
bool isOhosRuntime() => io.Platform.operatingSystem == 'ohos';
