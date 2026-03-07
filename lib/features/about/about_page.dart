import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 关于页，展示项目定位、技术基线和开发策略。
class AboutPage extends StatelessWidget {
  /// 创建关于页。
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于项目')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const <Widget>[
                CommonCard(
                  title: '项目定位',
                  child: Text(
                    '${AppConstants.appName} 是一个面向石斛种植与养护场景的跨平台 Flutter 前端，'
                    '用于演示单图识别、实时识别、结果展示、历史记录和运行环境配置。',
                  ),
                ),
                SizedBox(height: 20),
                CommonCard(
                  title: '当前技术基线',
                  child: Text(
                    'Flutter 全平台工程、OpenHarmony Flutter 3.35.7 模板、Material 3、GoRouter、Riverpod、Dio、SharedPreferences。',
                  ),
                ),
                SizedBox(height: 20),
                CommonCard(
                  title: '开发策略',
                  child: Text(
                    '当前先通过受控 mock 数据打通单图识别主链路，后续在 Repository 层切换到真实 Java 后端接口，不改页面契约。',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
