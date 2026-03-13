import 'package:flutter/material.dart';
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
      subtitle: '先看状态，再进入对应页面。',
      child: Column(
        children: <Widget>[
          for (int index = 0; index < children.length; index++) ...<Widget>[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
