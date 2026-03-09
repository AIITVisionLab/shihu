import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';

/// 关于页，映射后端 `preview.html` 的公开预览页结构。
class AboutPage extends ConsumerWidget {
  /// 创建关于页。
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF06101D),
              Color(0xFF091728),
              Color(0xFF0C1E35),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _PreviewBackground()),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: <Widget>[
                      _PreviewTopBar(
                        isAuthenticated: authState.isAuthenticated,
                        currentUser: currentUser,
                      ),
                      const SizedBox(height: 20),
                      _PreviewHero(isAuthenticated: authState.isAuthenticated),
                      const SizedBox(height: 24),
                      const _PreviewSection(
                        title: '第一部分｜平台与设备能力介绍',
                        description: '页面结构对齐后端预览页，重点展示平台定位、业务能力、硬件控制与后续可扩展方向。',
                        child: _PlatformSection(),
                      ),
                      const SizedBox(height: 24),
                      const _PreviewSection(
                        title: '第二部分｜石斛幼苗易病死的研究背景',
                        description:
                            '保留后端预览页里的科研与工程叙事，说明为什么系统要围绕环境调控、风险预警和设备联动来设计。',
                        child: _ResearchSection(),
                      ),
                      const SizedBox(height: 24),
                      const _PreviewSection(
                        title: '第三部分｜成活率与调控目标',
                        description: '通过目标值、参考值和当前系统关注指标的对比，强调平台的监测价值与控制闭环。',
                        child: _SurvivalSection(),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '石斛项目公开预览页 · Flutter 前端已按 `origin/web` 的展示结构同步收口',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF9EB1CA)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBackground extends StatelessWidget {
  const _PreviewBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: CustomPaint(painter: _PreviewGridPainter())),
        Positioned(
          left: -30,
          top: 40,
          child: _PreviewGlow(size: 300, color: const Color(0x2657D8FF)),
        ),
        Positioned(
          right: -20,
          top: 80,
          child: _PreviewGlow(size: 260, color: const Color(0x226D7CFF)),
        ),
      ],
    );
  }
}

class _PreviewGlow extends StatelessWidget {
  const _PreviewGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color, blurRadius: 100, spreadRadius: 20),
          ],
        ),
      ),
    );
  }
}

class _PreviewGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar({
    required this.isAuthenticated,
    required this.currentUser,
  });

  final bool isAuthenticated;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF57D8FF), Color(0xFF6D7CFF)],
              ),
            ),
            child: const Center(
              child: Text(
                '斛',
                style: TextStyle(
                  color: Color(0xFF05111B),
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dendrobium Seedling Smart Cultivation Platform',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9EB1CA),
                  ),
                ),
              ],
            ),
          ),
          if (isAuthenticated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                '当前用户：$currentUser',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => context.goNamed(
              isAuthenticated ? AppRoutes.home : AppRoutes.login,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF57D8FF),
              foregroundColor: const Color(0xFF06101D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(isAuthenticated ? '进入平台' : '登录入口'),
          ),
        ],
      ),
    );
  }
}

class _PreviewHero extends StatelessWidget {
  const _PreviewHero({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 980;
        final left = _HeroLead(isAuthenticated: isAuthenticated);
        const right = _HeroMetrics();

        if (isCompact) {
          return Column(
            children: <Widget>[left, const SizedBox(height: 18), right],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 12, child: left),
            SizedBox(width: 18),
            Expanded(flex: 9, child: right),
          ],
        );
      },
    );
  }
}

class _HeroLead extends StatelessWidget {
  const _HeroLead({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x1F57D8FF),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x3657D8FF)),
            ),
            child: Text(
              '面向石斛组培苗 / 练苗 / 初期培育场景的智能化平台',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFC8F4FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '以数据驱动石斛育苗，让环境调控更精准，让成活率更稳定。',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '本平台聚焦石斛幼苗培养设备的数字化管理，围绕温度、湿度、光照、气体传感、病害风险与执行器联动，构建“现场设备层 - 边缘控制层 - 网关层 - 云端应用层”的一体化管理体系。',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFD6E2F2),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _LeadPoint(
                title: '多平台可用',
                description: '支持 PC、大屏、平板与移动端浏览，适合作为实验室展示页、系统入口页与联调预览页。',
              ),
              _LeadPoint(
                title: '智能控制闭环',
                description: '从传感器采集、边缘控制、网关上云到后端规则判断，形成完整的监测与控制闭环。',
              ),
              _LeadPoint(
                title: '科研与工程结合',
                description: '将石斛栽培文献、标准化规程与设备管理能力融合展示，兼顾学术说明与工程落地。',
              ),
              _LeadPoint(
                title: '可追溯、可扩展',
                description: '为后续历史数据、告警记录、识别结果与设备留痕预留稳定的页面和模型结构。',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed: () => context.goNamed(
                  isAuthenticated ? AppRoutes.home : AppRoutes.login,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF57D8FF),
                  foregroundColor: const Color(0xFF06101D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(isAuthenticated ? '进入系统' : '登录入口'),
              ),
              OutlinedButton(
                onPressed: () => context.pushNamed(AppRoutes.about),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('查看预览说明'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadPoint extends StatelessWidget {
  const _LeadPoint({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF9EB1CA),
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetrics extends StatelessWidget {
  const _HeroMetrics();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          _MetricTile(
            label: '系统目标',
            value: '环境稳定',
            description: '围绕温度、湿度、光照和执行器联动建立稳定培育空间。',
          ),
          SizedBox(height: 14),
          _MetricTile(
            label: '文献最佳参考',
            value: '95%',
            description: '以优质文献中的高成活率区间作为平台长期控制目标。',
          ),
          SizedBox(height: 14),
          _MetricTile(
            label: '文献低值参考',
            value: '54%',
            description: '将低成活率情况作为高风险样本，用于反向约束环境控制策略。',
          ),
          SizedBox(height: 14),
          _MetricTile(
            label: '核心感知项',
            value: '4 项',
            description: '温度、湿度、光照和 MQ2 浓度已在当前前端主链路中完成建模。',
          ),
          SizedBox(height: 18),
          _SystemCard(),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.description,
  });

  final String label;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF9EB1CA)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFBFD0E6),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            '系统架构概览',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '页面继续保留后端预览页的系统架构叙事，方便联调时同时核对业务定位和真实接口边界。',
            style: TextStyle(color: Color(0xFF9EB1CA), height: 1.8),
          ),
          SizedBox(height: 16),
          _FlowItem(label: '现场设备层', value: '传感器采集温湿度、光照与气体数据'),
          SizedBox(height: 10),
          _FlowItem(label: '边缘控制层', value: '依据阈值和控制策略驱动执行器'),
          SizedBox(height: 10),
          _FlowItem(
            label: '网关与后端',
            value: '聚合 OneNET、Pulsar 与 Spring Boot 会话接口',
          ),
          SizedBox(height: 10),
          _FlowItem(label: 'Flutter 多端前台', value: '统一展示预览、认证、设备主控台与运维入口'),
        ],
      ),
    );
  }
}

class _FlowItem extends StatelessWidget {
  const _FlowItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF57D8FF), Color(0xFF6D7CFF)],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF9EB1CA)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF9EB1CA),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _PlatformSection extends StatelessWidget {
  const _PlatformSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: <Widget>[
            _PreviewFeatureCard(
              icon: Icons.dashboard_customize_outlined,
              title: '管理界面能力',
              description:
                  '预览页、登录页、实时主控台与设置页已经围绕后端 `preview / login / index` 结构重新收口。',
            ),
            _PreviewFeatureCard(
              icon: Icons.hub_outlined,
              title: '平台业务能力',
              description: '当前真实链路覆盖登录注册、会话恢复、设备状态轮询、LED 控制与健康检查。',
            ),
            _PreviewFeatureCard(
              icon: Icons.settings_input_component_outlined,
              title: '硬件控制能力',
              description: '四项环境指标、错误码等级和 LED 控制结果已与后端 DTO 字段逐项对齐。',
            ),
          ],
        ),
        SizedBox(height: 18),
        _DualNarrative(),
      ],
    );
  }
}

class _PreviewFeatureCard extends StatelessWidget {
  const _PreviewFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0x3357D8FF), Color(0x336D7CFF)],
                ),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF9EB1CA),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DualNarrative extends StatelessWidget {
  const _DualNarrative();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final cards = <Widget>[
          const _NarrativeCard(
            title: '后台管理界面展示重点',
            items: <String>[
              '对齐后端真实页面里的设备状态主控台结构，强调会话、状态轮询与异常等级。',
              '把登录页和预览页的视觉语义前移到 Flutter，多端联调时不再只剩功能壳。',
              '保留识别、历史和设置入口，作为 Flutter 相对静态 HTML 的扩展能力。',
            ],
          ),
          const _NarrativeCard(
            title: '硬件设备组成展示重点',
            items: <String>[
              '当前前端已经围绕温度、湿度、光照和 MQ2 构建统一指标卡片与状态映射。',
              '错误码 `0 / 1 / 2` 对应安全、警告、严重告警，未知值保持保守展示。',
              'LED 控制前置条件现在按后端约束执行，缺少 deviceId 时直接禁用。',
            ],
          ),
        ];

        if (isCompact) {
          return Column(children: cards);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: cards[0]),
            const SizedBox(width: 18),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFDCE9FA),
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResearchSection extends StatelessWidget {
  const _ResearchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        _NarrativeCard(
          title: '为什么石斛幼苗容易出问题',
          items: <String>[
            '石斛幼苗对温湿度、光照和基质环境高度敏感，短时间波动就可能造成缓苗失败。',
            '高温高湿、通风不足和病菌滋生是常见风险，传统人工巡检难以及时感知趋势变化。',
          ],
        ),
        SizedBox(height: 18),
        _NarrativeCard(
          title: '为什么需要智能培育管理平台',
          items: <String>[
            '平台通过持续采集、阈值判断、状态映射和远程控制，把“环境失控”尽量提前暴露为可视化预警。',
            '在工程侧通过后端缓存设备状态，在前端统一展示，有利于答辩演示、实验室部署和跨端运维。',
          ],
        ),
        SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: <Widget>[
            _PaperCard(
              title: '石斛组培苗移栽成活率与环境控制研究',
              meta: '文献方向：组培苗驯化 / 环境管理',
              description: '用于说明高湿、弱光、缓苗与逐步通风控制对前期成活率的影响，为当前平台的环境监测指标提供背景。',
            ),
            _PaperCard(
              title: '石斛幼苗早期培育中的病害与应激因素',
              meta: '文献方向：病害防治 / 预警线索',
              description: '强调高温高湿、空气流动不足等条件对病原滋生的促进作用，支撑当前页面里的异常等级设计。',
            ),
            _PaperCard(
              title: '智能温室与物联网培育系统的应用启示',
              meta: '文献方向：IoT 控制 / 数据闭环',
              description:
                  '从工程实现角度说明传感采集、边缘执行与云端展示的价值，为 OneNET + Flutter 前后端联调提供参考。',
            ),
          ],
        ),
      ],
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.title,
    required this.meta,
    required this.description,
  });

  final String title;
  final String meta;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meta,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF9EB1CA)),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFD4E3F7),
                height: 1.85,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurvivalSection extends StatelessWidget {
  const _SurvivalSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '成活率综合展示',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        const _BarRow(
          label: '低参考值',
          valueLabel: '54%',
          widthFactor: 0.54,
          color: Color(0xFFFF6B6B),
        ),
        const SizedBox(height: 14),
        const _BarRow(
          label: '当前系统目标',
          valueLabel: '80%',
          widthFactor: 0.80,
          color: Color(0xFF57D8FF),
        ),
        const SizedBox(height: 14),
        const _BarRow(
          label: '文献最佳参考',
          valueLabel: '95%',
          widthFactor: 0.95,
          color: Color(0xFF2BD576),
        ),
        const SizedBox(height: 18),
        Text(
          '当前 Flutter 前端保留该展示区块，用于说明平台为什么要优先联通设备状态、风险等级和执行器控制，而不是只停留在界面壳层。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9EB1CA),
            height: 1.8,
          ),
        ),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    required this.label,
    required this.valueLabel,
    required this.widthFactor,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: <Widget>[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD9E7F9),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 54,
              child: Text(
                valueLabel,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
