import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/user/progress_tracker.dart';
import 'package:student_study/core/user/user_model.dart';
import 'package:student_study/core/user/user_provider.dart';
import 'package:student_study/features/home/widgets/daily_checkin.dart';
import 'package:student_study/features/home/widgets/module_card.dart';
import 'package:student_study/features/home/widgets/stats_bar.dart';

/// 描述首页网格中显示的单个学习模块的数据类。
class _ModuleInfo {
  const _ModuleInfo({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
}

const List<_ModuleInfo> _modules = [
  _ModuleInfo(
    id: 'intellect',
    title: '智育学堂',
    icon: Icons.school,
    color: AppColors.intellect,
  ),
  _ModuleInfo(
    id: 'tech',
    title: '科技探索',
    icon: Icons.rocket_launch,
    color: AppColors.tech,
  ),
  _ModuleInfo(
    id: 'logic',
    title: '逻辑训练',
    icon: Icons.psychology,
    color: AppColors.logic,
  ),
  _ModuleInfo(
    id: 'general',
    title: '通识百科',
    icon: Icons.auto_stories,
    color: AppColors.general,
  ),
];

/// 选择用户资料后显示的主首页。
///
/// 包含欢迎问候语、每日签到卡片、2x2 模块网格和底部统计栏。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ProgressTracker? _tracker;
  bool _checkedIn = false;
  int _streak = 0;
  int _answeredToday = 0;
  double _correctRate = 0.0;
  Map<String, double> _moduleProgress = const {};

  @override
  void initState() {
    super.initState();
    // 延迟追踪器初始化，等到首次构建时用户可用后执行。
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTracker());
  }

  void _initTracker() {
    final user = ref.read(activeUserProvider).valueOrNull;
    if (user == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final tracker = ProgressTracker(prefs, user.id);

    final daily = tracker.getDailyStats();

    setState(() {
      _tracker = tracker;
      _checkedIn = tracker.hasCheckedInToday();
      _streak = tracker.getStreak();
      _answeredToday = daily['answeredToday'] as int;
      _correctRate = (daily['correctRate'] as double?) ?? 0.0;
      _moduleProgress = tracker.getAllModuleProgress();
    });
  }

  Future<void> _handleCheckIn() async {
    final tracker = _tracker;
    if (tracker == null) return;

    await tracker.checkIn();

    setState(() {
      _checkedIn = true;
      _streak = tracker.getStreak();
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
        body: Center(child: Text('Failed to load user: $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No active user')),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 问候语
              _buildGreeting(theme, user),
              const SizedBox(height: 20),

              // 每日签到
              DailyCheckIn(
                isCheckedIn: _checkedIn,
                streakDays: _streak,
                onCheckIn: _handleCheckIn,
              ),
              const SizedBox(height: 24),

              // 模块网格
              _buildModuleGrid(context),
              const SizedBox(height: 24),

              // 快速统计
              StatsBar(
                answeredToday: _answeredToday,
                correctRate: _correctRate,
                streakDays: _streak,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme, UserProfile user) {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 6) {
      timeGreeting = '夜深了';
    } else if (hour < 12) {
      timeGreeting = '早上好';
    } else if (hour < 14) {
      timeGreeting = '中午好';
    } else if (hour < 18) {
      timeGreeting = '下午好';
    } else {
      timeGreeting = '晚上好';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$timeGreeting，${user.name}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${user.grade}年级',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final info = _modules[index];
        final progress = _moduleProgress[info.id] ?? 0.0;

        return ModuleCard(
          title: info.title,
          icon: info.icon,
          color: info.color,
          progress: progress,
          onTap: () => context.push('/module/${info.id}'),
        );
      },
    );
  }
}
