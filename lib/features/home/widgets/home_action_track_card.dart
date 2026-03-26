import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页常用轨道卡片，按使用顺序收纳主入口。
class HomeActionTrackCard extends StatelessWidget {
  /// 创建首页常用轨道卡片。
  const HomeActionTrackCard({required this.children, super.key});

  /// 轨道内的入口项。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '常用入口',
      subtitle: '值守负责处理状态，视频负责查看画面，我的负责账号和本机设置。',
      accentColor: AppPalette.softPine,
      headerIcon: Icons.dashboard_customize_outlined,
      headerTag: '主路径',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760 || children.length < 3) {
            return Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < children.length;
                  index++
                ) ...<Widget>[
                  children[index],
                  if (index != children.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }

          return Column(
            children: <Widget>[
              children.first,
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: children[1]),
                  const SizedBox(width: 14),
                  Expanded(child: children[2]),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
