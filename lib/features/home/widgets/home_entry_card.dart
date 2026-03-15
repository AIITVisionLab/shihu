import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 首页入口卡片。
class HomeEntryCard extends StatefulWidget {
  /// 创建首页入口卡片。
  const HomeEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.stepLabel,
    this.accentColor,
    this.prominent = false,
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

  /// 序号标签。
  final String? stepLabel;

  /// 强调色。
  final Color? accentColor;

  /// 是否使用主操作卡样式。
  final bool prominent;

  @override
  State<HomeEntryCard> createState() => _HomeEntryCardState();
}

class _HomeEntryCardState extends State<HomeEntryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = widget.accentColor ?? colorScheme.primary;
    final backgroundGradient = widget.prominent
        ? <Color>[
            accentColor.withValues(alpha: 0.18),
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.98),
            AppPalette.frost.withValues(alpha: 0.98),
          ]
        : <Color>[
            colorScheme.surfaceBright.withValues(alpha: 0.99),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.97),
          ];
    final borderColor = _isHovered
        ? accentColor.withValues(alpha: 0.42)
        : colorScheme.outlineVariant.withValues(alpha: 0.66);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(
            0,
            _isHovered ? (widget.prominent ? -5 : -3) : 0,
            0,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundGradient,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (_isHovered ? accentColor : AppPalette.pineShadow)
                    .withValues(alpha: _isHovered ? 0.14 : 0.05),
                blurRadius: _isHovered ? 26 : 16,
                offset: Offset(0, widget.prominent ? 12 : 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: widget.onTap,
            child: Stack(
              children: <Widget>[
                if (widget.prominent)
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    child: IgnorePointer(
                      child: Container(
                        height: 1.4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.72),
                              accentColor.withValues(alpha: 0.38),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    widget.prominent ? 20 : 18,
                    18,
                    18,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 420;
                      final content = _EntryContent(
                        title: widget.title,
                        subtitle: widget.subtitle,
                        stepLabel: widget.stepLabel,
                        icon: widget.icon,
                        isHovered: _isHovered,
                        accentColor: accentColor,
                        prominent: widget.prominent,
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            content,
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _EntryArrow(
                                isHovered: _isHovered,
                                accentColor: accentColor,
                                prominent: widget.prominent,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(child: content),
                          const SizedBox(width: 14),
                          _EntryArrow(
                            isHovered: _isHovered,
                            accentColor: accentColor,
                            prominent: widget.prominent,
                          ),
                        ],
                      );
                    },
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

class _EntryContent extends StatelessWidget {
  const _EntryContent({
    required this.title,
    required this.subtitle,
    required this.stepLabel,
    required this.icon,
    required this.isHovered,
    required this.accentColor,
    required this.prominent,
  });

  final String title;
  final String subtitle;
  final String? stepLabel;
  final IconData icon;
  final bool isHovered;
  final Color accentColor;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: prominent ? 58 : 52,
          height: prominent ? 58 : 52,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: isHovered ? 0.26 : 0.18),
            borderRadius: BorderRadius.circular(prominent ? 20 : 18),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: accentColor, size: prominent ? 28 : 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (stepLabel != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    stepLabel!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: prominent ? 1.08 : 1.14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.56,
                ),
              ),
              if (prominent) ...<Widget>[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest.withValues(
                      alpha: 0.82,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.52),
                    ),
                  ),
                  child: Text(
                    '登录后默认进入这块，优先处理实时状态。',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EntryArrow extends StatelessWidget {
  const _EntryArrow({
    required this.isHovered,
    required this.accentColor,
    required this.prominent,
  });

  final bool isHovered;
  final Color accentColor;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: prominent ? 46 : 42,
      height: prominent ? 46 : 42,
      decoration: BoxDecoration(
        color: isHovered
            ? accentColor.withValues(alpha: 0.2)
            : colorScheme.surfaceBright.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(prominent ? 18 : 16),
        border: Border.all(
          color: isHovered
              ? accentColor.withValues(alpha: 0.32)
              : colorScheme.outlineVariant.withValues(alpha: 0.54),
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 20,
        color: isHovered ? accentColor : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
