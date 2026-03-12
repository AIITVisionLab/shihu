import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';

/// 系统总览页头部主展示区。
class AboutHeroSection extends StatelessWidget {
  /// 创建主展示区。
  const AboutHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainer.withValues(alpha: 0.98),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.98),
            colorScheme.primaryContainer.withValues(alpha: 0.68),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.95),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x5A020914),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -36,
            top: -46,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 72,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 980;
              final lead = _HeroLead(theme: theme);
              final stats = _HeroStats(theme: theme);

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[lead, const SizedBox(height: 22), stats],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 11, child: lead),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: stats),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroLead extends StatelessWidget {
  const _HeroLead({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.9),
            ),
          ),
          child: Text(
            '工作说明',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AboutContent.scopeRules
              .map((item) => _HeroPill(label: item.title))
              .toList(growable: false),
        ),
        const SizedBox(height: 22),
        Text(
          AboutContent.heroTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AboutContent.heroDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.64,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.78),
            ),
          ),
          child: Text(
            AboutContent.heroFootnote,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.66,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AboutContent.heroStats
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == AboutContent.heroStats.last ? 0 : 12,
              ),
              child: _HeroStatCard(item: item, theme: theme),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({required this.item, required this.theme});

  final AboutHeroStat item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
