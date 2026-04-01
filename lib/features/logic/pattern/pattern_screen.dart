/// 规律岛（模式识别训练）页面。
///
/// 提供20个关卡的选择界面以及专项训练入口，
/// 用户可选择关卡进行模式识别类题目练习。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/content_loader.dart';
import 'package:student_study/core/content/models/question.dart';

// ---------------------------------------------------------------------------
// 内容加载器提供者
// ---------------------------------------------------------------------------

/// 模式识别题目的内容加载提供者。
final _patternQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final loader = ContentLoader();
  return loader.loadQuestions('logic', subject: 'pattern');
});

// ---------------------------------------------------------------------------
// 关卡状态枚举
// ---------------------------------------------------------------------------

/// 关卡的三种可能状态。
enum _LevelStatus {
  /// 已完成
  completed,

  /// 当前可玩
  current,

  /// 未解锁
  locked,
}

// ---------------------------------------------------------------------------
// 主页面
// ---------------------------------------------------------------------------

/// 规律岛主页面，展示关卡选择网格和专项训练入口。
class PatternScreen extends ConsumerStatefulWidget {
  const PatternScreen({super.key});

  @override
  ConsumerState<PatternScreen> createState() => _PatternScreenState();
}

class _PatternScreenState extends ConsumerState<PatternScreen> {
  /// 当前已解锁到的最高关卡（从1开始计数），后续接入进度系统
  final int _currentLevel = 1;

  /// 总关卡数
  static const int _totalLevels = 20;

  /// 获取指定关卡编号的状态
  _LevelStatus _getLevelStatus(int level) {
    if (level < _currentLevel) return _LevelStatus.completed;
    if (level == _currentLevel) return _LevelStatus.current;
    return _LevelStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    // 预加载题目数据，在用户选择关卡前完成内容准备
    final questionsAsync = ref.watch(_patternQuestionsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: questionsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF43A047),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text('加载题目失败: $error'),
                ),
                data: (_) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLevelGrid(context),
                      const SizedBox(height: 28),
                      _buildSpecialTrainingSection(context),
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

  /// 构建页面顶部标题栏，显示岛屿名称和关卡进度。
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),

          // 岛屿图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.pattern,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 标题和进度文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '规律岛',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '关卡 $_currentLevel/$_totalLevels',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha:0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建20个关卡的网格选择界面。
  Widget _buildLevelGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择关卡',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _totalLevels,
          itemBuilder: (context, index) {
            final level = index + 1;
            final status = _getLevelStatus(level);
            return _LevelButton(
              level: level,
              status: status,
              onTap: () => _startLevel(level, status),
            );
          },
        ),
      ],
    );
  }

  /// 构建"专项训练"区域，包含数字规律和图形规律两张训练卡片。
  Widget _buildSpecialTrainingSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '专项训练',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _TrainingCard(
                title: '数字规律',
                description: '练习数字序列的规律发现',
                icon: Icons.looks_one_rounded,
                color: const Color(0xFF26A69A),
                onTap: () {
                  // 导航至数字规律专项训练
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TrainingCard(
                title: '图形规律',
                description: '练习图形变化的规律识别',
                icon: Icons.category_rounded,
                color: const Color(0xFF42A5F5),
                onTap: () {
                  // 导航至图形规律专项训练
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 处理关卡点击事件，只有已完成和当前关卡可进入。
  void _startLevel(int level, _LevelStatus status) {
    if (status == _LevelStatus.locked) return;

    // 从已加载的题目中获取数据，通过 extra 传递给 QuizInteractionScreen
    // 避免使用路由查询参数（router 不处理查询参数过滤逻辑）
    final questionsAsync = ref.read(_patternQuestionsProvider);
    // 使用 when 安全提取数据，避免访问不存在的 valueOrNull getter
    final allQuestions = questionsAsync.when(
      data: (q) => q,
      loading: () => <Question>[],
      error: (e, s) => <Question>[],
    );
    // 按关卡编号分页：每关取固定数量的题目
    const questionsPerLevel = 5;
    final start = ((level - 1) * questionsPerLevel).clamp(0, allQuestions.length);
    final end = (start + questionsPerLevel).clamp(0, allQuestions.length);
    final levelQuestions = allQuestions.sublist(start, end);

    context.push('/quiz/logic', extra: levelQuestions.isNotEmpty ? levelQuestions : allQuestions);
  }
}

// ---------------------------------------------------------------------------
// 关卡按钮组件
// ---------------------------------------------------------------------------

/// 关卡选择网格中的单个关卡按钮。
///
/// 根据关卡状态呈现不同的视觉效果：
/// - 已完成：绿色背景，显示对勾
/// - 当前：发光边框效果
/// - 未解锁：灰色背景，显示锁图标
class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.level,
    required this.status,
    required this.onTap,
  });

  final int level;
  final _LevelStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    final List<BoxShadow> shadows;

    switch (status) {
      case _LevelStatus.completed:
        backgroundColor = AppColors.success.withValues(alpha:0.15);
        borderColor = AppColors.success;
        textColor = AppColors.success;
        shadows = [];
      case _LevelStatus.current:
        backgroundColor = const Color(0xFF43A047).withValues(alpha:0.1);
        borderColor = const Color(0xFF43A047);
        textColor = const Color(0xFF43A047);
        shadows = [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha:0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ];
      case _LevelStatus.locked:
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade400;
        shadows = [];
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: shadows,
        ),
        child: Center(
          child: status == _LevelStatus.completed
              ? Icon(Icons.check_rounded, color: textColor, size: 22)
              : status == _LevelStatus.locked
                  ? Icon(Icons.lock_rounded, color: textColor, size: 18)
                  : Text(
                      '$level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 专项训练卡片组件
// ---------------------------------------------------------------------------

/// 专项训练区域的单个训练类型卡片。
class _TrainingCard extends StatelessWidget {
  const _TrainingCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha:0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
