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
          borderRadius: BorderRadius.circular(22),
          onTap: widget.onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 320;
              final iconBoxSize = isCompact ? 44.0 : 48.0;
              final cardPadding = isCompact ? 16.0 : 18.0;
              final minHeight = isCompact ? 156.0 : 168.0;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                constraints: BoxConstraints(minHeight: minHeight),
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surfaceContainerLow.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _isHovered
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  boxShadow: _isHovered
                      ? const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x52000000),
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ]
                      : const <BoxShadow>[],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.icon,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: _isHovered
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    SizedBox(height: isCompact ? 24 : 28),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.52,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
