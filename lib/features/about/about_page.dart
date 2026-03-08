import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 关于页，展示项目定位、技术基线和开发策略。
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
            constraints: const BoxConstraints(maxWidth: 900),
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
