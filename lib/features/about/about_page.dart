import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 关于页，展示当前平台定位和后端收口策略。
class AboutPage extends StatelessWidget {
  /// 创建关于页。
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppCopy.aboutPageTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const <Widget>[
                CommonCard(
                  title: AppCopy.aboutProjectTitle,
                  child: Text(
                    '${AppConstants.appName}${AppCopy.aboutProjectDescription}',
                  ),
                ),
                SizedBox(height: 20),
                CommonCard(
                  title: '当前已接通能力',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('1. 登录链路：/api/login、/api/check-login、/api/logout。'),
                      SizedBox(height: 8),
                      Text('2. 设备监控：/api/status 返回设备名称、环境数据、错误码和 LED 状态。'),
                      SizedBox(height: 8),
                      Text('3. 运维排障：/api/ops/led 与 /api/health 已在前端落地。'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                CommonCard(
                  title: AppCopy.aboutTechTitle,
                  child: Text(AppCopy.aboutTechDescription),
                ),
                SizedBox(height: 20),
                CommonCard(
                  title: AppCopy.aboutStrategyTitle,
                  child: Text(AppCopy.aboutStrategyDescription),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
