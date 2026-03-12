import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 兼容旧引用保留的说明区块。
///
/// 当前说明页已经收敛为主路径与协作边界两组信息，这个区块只保留为
/// 兼容旧代码时的轻量说明，不再单独出现在正式页面中。
class AboutResearchSection extends StatelessWidget {
  /// 创建兼容说明区块。
  const AboutResearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '说明范围',
      subtitle: '旧版背景说明已合并到新的工作说明结构中。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AboutContent.scopeRules
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item == AboutContent.scopeRules.last ? 0 : 12,
                ),
                child: Text(
                  '${item.title}：${item.description}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.64),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
