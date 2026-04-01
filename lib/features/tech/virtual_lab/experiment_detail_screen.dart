import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/content_loader.dart';
import 'package:student_study/core/content/models/experiment.dart';

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------

/// 内容加载器的提供者。
final _contentLoaderProvider = Provider<ContentLoader>((ref) {
  return ContentLoader();
});

/// 根据实验 ID 获取单个实验数据的提供者。
///
/// 从 tech 模块的所有实验中查找匹配指定 ID 的实验。
final experimentDetailProvider =
    FutureProvider.autoDispose.family<Experiment?, String>((ref, id) async {
  final loader = ref.watch(_contentLoaderProvider);
  final experiments = await loader.loadExperiments('tech');
  try {
    return experiments.firstWhere((e) => e.id == id);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// 辅助函数
// ---------------------------------------------------------------------------

/// 根据器材名称返回对应的图标。
IconData _componentIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('水') || lower.contains('液')) {
    return Icons.water_drop_rounded;
  }
  if (lower.contains('灯') || lower.contains('电')) {
    return Icons.lightbulb_rounded;
  }
  if (lower.contains('瓶') || lower.contains('杯') || lower.contains('容器')) {
    return Icons.science_rounded;
  }
  if (lower.contains('纸') || lower.contains('笔')) {
    return Icons.edit_note_rounded;
  }
  if (lower.contains('尺') || lower.contains('量')) {
    return Icons.straighten_rounded;
  }
  if (lower.contains('镜')) {
    return Icons.search_rounded;
  }
  return Icons.build_circle_rounded;
}

// ---------------------------------------------------------------------------
// 页面组件
// ---------------------------------------------------------------------------

/// 实验详情与执行页面。
///
/// 展示实验的完整信息，包括标题、类别徽章、难度星级、描述、
/// 学习目标、所需器材、实验步骤（可逐步勾选完成）、
/// 趣味知识和课后思考问题。
class ExperimentDetailScreen extends ConsumerStatefulWidget {
  const ExperimentDetailScreen({
    super.key,
    required this.experimentId,
  });

  final String experimentId;

  @override
  ConsumerState<ExperimentDetailScreen> createState() =>
      _ExperimentDetailScreenState();
}

class _ExperimentDetailScreenState
    extends ConsumerState<ExperimentDetailScreen> {
  /// 记录每个实验步骤的完成状态，键为步骤序号。
  final Map<int, bool> _completedSteps = {};

  /// 检查是否所有步骤都已完成。
  bool _allStepsCompleted(List<ExperimentStep> steps) {
    if (steps.isEmpty) return false;
    return steps.every((step) => _completedSteps[step.order] == true);
  }

  /// 切换指定步骤的完成状态。
  void _toggleStep(int order) {
    setState(() {
      _completedSteps[order] = !(_completedSteps[order] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncExperiment =
        ref.watch(experimentDetailProvider(widget.experimentId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('实验详情'),
        backgroundColor: AppColors.tech,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncExperiment.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('加载失败: $error'),
        ),
        data: (experiment) {
          if (experiment == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '未找到该实验',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildContent(context, theme, experiment);
        },
      ),
    );
  }

  /// 构建实验详情的完整内容布局。
  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    Experiment experiment,
  ) {
    final allCompleted = _allStepsCompleted(experiment.steps);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题、类别徽章和难度星级
          _buildTitleSection(theme, experiment),
          const SizedBox(height: 16),

          // 实验描述
          Text(
            experiment.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // 学习目标
          if (experiment.learningGoals.isNotEmpty)
            _buildLearningGoals(theme, experiment.learningGoals),

          // 所需器材
          if (experiment.components.isNotEmpty)
            _buildComponents(theme, experiment.components),

          // 实验步骤
          if (experiment.steps.isNotEmpty)
            _buildSteps(theme, experiment.steps),

          // 实验完成庆祝提示
          if (allCompleted) _buildCelebration(theme),

          // 趣味知识
          if (experiment.funFacts.isNotEmpty)
            _buildFunFacts(theme, experiment.funFacts),

          // 课后思考
          if (experiment.followUpQuestions.isNotEmpty)
            _buildFollowUpQuestions(theme, experiment.followUpQuestions),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建标题区域，包含实验标题、类别徽章和难度星级。
  Widget _buildTitleSection(ThemeData theme, Experiment experiment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          experiment.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        // 类别徽章和难度星级
        Row(
          children: [
            // 类别徽章
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tech.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                experiment.category,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.tech,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 难度星级
            ...List.generate(5, (index) {
              return Icon(
                index < experiment.difficulty
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 18,
                color: index < experiment.difficulty
                    ? AppColors.achievementStar
                    : AppColors.textSecondary.withValues(alpha:0.4),
              );
            }),
          ],
        ),
      ],
    );
  }

  /// 构建"学习目标"分段，以编号列表形式展示。
  Widget _buildLearningGoals(ThemeData theme, List<String> goals) {
    return _SectionContainer(
      title: '学习目标',
      icon: Icons.flag_rounded,
      iconColor: AppColors.success,
      child: Column(
        children: goals.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 序号圆圈
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha:0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.value,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建"所需器材"分段，以水平滚动行展示器材图标和名称。
  Widget _buildComponents(
    ThemeData theme,
    List<ExperimentComponent> components,
  ) {
    return _SectionContainer(
      title: '所需器材',
      icon: Icons.handyman_rounded,
      iconColor: AppColors.secondary,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: components.map((component) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 器材图标容器
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _componentIcon(component.name),
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 器材名称
                  Text(
                    component.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // 数量信息
                  if (component.quantity != null)
                    Text(
                      '${component.quantity}${component.unit ?? '个'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha:0.7),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 构建"实验步骤"分段，每个步骤带有可勾选的复选框。
  Widget _buildSteps(ThemeData theme, List<ExperimentStep> steps) {
    final sortedSteps = List<ExperimentStep>.from(steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    return _SectionContainer(
      title: '实验步骤',
      icon: Icons.format_list_numbered_rounded,
      iconColor: AppColors.info,
      child: Column(
        children: sortedSteps.map((step) {
          final isCompleted = _completedSteps[step.order] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _toggleStep(step.order),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha:0.06)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha:0.3)
                        : AppColors.divider,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 完成状态复选框
                    Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 步骤编号和指令
                          Text(
                            '步骤 ${step.order}: ${step.instruction}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          // 步骤提示
                          if (step.tip != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '提示: ${step.tip}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.info,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建实验完成后的庆祝提示。
  Widget _buildCelebration(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withValues(alpha:0.15),
            AppColors.achievementStar.withValues(alpha:0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha:0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            color: AppColors.achievementStar,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            '实验完成!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '恭喜你完成了所有实验步骤，真棒!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建"趣味知识"分段，使用信息卡片样式。
  Widget _buildFunFacts(ThemeData theme, List<String> facts) {
    return _SectionContainer(
      title: '趣味知识',
      icon: Icons.lightbulb_rounded,
      iconColor: AppColors.achievementStar,
      child: Column(
        children: facts.map((fact) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.achievementStar.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.achievementStar.withValues(alpha:0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.achievementStar,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fact,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建"课后思考"分段，以简单问答形式展示。
  Widget _buildFollowUpQuestions(ThemeData theme, List<String> questions) {
    return _SectionContainer(
      title: '课后思考',
      icon: Icons.quiz_rounded,
      iconColor: AppColors.tech,
      child: Column(
        children: questions.asMap().entries.map((entry) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.techLight.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 问题编号
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.tech.withValues(alpha:0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.tech,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 通用分段容器组件。
///
/// 提供统一的分段标题样式（图标 + 标题文字）和内容区域。
class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分段标题行
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 分段内容
          child,
        ],
      ),
    );
  }
}
