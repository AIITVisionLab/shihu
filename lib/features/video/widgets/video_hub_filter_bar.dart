import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/video/video_hub_query_controller.dart';

/// 视频中心筛选和检索栏。
class VideoHubFilterBar extends StatefulWidget {
  /// 创建视频中心筛选和检索栏。
  const VideoHubFilterBar({
    required this.queryState,
    required this.visibleCount,
    required this.totalCount,
    required this.onKeywordChanged,
    required this.onClearKeyword,
    required this.onFilterChanged,
    super.key,
  });

  /// 当前查询状态。
  final VideoHubQueryState queryState;

  /// 当前可见数量。
  final int visibleCount;

  /// 当前总数量。
  final int totalCount;

  /// 关键词变更回调。
  final ValueChanged<String> onKeywordChanged;

  /// 清空关键词回调。
  final VoidCallback onClearKeyword;

  /// 筛选条件变更回调。
  final ValueChanged<VideoHubFilter> onFilterChanged;

  @override
  State<VideoHubFilterBar> createState() => _VideoHubFilterBarState();
}

class _VideoHubFilterBarState extends State<VideoHubFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.queryState.keyword);
  }

  @override
  void didUpdateWidget(covariant VideoHubFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.queryState.keyword) {
      _controller.value = TextEditingValue(
        text: widget.queryState.keyword,
        selection: TextSelection.collapsed(
          offset: widget.queryState.keyword.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.38),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                AppCopy.videoFilterTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                AppCopy.videoVisibleCount(
                  widget.visibleCount,
                  widget.totalCount,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: widget.onKeywordChanged,
            decoration: InputDecoration(
              hintText: AppCopy.videoSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: widget.queryState.keyword.isEmpty
                  ? null
                  : IconButton(
                      tooltip: AppCopy.cancel,
                      onPressed: () {
                        widget.onClearKeyword();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: VideoHubFilter.values
                .map(
                  (filter) => ChoiceChip(
                    label: Text(filter.label),
                    selected: widget.queryState.filter == filter,
                    onSelected: (_) => widget.onFilterChanged(filter),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}
