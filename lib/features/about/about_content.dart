import 'package:flutter/material.dart';

/// 系统总览页头部亮点数据。
class AboutHeroStat {
  /// 创建亮点数据。
  const AboutHeroStat({
    required this.value,
    required this.label,
    required this.description,
  });

  /// 重点数值。
  final String value;

  /// 条目名称。
  final String label;

  /// 条目说明。
  final String description;
}

/// 主路径轨道条目。
class AboutWorkflowTrack {
  /// 创建主路径轨道条目。
  const AboutWorkflowTrack({
    required this.icon,
    required this.step,
    required this.title,
    required this.summary,
    required this.entryHint,
    required this.focusHint,
    required this.actionHint,
  });

  /// 图标。
  final IconData icon;

  /// 步骤序号。
  final String step;

  /// 路径名称。
  final String title;

  /// 一句话总结。
  final String summary;

  /// 什么时候进入。
  final String entryHint;

  /// 重点看什么。
  final String focusHint;

  /// 进去后做什么。
  final String actionHint;
}

/// 后端协作说明条目。
class AboutCollaborationTopic {
  /// 创建协作说明条目。
  const AboutCollaborationTopic({
    required this.icon,
    required this.badge,
    required this.title,
    required this.summary,
    required this.interfaceValue,
    required this.frontendAction,
    required this.boundary,
  });

  /// 图标。
  final IconData icon;

  /// 顶部标签。
  final String badge;

  /// 标题。
  final String title;

  /// 一句话说明。
  final String summary;

  /// 最小接口或关键字段。
  final String interfaceValue;

  /// 前端侧动作。
  final String frontendAction;

  /// 关键边界。
  final String boundary;
}

/// 页面底部范围说明条目。
class AboutScopeRule {
  /// 创建范围说明条目。
  const AboutScopeRule({required this.title, required this.description});

  /// 标题。
  final String title;

  /// 说明。
  final String description;
}

/// 系统总览页静态内容集合。
final class AboutContent {
  /// 顶部主标题。
  static const String heroTitle = '三条主路径，两类协作边界，一页看清';

  /// 顶部主说明。
  static const String heroDescription =
      '你平时只要按“总览 -> 值守 -> 我的”走。先看状态，再决定是否处理，页面不会把没接通的能力塞进主流程里。';

  /// 顶部补充说明。
  static const String heroFootnote =
      '视频协作和 AI 协作会在说明页里讲清楚接入边界，但当前版本不额外放视频页或 AI 页，避免用户看到空壳入口。';

  /// 协作区总说明。
  static const String collaborationSummary =
      '以下内容根据 `doc/java-video-collaboration.md` 和 `doc/java-ai-collaboration.md` 提炼，只说明后续怎么接，不代表当前前端已经内置这些页面。';

  /// 顶部亮点卡片。
  static const List<AboutHeroStat> heroStats = <AboutHeroStat>[
    AboutHeroStat(
      value: '3 条',
      label: '主路径',
      description: '总览、值守、我的。日常操作只沿这三条路径走。',
    ),
    AboutHeroStat(
      value: '2 类',
      label: '协作边界',
      description: '视频协作、AI 协作只讲接法，不做当前入口。',
    ),
    AboutHeroStat(
      value: '1 个',
      label: '核心原则',
      description: '先看状态，再决定是否处理，减少误操作和无效跳转。',
    ),
  ];

  /// 主路径轨道条目。
  static const List<AboutWorkflowTrack> workflowTracks = <AboutWorkflowTrack>[
    AboutWorkflowTrack(
      icon: Icons.dashboard_rounded,
      step: '01',
      title: '总览',
      summary: '每次进入系统先看这里，先确认设备有没有在线、数据是不是刚更新。',
      entryHint: '刚登录或刚返回工作台时先进入。',
      focusHint: '设备状态、最近同步时间、三个一级入口。',
      actionHint: '正常就继续去值守；异常再决定是否需要人工处理。',
    ),
    AboutWorkflowTrack(
      icon: Icons.monitor_heart_rounded,
      step: '02',
      title: '值守',
      summary: '需要判断当前环境或处理补光时再进入，不把所有操作堆在首页。',
      entryHint: '要看实时指标、错误码或切换 LED 时进入。',
      focusHint: '主状态、温湿度/光照/MQ2、运行明细、LED 控制。',
      actionHint: '先看异常等级，再处理补光，最后等待状态回写确认。',
    ),
    AboutWorkflowTrack(
      icon: Icons.settings_rounded,
      step: '03',
      title: '我的',
      summary: '把账号、设备信息和本机偏好收在一起，不混进实时操作链路。',
      entryHint: '改账号、看当前设备或恢复默认设置时进入。',
      focusHint: '当前账号、当前设备、记住账号和本机偏好。',
      actionHint: '在这里做管理类动作，不在这里做实时值守处置。',
    ),
  ];

  /// 后端协作说明条目。
  static const List<AboutCollaborationTopic>
  collaborationTopics = <AboutCollaborationTopic>[
    AboutCollaborationTopic(
      icon: Icons.videocam_outlined,
      badge: '视频协作',
      title: 'Java 后端只负责告诉前端去哪里播放',
      summary: '最小接口是查询视频流信息，前端拿到 `playerUrl` 后直接访问公网 go2rtc/frp 播放地址。',
      interfaceValue:
          'GET /api/video/streams 或 GET /api/video/streams/{streamId}',
      frontendAction: '读取 `playerUrl` 后直接播放，不让 Java 业务服务代理 WebRTC 媒体流。',
      boundary: '不要让 Java 代理 8555 端口；不要把 K230 的内网 RTSP 地址直接暴露给前端。',
    ),
    AboutCollaborationTopic(
      icon: Icons.memory_rounded,
      badge: 'AI 协作',
      title: 'Java 后端先接结果，再决定怎么给前端展示',
      summary:
          'RK3568 已能接收 K230 的 AI 结果，但只有 `ai_forward.enabled=true` 且 `detections` 非空时，才会继续上送到 Java。',
      interfaceValue: 'POST /api/edge/ai-detections',
      frontendAction: '当前前端不直接拉 AI JSON。若后端要展示 AI 结果，应先接收、存储，再定义自己的查询或推送接口。',
      boundary: '默认建议关闭 AI 转发；前端这一轮不新增 AI 查询页，也不直接对接 RK3568 内存态结果。',
    ),
  ];

  /// 范围说明条目。
  static const List<AboutScopeRule> scopeRules = <AboutScopeRule>[
    AboutScopeRule(
      title: '当前可用',
      description: '只保留总览、值守、我的三条主路径，不新增视频页和 AI 页。',
    ),
    AboutScopeRule(
      title: '视频接入',
      description: 'Java 后端返回 `playerUrl`，前端直接播，媒体流不走 Java 代理。',
    ),
    AboutScopeRule(
      title: 'AI 接入',
      description: 'RK3568 先把非空检测结果上送 Java，再由 Java 定义前端可读接口。',
    ),
  ];
}
