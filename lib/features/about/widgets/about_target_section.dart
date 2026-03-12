import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 兼容旧引用保留的目标说明区块。
///
/// 当前正式说明页已把原有目标与流程说明并入主路径轨道和协作边界，不再
/// 单独维护旧版指标卡片。
class AboutTargetSection extends StatelessWidget {
  /// 创建兼容说明区块。
  const AboutTargetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '当前取舍',
      subtitle: '把真正可用的路径和未来协作边界拆开讲，避免说明页继续膨胀。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AboutContent.workflowTracks
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item == AboutContent.workflowTracks.last ? 0 : 12,
                ),
                child: Text(
                  '${item.title}：${item.summary}',
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
