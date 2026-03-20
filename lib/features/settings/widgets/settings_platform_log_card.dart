import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/platform_logs/application/platform_log_providers.dart';
import 'package:sickandflutter/features/platform_logs/domain/platform_log_entry.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

const List<int> _logLimitOptions = <int>[6, 20, 50, 100];
const List<String> _defaultTypeOptions = <String>[
  'ONENET_UPLINK',
  'ONENET_COMMAND',
  'ONENET_SET_REPLY',
  'AI_DETECTION',
];

/// 设置页平台日志卡片。
class SettingsPlatformLogCard extends ConsumerStatefulWidget {
  /// 创建平台日志卡片。
  const SettingsPlatformLogCard({
    required this.overviewAsync,
    required this.onRefresh,
    super.key,
  });

  /// 平台日志异步状态。
  final AsyncValue<PlatformLogOverview> overviewAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  ConsumerState<SettingsPlatformLogCard> createState() =>
      _SettingsPlatformLogCardState();
}

class _SettingsPlatformLogCardState
    extends ConsumerState<SettingsPlatformLogCard> {
  late final TextEditingController _keywordController;
  late PlatformLogQuery _lastSyncedQuery;
  late String _selectedType;
  late int _selectedLimit;

  @override
  void initState() {
    super.initState();
    final query = ref.read(platformLogQueryProvider);
    _lastSyncedQuery = query;
    _keywordController = TextEditingController(text: query.normalizedKeyword);
    _selectedType = query.normalizedType;
    _selectedLimit = query.limit;
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(platformLogQueryProvider);
    _syncDraftFromQuery(query);

    final supportedTypes =
        widget.overviewAsync.asData?.value.summary.supportedTypes ??
        const <String>[];

    return CommonCard(
      title: '平台日志',
      subtitle: '查看后端近期接收到的设备上报、下发回写和 AI 事件。',
      accentColor: AppPalette.softLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FilterPanel(
            keywordController: _keywordController,
            selectedType: _selectedType,
            selectedLimit: _selectedLimit,
            typeOptions: _resolveTypeOptions(supportedTypes),
            hasActiveFilters:
                query.hasFilter || query.limit != PlatformLogQuery.defaultLimit,
            onTypeChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
            onLimitChanged: (value) {
              setState(() {
                _selectedLimit = value;
              });
            },
            onApply: _applyFilters,
            onReset: _resetFilters,
          ),
          const SizedBox(height: 16),
          widget.overviewAsync.when(
            loading: () => Row(
              children: <Widget>[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '正在加载平台日志...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            error: (error, stackTrace) => _StateBlock(
              message: '平台日志加载失败：$error',
              onRefresh: widget.onRefresh,
            ),
            data: (overview) => _LogPanel(
              overview: overview,
              query: query,
              onRefresh: widget.onRefresh,
            ),
          ),
        ],
      ),
    );
  }

  void _syncDraftFromQuery(PlatformLogQuery query) {
    if (_lastSyncedQuery == query) {
      return;
    }

    final normalizedKeyword = query.normalizedKeyword;
    if (_keywordController.text != normalizedKeyword) {
      _keywordController.value = TextEditingValue(
        text: normalizedKeyword,
        selection: TextSelection.collapsed(offset: normalizedKeyword.length),
      );
    }
    _selectedType = query.normalizedType;
    _selectedLimit = query.limit;
    _lastSyncedQuery = query;
  }

  List<String> _resolveTypeOptions(List<String> supportedTypes) {
    final seen = <String>{};
    final orderedValues = <String>[
      ..._defaultTypeOptions,
      ...supportedTypes,
      if (_selectedType.isNotEmpty) _selectedType,
    ];

    return orderedValues
        .map((value) => value.trim().toUpperCase())
        .where((value) => value.isNotEmpty && seen.add(value))
        .toList(growable: false);
  }

  void _applyFilters() {
    final query = PlatformLogQuery(
      keyword: _keywordController.text,
      type: _selectedType,
      limit: _selectedLimit,
    );
    FocusScope.of(context).unfocus();
    _lastSyncedQuery = query;
    ref.read(platformLogQueryProvider.notifier).updateQuery(query);
  }

  void _resetFilters() {
    setState(() {
      _keywordController.clear();
      _selectedType = '';
      _selectedLimit = PlatformLogQuery.defaultLimit;
    });
    FocusScope.of(context).unfocus();
    _lastSyncedQuery = const PlatformLogQuery();
    ref.read(platformLogQueryProvider.notifier).reset();
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.keywordController,
    required this.selectedType,
    required this.selectedLimit,
    required this.typeOptions,
    required this.hasActiveFilters,
    required this.onTypeChanged,
    required this.onLimitChanged,
    required this.onApply,
    required this.onReset,
  });

  final TextEditingController keywordController;
  final String selectedType;
  final int selectedLimit;
  final List<String> typeOptions;
  final bool hasActiveFilters;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<int> onLimitChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '筛选条件',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '按关键字、事件类型和条数范围重新查询，直接复用后端 `/api/logs` 的筛选能力。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 760;
              final keywordField = TextField(
                controller: keywordController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => onApply(),
                decoration: const InputDecoration(
                  labelText: '关键字',
                  hintText: '设备 ID、摘要或详情字段',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              );
              final typeField = DropdownButtonFormField<String>(
                key: ValueKey<String>('platform-log-type:$selectedType'),
                initialValue: selectedType,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: '事件类型',
                  prefixIcon: Icon(Icons.tune_rounded),
                ),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('全部类型'),
                  ),
                  ...typeOptions.map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(_typeLabel(value)),
                    ),
                  ),
                ],
                onChanged: (value) => onTypeChanged(value ?? ''),
              );
              final limitField = DropdownButtonFormField<int>(
                key: ValueKey<String>('platform-log-limit:$selectedLimit'),
                initialValue: selectedLimit,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: '展示条数',
                  prefixIcon: Icon(Icons.format_list_numbered_rounded),
                ),
                items: _logLimitOptions
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value 条'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value != null) {
                    onLimitChanged(value);
                  }
                },
              );

              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    keywordField,
                    const SizedBox(height: 12),
                    typeField,
                    const SizedBox(height: 12),
                    limitField,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 7, child: keywordField),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: typeField),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: limitField),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final applyButton = FilledButton.tonalIcon(
                onPressed: onApply,
                icon: const Icon(Icons.filter_alt_rounded),
                label: const Text('查询日志'),
              );
              final resetButton = OutlinedButton.icon(
                onPressed: hasActiveFilters ? onReset : null,
                icon: const Icon(Icons.layers_clear_rounded),
                label: const Text('恢复全部'),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: double.infinity, child: applyButton),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: resetButton),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  applyButton,
                  const SizedBox(width: 10),
                  resetButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StateBlock extends StatelessWidget {
  const _StateBlock({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.error,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        CommonButton(
          label: '重新获取',
          tone: CommonButtonTone.secondary,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _LogPanel extends StatelessWidget {
  const _LogPanel({
    required this.overview,
    required this.query,
    required this.onRefresh,
  });

  final PlatformLogOverview overview;
  final PlatformLogQuery query;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final summary = overview.summary;
    final recentEntries = overview.recentEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 540 ? 2 : 1;
            final itemWidth =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                SizedBox(
                  width: itemWidth,
                  child: SettingsSettingRow(
                    title: '累计事件',
                    value: '${summary.count} 条',
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SettingsSettingRow(
                    title: '事件类型',
                    value: summary.supportedTypes.isEmpty
                        ? '--'
                        : summary.supportedTypes.map(_typeLabel).join(' / '),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SettingsSettingRow(
                    title: '日志文件',
                    value: summary.file.trim().isEmpty
                        ? '--'
                        : summary.file.trim(),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SettingsSettingRow(
                    title: '当前查询',
                    value: _queryLabel(query),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          '最近事件',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        if (recentEntries.isEmpty)
          Text(
            query.hasFilter ? '当前筛选下没有匹配的平台事件。' : '当前没有可展示的平台事件。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          )
        else
          Column(
            children: <Widget>[
              for (
                int index = 0;
                index < recentEntries.length;
                index++
              ) ...<Widget>[
                _LogEntryTile(entry: recentEntries[index]),
                if (index != recentEntries.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        const SizedBox(height: 14),
        CommonButton(
          label: '刷新平台日志',
          tone: CommonButtonTone.secondary,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final PlatformLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final typeColor = _typeColor(entry.type);
    final headline = _buildHeadline(entry);
    final description = _buildDescription(entry);
    final tags = _buildTags(entry);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_typeIcon(entry.type), color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  headline,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
                if (description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map((tag) => _LogTag(label: tag.label, value: tag.value))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogTag extends StatelessWidget {
  const _LogTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        '$label · $value',
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _buildHeadline(PlatformLogEntry entry) {
  final details = entry.detailsMap;
  switch (entry.type.trim().toUpperCase()) {
    case 'AI_DETECTION':
      return '收到新的 AI 巡检结果';
    case 'ONENET_COMMAND':
      final led = asBool(details?['led']);
      return led ? '补光指令已下发' : '补光关闭指令已下发';
    case 'ONENET_SET_REPLY':
      final success = asBool(details?['success']);
      return success ? '设备回写已完成' : '设备回写失败';
    case 'ONENET_UPLINK':
      return '设备状态已同步';
    default:
      final summary = entry.summary.trim();
      return summary.isEmpty ? '最近平台事件' : summary;
  }
}

String _buildDescription(PlatformLogEntry entry) {
  final details = entry.detailsMap;
  final summary = entry.summary.trim();
  final deviceName = asString(details?['deviceName']).trim();
  final deviceLabel = deviceName.isEmpty ? _deviceLabel(entry) : deviceName;

  switch (entry.type.trim().toUpperCase()) {
    case 'AI_DETECTION':
      if (summary.isNotEmpty) {
        return summary;
      }
      final count = _nullableInt(
        details?['detectionCount'] ?? details?['count'],
      );
      final risk = _riskLabel(
        asString(details?['overallRiskLevel'] ?? details?['risk']).trim(),
      );
      final countText = count == null ? '已同步到后端' : '识别到 $count 个目标';
      final riskText = risk.isEmpty ? '' : '，当前风险 $risk';
      return '$deviceLabel$countText$riskText。';
    case 'ONENET_COMMAND':
      final status = _statusLabel(asString(details?['status']).trim());
      final message = asString(details?['message']).trim();
      if (message.isNotEmpty) {
        return '$deviceLabel$status。';
      }
      return '$deviceLabel已提交新的设备控制动作。';
    case 'ONENET_SET_REPLY':
      final success = asBool(details?['success']);
      final message = asString(details?['message']).trim();
      final result = success ? '设备已确认执行完成' : '设备回写失败';
      if (message.isNotEmpty) {
        return '$deviceLabel$result，$message。';
      }
      return '$deviceLabel$result。';
    case 'ONENET_UPLINK':
      final metrics = <String>[
        _metricText('温度', details?['temperature'], '°C'),
        _metricText('湿度', details?['humidity'], '%'),
        _metricText('光照', details?['light'], 'Lux'),
        _metricText('MQ2', details?['mq2'], 'ppm'),
      ].where((value) => value.isNotEmpty).join(' · ');
      if (metrics.isNotEmpty) {
        return '$deviceLabel$metrics。';
      }
      return '$deviceLabel已收到最新环境上报。';
    default:
      return summary;
  }
}

List<({String label, String value})> _buildTags(PlatformLogEntry entry) {
  final details = entry.detailsMap;
  final resultLabel = _eventResultLabel(entry);

  return <({String label, String value})>[
    (label: '类型', value: _typeLabel(entry.type)),
    (label: '设备', value: _deviceLabel(entry)),
    (label: '时间', value: _formatDateTime(entry.occurredAt)),
    if (resultLabel.isNotEmpty) (label: '结果', value: resultLabel),
    if (_requestIdLabel(details).isNotEmpty)
      (label: '请求', value: _requestIdLabel(details)),
  ];
}

String _typeLabel(String rawValue) {
  switch (rawValue.trim().toUpperCase()) {
    case 'AI_DETECTION':
      return 'AI 巡检';
    case 'ONENET_COMMAND':
      return '设备下发';
    case 'ONENET_SET_REPLY':
      return '设备回写';
    case 'ONENET_UPLINK':
      return '状态上报';
    default:
      return rawValue.trim().isEmpty ? '未知事件' : rawValue.trim();
  }
}

String _queryLabel(PlatformLogQuery query) {
  final typeLabel = query.normalizedType.isEmpty
      ? '全部类型'
      : _typeLabel(query.normalizedType);
  final keywordLabel = query.normalizedKeyword.isEmpty
      ? '未设关键字'
      : '关键字 ${query.normalizedKeyword}';
  return '$typeLabel / $keywordLabel / 最近 ${query.limit} 条';
}

String _deviceLabel(PlatformLogEntry entry) {
  final details = entry.detailsMap;
  final deviceName = asString(details?['deviceName']).trim();
  if (deviceName.isNotEmpty) {
    return deviceName;
  }
  final deviceId = entry.deviceId.trim();
  return deviceId.isEmpty ? '未标记设备' : deviceId;
}

String _eventResultLabel(PlatformLogEntry entry) {
  final details = entry.detailsMap;
  switch (entry.type.trim().toUpperCase()) {
    case 'AI_DETECTION':
      return _riskLabel(
        asString(details?['overallRiskLevel'] ?? details?['risk']).trim(),
      );
    case 'ONENET_COMMAND':
      return _statusLabel(asString(details?['status']).trim());
    case 'ONENET_SET_REPLY':
      return asBool(details?['success']) ? '成功' : '失败';
    case 'ONENET_UPLINK':
      return '已同步';
    default:
      return '';
  }
}

String _requestIdLabel(Map<String, dynamic>? details) {
  final requestId = asString(details?['requestId']).trim();
  return requestId.isEmpty ? '' : requestId;
}

String _statusLabel(String rawValue) {
  switch (rawValue.toLowerCase()) {
    case 'accepted':
    case 'success':
    case 'ok':
      return '已下发';
    case 'pending':
      return '待回写';
    case 'error':
      return '失败';
    default:
      return rawValue.isEmpty ? '待确认' : rawValue;
  }
}

String _riskLabel(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'extreme':
    case 'critical':
    case 'very_high':
    case 'very-high':
    case 'severe':
    case '极高':
      return '极高';
    case 'high':
    case 'alarm':
    case '高':
      return '高';
    case 'medium':
    case 'moderate':
    case 'mid':
    case '中':
      return '中';
    case 'low':
    case 'minor':
    case '低':
      return '低';
    case 'healthy':
    case 'normal':
    case 'safe':
    case 'ok':
    case '健康':
      return '健康';
    default:
      return rawValue.trim();
  }
}

String _metricText(String label, Object? rawValue, String unit) {
  if (rawValue == null) {
    return '';
  }

  final value = rawValue is num
      ? rawValue.toString()
      : asString(rawValue).trim();
  if (value.isEmpty) {
    return '';
  }
  return '$label $value$unit';
}

int? _nullableInt(Object? value) {
  if (value == null) {
    return null;
  }
  return asInt(value);
}

Color _typeColor(String rawValue) {
  switch (rawValue.trim().toUpperCase()) {
    case 'AI_DETECTION':
      return const Color(0xFF7C4D96);
    case 'ONENET_COMMAND':
      return const Color(0xFF2F7D4A);
    case 'ONENET_SET_REPLY':
      return const Color(0xFFB57A12);
    case 'ONENET_UPLINK':
      return const Color(0xFF356D8C);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData _typeIcon(String rawValue) {
  switch (rawValue.trim().toUpperCase()) {
    case 'AI_DETECTION':
      return Icons.psychology_alt_outlined;
    case 'ONENET_COMMAND':
      return Icons.settings_remote_outlined;
    case 'ONENET_SET_REPLY':
      return Icons.task_alt_rounded;
    case 'ONENET_UPLINK':
      return Icons.publish_rounded;
    default:
      return Icons.article_outlined;
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '时间未知';
  }

  final localValue = value.toLocal();
  final month = localValue.month.toString().padLeft(2, '0');
  final day = localValue.day.toString().padLeft(2, '0');
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');
  final second = localValue.second.toString().padLeft(2, '0');
  return '${localValue.year}-$month-$day $hour:$minute:$second';
}
