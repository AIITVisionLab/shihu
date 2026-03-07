import 'package:flutter/material.dart';

/// 通用加载视图，可用于全页或局部加载状态。
class LoadingView extends StatelessWidget {
  /// 创建加载视图。
  const LoadingView({this.message = '加载中...', super.key});

  /// 加载提示文案。
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
