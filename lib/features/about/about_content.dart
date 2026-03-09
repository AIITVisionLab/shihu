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

/// 系统能力卡片数据。
class AboutCapabilityItem {
  /// 创建系统能力卡片数据。
  const AboutCapabilityItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  /// 图标。
  final IconData icon;

  /// 标题。
  final String title;

  /// 说明。
  final String description;
}

/// 栽培背景风险卡片数据。
class AboutRiskItem {
  /// 创建风险卡片数据。
  const AboutRiskItem({
    required this.title,
    required this.description,
    required this.tag,
  });

  /// 风险标题。
  final String title;

  /// 风险说明。
  final String description;

  /// 风险标签。
  final String tag;
}

/// 调控目标条目数据。
class AboutGoalMetric {
  /// 创建调控目标条目数据。
  const AboutGoalMetric({
    required this.label,
    required this.target,
    required this.note,
    required this.progress,
  });

  /// 指标名称。
  final String label;

  /// 目标值。
  final String target;

  /// 说明。
  final String note;

  /// 视觉强调值。
  final double progress;
}

/// 闭环步骤数据。
class AboutFlowStep {
  /// 创建闭环步骤数据。
  const AboutFlowStep({
    required this.index,
    required this.title,
    required this.description,
  });

  /// 步骤序号。
  final String index;

  /// 步骤标题。
  final String title;

  /// 步骤说明。
  final String description;
}

/// 系统总览页静态内容集合。
final class AboutContent {
  /// 顶部主标题。
  static const String heroTitle = '让培育现场从经验操作走向可视闭环';

  /// 顶部主说明。
  static const String heroDescription =
      '斛生围绕环境采集、风险判断、远程执行和运行回写组织统一工作流，让日常值守、排障和调控不再依赖分散页面和口头经验。';

  /// 顶部补充说明。
  static const String heroFootnote = '当前主功能只开放已接入服务的真实链路，保证进入页面即可直接使用。';

  /// 栽培背景段落。
  static const String researchIntro =
      '石斛幼苗阶段对温度、湿度、光照和空气状态的波动十分敏感。真正影响成活率的往往不是某一次极端值，而是连续几天的轻微偏离与处置滞后。';

  /// 栽培背景补充段落。
  static const String researchSummary =
      '因此软件重点不是堆叠展示页，而是把采集、判断、执行和回写放进同一个稳定工作台里，让值守人员在一次进入中完成查看、判断与处理。';

  /// 调控目标补充说明。
  static const String targetSummary =
      '所有页面都围绕“看得见、判得出、能执行、可回看”展开，保证系统从说明层到主控层保持一致的业务语义。';

  /// 顶部亮点卡片。
  static const List<AboutHeroStat> heroStats = <AboutHeroStat>[
    AboutHeroStat(
      value: '4 项',
      label: '环境指标',
      description: '温度、湿度、光照与 MQ2 持续采集并统一呈现。',
    ),
    AboutHeroStat(
      value: '1 条',
      label: '执行链路',
      description: '补光控制提交后继续刷新等待状态回写。',
    ),
    AboutHeroStat(
      value: '24h',
      label: '值守目标',
      description: '围绕巡检、值守与排障形成连续工作闭环。',
    ),
  ];

  /// 系统能力条目。
  static const List<AboutCapabilityItem> capabilities = <AboutCapabilityItem>[
    AboutCapabilityItem(
      icon: Icons.lock_outline_rounded,
      title: '统一认证',
      description: '账号登录、在线注册、会话恢复和退出统一收口，不再拆散到多个入口。',
    ),
    AboutCapabilityItem(
      icon: Icons.monitor_heart_outlined,
      title: '环境监测',
      description: '设备名称、温湿度、光照、MQ2 与运行状态在同一视图内持续更新。',
    ),
    AboutCapabilityItem(
      icon: Icons.warning_amber_rounded,
      title: '风险预警',
      description: '异常码统一映射成运行等级和说明，帮助值守人员快速判断影响范围。',
    ),
    AboutCapabilityItem(
      icon: Icons.toggle_on_outlined,
      title: '远程执行',
      description: '补光指令提交后保留反馈与回写等待状态，避免出现“点了没反应”的误判。',
    ),
  ];

  /// 栽培背景风险条目。
  static const List<AboutRiskItem> risks = <AboutRiskItem>[
    AboutRiskItem(
      title: '闷热高湿',
      description: '持续高湿且通风不足时，幼苗容易出现软腐、根系压力增大和局部烂苗。',
      tag: '需优先预警',
    ),
    AboutRiskItem(
      title: '补光波动',
      description: '光照不足或补光节律不稳定会拖慢生长节奏，影响叶色和新芽状态。',
      tag: '需稳定节律',
    ),
    AboutRiskItem(
      title: '气体异常',
      description: '封闭环境下的气体累积会放大生理压力，异常往往先体现在整体状态而不是单株症状。',
      tag: '需持续监测',
    ),
  ];

  /// 调控目标条目。
  static const List<AboutGoalMetric> goalMetrics = <AboutGoalMetric>[
    AboutGoalMetric(
      label: '温度',
      target: '23°C - 27°C',
      note: '保持稳定区间，降低连续波动带来的应激。',
      progress: 0.72,
    ),
    AboutGoalMetric(
      label: '湿度',
      target: '75% - 85%',
      note: '兼顾保湿和通风，避免长时间闷湿。',
      progress: 0.82,
    ),
    AboutGoalMetric(
      label: '光照',
      target: '1200 - 1800 lx',
      note: '围绕稳定补光组织执行策略和巡检频率。',
      progress: 0.66,
    ),
    AboutGoalMetric(
      label: 'MQ2',
      target: '≤ 20',
      note: '异常抬升时尽快排查环境与设备状态。',
      progress: 0.58,
    ),
  ];

  /// 闭环步骤。
  static const List<AboutFlowStep> flowSteps = <AboutFlowStep>[
    AboutFlowStep(
      index: '01',
      title: '采集',
      description: '实时读取设备状态，统一承接环境数据和执行器状态。',
    ),
    AboutFlowStep(
      index: '02',
      title: '判断',
      description: '把异常码、更新时间和设备身份映射为可读的运行状态。',
    ),
    AboutFlowStep(
      index: '03',
      title: '执行',
      description: '在明确设备身份后提交补光操作，并阻断重复高风险操作。',
    ),
    AboutFlowStep(
      index: '04',
      title: '回写',
      description: '继续刷新最新状态，确保界面展示和现场设备保持一致。',
    ),
  ];
}
