import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';

/// 系统总览页头部主展示区。
class AboutHeroSection extends StatelessWidget {
  /// 创建主展示区。
  const AboutHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0F4A45),
            Color(0xFF1F857B),
            Color(0xFFB18156),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x18172019),
            blurRadius: 36,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 960;
          final lead = _HeroLead(theme: theme);
          final stats = _HeroStats(theme: theme);

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[lead, const SizedBox(height: 24), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 10, child: lead),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroLead extends StatelessWidget {
  const _HeroLead({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const <Widget>[
            _HeroPill(label: '设备监测'),
            _HeroPill(label: '风险预警'),
            _HeroPill(label: '远程调控'),
            _HeroPill(label: '运维自检'),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          AboutContent.heroTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AboutContent.heroDescription,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF0F7F4),
            height: 1.66,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AboutContent.heroFootnote,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFDAECE6),
            height: 1.68,
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
          .toList(),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({required this.item, required this.theme});

  final AboutHeroStat item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFF3FAF6),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFDBECE5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
