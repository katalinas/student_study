import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/user/progress_tracker.dart';
import 'package:student_study/core/user/user_provider.dart';

/// 模块开关状态的键名列表。
const List<String> _moduleIds = [
  'intellect',
  'tech',
  'logic',
  'general',
  'moral',
];

/// 模块显示名称。
const Map<String, String> _moduleNames = {
  'intellect': '智育学堂',
  'tech': '科技探索',
  'logic': '逻辑训练',
  'general': '通识百科',
  'moral': '德育融入',
};

/// 模块颜色。
const Map<String, Color> _moduleColors = {
  'intellect': AppColors.intellect,
  'tech': AppColors.tech,
  'logic': AppColors.logic,
  'general': AppColors.general,
  'moral': AppColors.moral,
};

/// 家长面板页面。
///
/// 进入前需要输入4位 PIN 码（默认 0000），通过后展示学习报告、
/// 使用时间管理和内容管理等功能。
class ParentScreen extends ConsumerStatefulWidget {
  const ParentScreen({super.key});

  @override
  ConsumerState<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends ConsumerState<ParentScreen> {
  /// 是否已通过 PIN 验证。
  bool _isAuthenticated = false;

  /// PIN 输入控制器。
  late final TextEditingController _pinController;

  /// PIN 错误提示。
  String? _pinError;

  /// 每日学习时长限制（分钟）。
  double _dailyLimitMinutes = 60;

  /// 休息提醒间隔（分钟）。
  int _breakIntervalMinutes = 30;

  /// 年级范围最小值。
  int _gradeRangeMin = 1;

  /// 年级范围最大值。
  int _gradeRangeMax = 9;

  /// 各模块开关状态。
  Map<String, bool> _moduleEnabled = {};

  /// 学习统计数据。
  int _weeklyAnswered = 0;
  double _weeklyCorrectRate = 0.0;
  int _weeklyMinutes = 0;
  Map<String, double> _moduleProgress = {};

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();

    // 初始化模块开关（全部默认开启）
    _moduleEnabled = {for (final id in _moduleIds) id: true};
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  /// 验证 PIN 码。
  void _verifyPin() {
    final prefs = ref.read(sharedPreferencesProvider);
    final savedPin = prefs.getString('parent_pin') ?? '0000';

    if (_pinController.text == savedPin) {
      setState(() {
        _isAuthenticated = true;
        _pinError = null;
      });
      _loadParentSettings();
      _loadLearningStats();
    } else {
      setState(() => _pinError = 'PIN码错误，请重试');
    }
  }

  /// 加载家长管理设置。
  void _loadParentSettings() {
    final prefs = ref.read(sharedPreferencesProvider);

    setState(() {
      _dailyLimitMinutes =
          (prefs.getInt('parent_daily_limit') ?? 60).toDouble();
      _breakIntervalMinutes = prefs.getInt('parent_break_interval') ?? 30;
      _gradeRangeMin = prefs.getInt('parent_grade_min') ?? 1;
      _gradeRangeMax = prefs.getInt('parent_grade_max') ?? 9;

      // 加载各模块开关
      for (final id in _moduleIds) {
        _moduleEnabled[id] = prefs.getBool('parent_module_$id') ?? true;
      }
    });
  }

  /// 加载孩子的学习统计数据。
  void _loadLearningStats() {
    final user = ref.read(activeUserProvider).valueOrNull;
    if (user == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final tracker = ProgressTracker(prefs, user.id);

    int totalAnswered = 0;
    int totalCorrect = 0;
    int totalSeconds = 0;

    for (final id in _moduleIds) {
      final progress = tracker.getModuleProgress(id);
      totalAnswered += progress['totalAnswered'] as int;
      totalCorrect += progress['correctCount'] as int;
      totalSeconds += tracker.getTimeSpent(id).inSeconds;
    }

    final rate = totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0;

    setState(() {
      _weeklyAnswered = totalAnswered;
      _weeklyCorrectRate = rate;
      _weeklyMinutes = (totalSeconds / 60).ceil();
      _moduleProgress = tracker.getAllModuleProgress();
    });
  }

  /// 保存每日学习时长限制。
  Future<void> _saveDailyLimit(double value) async {
    setState(() => _dailyLimitMinutes = value);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('parent_daily_limit', value.round());
  }

  /// 保存休息提醒间隔。
  Future<void> _saveBreakInterval(int value) async {
    setState(() => _breakIntervalMinutes = value);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('parent_break_interval', value);
  }

  /// 保存年级范围。
  Future<void> _saveGradeRange(int min, int max) async {
    setState(() {
      _gradeRangeMin = min;
      _gradeRangeMax = max;
    });
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('parent_grade_min', min);
    await prefs.setInt('parent_grade_max', max);
  }

  /// 保存模块开关状态。
  Future<void> _saveModuleToggle(String moduleId, bool enabled) async {
    setState(() => _moduleEnabled = {..._moduleEnabled, moduleId: enabled});
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('parent_module_$moduleId', enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家长面板'),
        centerTitle: true,
      ),
      body: _isAuthenticated ? _buildDashboard(context) : _buildPinEntry(context),
    );
  }

  /// 构建 PIN 码输入界面。
  Widget _buildPinEntry(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '请输入家长PIN码',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '默认PIN码：0000',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                counterText: '',
                errorText: _pinError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _verifyPin,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('验证'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建验证通过后的家长面板主体。
  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 学习报告
          _buildLearningReport(theme),
          const SizedBox(height: 20),

          // 模块进度柱状图
          _buildModuleProgressChart(theme),
          const SizedBox(height: 20),

          // 使用时间管理
          _buildTimeManagement(theme),
          const SizedBox(height: 20),

          // 内容管理
          _buildContentManagement(theme),
        ],
      ),
    );
  }

  /// 构建学习报告卡片。
  Widget _buildLearningReport(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学习报告',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildReportStat(
                  theme,
                  label: '本周答题数',
                  value: '$_weeklyAnswered',
                  color: AppColors.intellect,
                ),
                _buildReportStat(
                  theme,
                  label: '正确率',
                  value: '${(_weeklyCorrectRate * 100).toStringAsFixed(0)}%',
                  color: AppColors.success,
                ),
                _buildReportStat(
                  theme,
                  label: '学习时长',
                  value: '$_weeklyMinutes分钟',
                  color: AppColors.tech,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建报告中的单个统计项。
  Widget _buildReportStat(
    ThemeData theme, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 构建模块进度柱状图。
  Widget _buildModuleProgressChart(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '各模块学习进度',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // 简易柱状图
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _moduleIds.map((id) {
                  final progress = _moduleProgress[id] ?? 0.0;
                  final color = _moduleColors[id] ?? AppColors.primary;
                  final name = _moduleNames[id] ?? id;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 百分比标签
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 柱体
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: progress.clamp(0.05, 1.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // 模块名称
                          Text(
                            name.substring(0, 2),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建使用时间管理区域。
  Widget _buildTimeManagement(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用时间管理',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // 每日学习时长限制
            Text(
              '每日学习时长限制：${_dailyLimitMinutes.round()}分钟',
              style: theme.textTheme.bodyMedium,
            ),
            Slider(
              value: _dailyLimitMinutes,
              min: 30,
              max: 120,
              divisions: 6,
              label: '${_dailyLimitMinutes.round()}分钟',
              onChanged: (value) => setState(() => _dailyLimitMinutes = value),
              onChangeEnd: _saveDailyLimit,
            ),

            const Divider(height: 24),

            // 休息提醒间隔
            Text(
              '休息提醒间隔',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(value: 15, label: Text('15分钟')),
                ButtonSegment<int>(value: 30, label: Text('30分钟')),
                ButtonSegment<int>(value: 45, label: Text('45分钟')),
              ],
              selected: {_breakIntervalMinutes},
              onSelectionChanged: (selected) {
                _saveBreakInterval(selected.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建内容管理区域。
  Widget _buildContentManagement(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '内容管理',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // 年级内容范围
            Text(
              '年级内容范围：$_gradeRangeMin年级 ~ $_gradeRangeMax年级',
              style: theme.textTheme.bodyMedium,
            ),
            RangeSlider(
              values: RangeValues(
                _gradeRangeMin.toDouble(),
                _gradeRangeMax.toDouble(),
              ),
              min: 1,
              max: 9,
              divisions: 8,
              labels: RangeLabels(
                '$_gradeRangeMin年级',
                '$_gradeRangeMax年级',
              ),
              onChanged: (values) {
                setState(() {
                  _gradeRangeMin = values.start.round();
                  _gradeRangeMax = values.end.round();
                });
              },
              onChangeEnd: (values) {
                _saveGradeRange(values.start.round(), values.end.round());
              },
            ),

            const Divider(height: 24),

            // 模块开关
            Text(
              '模块开关',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_moduleIds.length, (index) {
              final id = _moduleIds[index];
              final name = _moduleNames[id] ?? id;
              final color = _moduleColors[id] ?? AppColors.primary;
              final enabled = _moduleEnabled[id] ?? true;

              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(name),
                  ],
                ),
                value: enabled,
                onChanged: (value) => _saveModuleToggle(id, value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
