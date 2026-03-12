import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/widgets/app_backdrop.dart';

/// 认证入口页通用壳层，统一背景、页头和响应式布局。
class AuthEntryShell extends StatelessWidget {
  /// 创建认证入口页壳层。
  const AuthEntryShell({
    required this.formPanel,
    this.overviewPanel,
    this.onBackPressed,
    super.key,
  });

  /// 辅助说明面板。
  final Widget? overviewPanel;

  /// 表单面板。
  final Widget formPanel;

  /// 返回系统总览回调。
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050C15),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: AppBackdrop(
              baseGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF050C15),
                  Color(0xFF09121F),
                  Color(0xFF060D17),
                ],
              ),
              orbs: <BackdropOrbData>[
                BackdropOrbData(
                  alignment: Alignment(-1.0, -0.92),
                  size: 260,
                  color: Color(0x124B9BFF),
                ),
                BackdropOrbData(
                  alignment: Alignment(1.02, -0.08),
                  size: 220,
                  color: Color(0x1045D0FF),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  children: <Widget>[
                    _AuthEntryHeader(onBackPressed: onBackPressed),
                    const SizedBox(height: 28),
                    _AuthWorkspaceFrame(
                      formPanel: formPanel,
                      overviewPanel: overviewPanel,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthWorkspaceFrame extends StatelessWidget {
  const _AuthWorkspaceFrame({
    required this.formPanel,
    required this.overviewPanel,
  });

  final Widget formPanel;
  final Widget? overviewPanel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelMaxWidth = constraints.maxWidth >= 760
            ? 468.0
            : double.infinity;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: panelMaxWidth),
            child: Column(
              children: <Widget>[
                _FormStage(
                  isCompact: constraints.maxWidth < 760,
                  child: formPanel,
                ),
                if (overviewPanel != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _OverviewStage(
                    isCompact: constraints.maxWidth < 760,
                    child: overviewPanel!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewStage extends StatelessWidget {
  const _OverviewStage({required this.child, this.isCompact = false});

  final Widget child;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xD90D1724),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x22314B68)),
      ),
      child: child,
    );
  }
}

class _FormStage extends StatelessWidget {
  const _FormStage({required this.child, this.isCompact = false});

  final Widget child;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xF30B1623), Color(0xF708101A)],
        ),
        border: Border.all(color: const Color(0x22314B68)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x54000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AuthEntryHeader extends StatelessWidget {
  const _AuthEntryHeader({required this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final brand = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF69B4FF), Color(0xFF1A61C9)],
            ),
          ),
          child: const Icon(Icons.spa_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppConstants.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '登录后继续使用工作台',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA1B0B9),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final action = onBackPressed == null
        ? null
        : OutlinedButton.icon(
            onPressed: onBackPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0x22FFFFFF)),
              backgroundColor: const Color(0x10FFFFFF),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('返回'),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x120C1825),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x22314B68)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                brand,
                if (action != null) ...<Widget>[
                  const SizedBox(height: 14),
                  action,
                ],
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: brand),
              ?action,
            ],
          );
        },
      ),
    );
  }
}
