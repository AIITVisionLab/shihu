import 'package:flutter/material.dart';

/// 首页入口卡片。
class HomeEntryCard extends StatefulWidget {
  /// 创建首页入口卡片。
  const HomeEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  /// 图标。
  final IconData icon;

  /// 标题。
  final String title;

  /// 副标题。
  final String subtitle;

  /// 点击回调。
  final VoidCallback onTap;

  @override
  State<HomeEntryCard> createState() => _HomeEntryCardState();
}

class _HomeEntryCardState extends State<HomeEntryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isHovered
                  ? colorScheme.surfaceContainerLow
                  : colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? colorScheme.primary.withValues(alpha: 0.26)
                    : colorScheme.outlineVariant.withValues(alpha: 0.34),
              ),
              boxShadow: _isHovered
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0C172019),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.52,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: _isHovered
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
