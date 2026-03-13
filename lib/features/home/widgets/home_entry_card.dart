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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surfaceBright.withValues(alpha: 0.99),
                colorScheme.surfaceContainerLow.withValues(alpha: 0.97),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary.withValues(alpha: 0.34)
                  : colorScheme.outlineVariant.withValues(alpha: 0.66),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color:
                    (_isHovered
                            ? AppPalette.pineGreen
                            : const Color(0xFF101713))
                        .withValues(alpha: _isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 24 : 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 420;
                  final content = _EntryContent(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    stepLabel: widget.stepLabel,
                    icon: widget.icon,
                    isHovered: _isHovered,
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        content,
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _EntryArrow(isHovered: _isHovered),
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: content),
                      const SizedBox(width: 14),
                      _EntryArrow(isHovered: _isHovered),
                    ],
                  );
                },
              ),
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
  });

  final String title;
  final String subtitle;
  final String? stepLabel;
  final IconData icon;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(
              alpha: isHovered ? 0.92 : 0.82,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
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
                    color: AppPalette.fogMint.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    stepLabel!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
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
            ],
          ),
        ),
      ],
    );
  }
}

class _EntryArrow extends StatelessWidget {
  const _EntryArrow({required this.isHovered});

  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isHovered
            ? colorScheme.primaryContainer.withValues(alpha: 0.88)
            : colorScheme.surfaceBright.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.54),
        ),
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 20,
        color: isHovered
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
