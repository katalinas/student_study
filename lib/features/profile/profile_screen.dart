import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/user/progress_tracker.dart';
import 'package:student_study/core/user/user_model.dart';
import 'package:student_study/core/user/user_provider.dart';

/// 预设头像图标列表，供用户选择。
const List<IconData> _avatarIcons = [
  Icons.pets,
  Icons.cruelty_free,
  Icons.emoji_nature,
  Icons.flutter_dash,
  Icons.pest_control,
  Icons.bug_report,
  Icons.set_meal,
  Icons.sailing,
  Icons.forest,
  Icons.park,
  Icons.eco,
  Icons.spa,
];

/// 模块进度展示数据。
class _ModuleProgressInfo {
  const _ModuleProgressInfo({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final Color color;
}

/// 五大模块的进度信息。
const List<_ModuleProgressInfo> _moduleInfoList = [
  _ModuleProgressInfo(id: 'intellect', name: '智育学堂', color: AppColors.intellect),
  _ModuleProgressInfo(id: 'tech', name: '科技探索', color: AppColors.tech),
  _ModuleProgressInfo(id: 'logic', name: '逻辑训练', color: AppColors.logic),
  _ModuleProgressInfo(id: 'general', name: '通识百科', color: AppColors.general),
  _ModuleProgressInfo(id: 'moral', name: '德育融入', color: AppColors.moral),
];

/// 个人中心页面。
///
/// 展示用户头像、名称、年级、学习统计、模块进度和成就徽章。
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  /// 总答题数。
  int _totalAnswered = 0;

  /// 总正确率。
  double _correctRate = 0.0;

  /// 连续打卡天数。
  int _streakDays = 0;

  /// 总学习时长（分钟）。
  int _totalMinutes = 0;

  /// 各模块进度百分比。
  Map<String, double> _moduleProgress = const {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  /// 从 ProgressTracker 中加载用户统计数据。
  void _loadStats() {
    final user = ref.read(activeUserProvider).value;
    if (user == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final tracker = ProgressTracker(prefs, user.id);

    // 汇总各模块的答题数和正确数
    int totalAnswered = 0;
    int totalCorrect = 0;
    int totalSeconds = 0;

    for (final moduleInfo in _moduleInfoList) {
      final progress = tracker.getModuleProgress(moduleInfo.id);
      totalAnswered += progress['totalAnswered'] as int;
      totalCorrect += progress['correctCount'] as int;
      totalSeconds += tracker.getTimeSpent(moduleInfo.id).inSeconds;
    }

    final rate = totalAnswered > 0 ? totalCorrect / totalAnswered : 0.0;

    setState(() {
      _totalAnswered = totalAnswered;
      _correctRate = rate;
      _streakDays = tracker.getStreak();
      _totalMinutes = (totalSeconds / 60).ceil();
      _moduleProgress = tracker.getAllModuleProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(activeUserProvider);

    return asyncUser.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('加载失败: $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('未登录')),
          );
        }
        return _buildContent(context, user);
      },
    );
  }

  Widget _buildContent(BuildContext context, UserProfile user) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // 用户信息区域
              _buildUserHeader(theme, user),
              const SizedBox(height: 24),

              // 统计概览卡片
              _buildStatsCard(theme),
              const SizedBox(height: 20),

              // 模块进度
              _buildModuleProgress(theme),
              const SizedBox(height: 20),

              // 成就徽章
              _buildAchievements(theme),
              const SizedBox(height: 24),

              // 学习资源按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/resources'),
                  icon: const Icon(
                    Icons.language_rounded,
                    color: AppColors.primary,
                  ),
                  label: const Text('学习资源'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 设置按钮
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profile/settings'),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('设置'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户头像、名称和年级区域。
  Widget _buildUserHeader(ThemeData theme, UserProfile user) {
    final avatarIcon = user.avatarIndex < _avatarIcons.length
        ? _avatarIcons[user.avatarIndex]
        : Icons.person;

    return Column(
      children: [
        // 头像
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary.withValues(alpha:0.12),
          child: Icon(
            avatarIcon,
            size: 44,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),

        // 名称
        Text(
          user.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),

        // 年级标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            // 钳制索引，防止 grade 超出 gradeColors 范围导致 RangeError
          color: AppColors.gradeColors[
            (user.grade - 1).clamp(0, AppColors.gradeColors.length - 1)
          ].withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${user.grade}年级',
            style: theme.textTheme.labelMedium?.copyWith(
              // 钳制索引，防止 grade 超出 gradeColors 范围导致 RangeError
              color: AppColors.gradeColors[
                (user.grade - 1).clamp(0, AppColors.gradeColors.length - 1)
              ],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 编辑资料按钮
        TextButton.icon(
          onPressed: () async {
            await context.push('/profile/edit');
            // 编辑完成后刷新统计
            _loadStats();
          },
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('编辑资料'),
        ),
      ],
    );
  }

  /// 构建统计概览卡片。
  Widget _buildStatsCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Row(
          children: [
            _buildStatColumn(
              theme,
              icon: Icons.quiz_outlined,
              value: '$_totalAnswered',
              label: '总答题数',
              color: AppColors.intellect,
            ),
            _buildStatColumn(
              theme,
              icon: Icons.check_circle_outline,
              value: '${(_correctRate * 100).toStringAsFixed(0)}%',
              label: '正确率',
              color: AppColors.success,
            ),
            _buildStatColumn(
              theme,
              icon: Icons.local_fire_department_outlined,
              value: '$_streakDays',
              label: '连续打卡',
              color: AppColors.streakFlame,
            ),
            _buildStatColumn(
              theme,
              icon: Icons.timer_outlined,
              value: '$_totalMinutes',
              label: '时长(分钟)',
              color: AppColors.tech,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个统计列。
  Widget _buildStatColumn(
    ThemeData theme, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
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

  /// 构建模块进度条列表。
  Widget _buildModuleProgress(ThemeData theme) {
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
              '模块学习进度',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            ...List.generate(_moduleInfoList.length, (index) {
              final info = _moduleInfoList[index];
              final progress = _moduleProgress[info.id] ?? 0.0;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _moduleInfoList.length - 1 ? 12 : 0,
                ),
                child: _buildProgressRow(theme, info, progress),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建单行模块进度条。
  Widget _buildProgressRow(
    ThemeData theme,
    _ModuleProgressInfo info,
    double progress,
  ) {
    final percent = (progress * 100).toStringAsFixed(0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              info.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: info.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: info.color.withValues(alpha:0.12),
            valueColor: AlwaysStoppedAnimation<Color>(info.color),
          ),
        ),
      ],
    );
  }

  /// 构建成就徽章占位区域。
  Widget _buildAchievements(ThemeData theme) {
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
              '成就徽章',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 28,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha:0.4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '未解锁',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha:0.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
