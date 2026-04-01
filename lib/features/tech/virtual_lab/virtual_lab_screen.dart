import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// 实验列表数据的异步提供者。
///
/// 从 tech 模块加载所有实验数据。
final virtualLabExperimentsProvider =
    FutureProvider.autoDispose<List<Experiment>>((ref) async {
  final loader = ref.watch(_contentLoaderProvider);
  return loader.loadExperiments('tech');
});

// ---------------------------------------------------------------------------
// 辅助函数
// ---------------------------------------------------------------------------

/// 根据实验类别返回对应的图标。
IconData _categoryIcon(String category) {
  switch (category) {
    case '物理':
      return Icons.bolt_rounded;
    case '化学':
      return Icons.science_rounded;
    case '生物':
      return Icons.biotech_rounded;
    case '地球科学':
      return Icons.public_rounded;
    case '工程':
      return Icons.engineering_rounded;
    default:
      return Icons.science_rounded;
  }
}

/// 根据实验类别返回对应的主题颜色。
Color _categoryColor(String category) {
  switch (category) {
    case '物理':
      return const Color(0xFF42A5F5);
    case '化学':
      return const Color(0xFFEF5350);
    case '生物':
      return const Color(0xFF66BB6A);
    case '地球科学':
      return const Color(0xFF26A69A);
    case '工程':
      return const Color(0xFFFF7043);
    default:
      return AppColors.tech;
  }
}

// ---------------------------------------------------------------------------
// 页面组件
// ---------------------------------------------------------------------------

/// 虚拟实验室列表页面。
///
/// 以网格形式展示所有可用的实验项目，每个卡片显示实验封面、
/// 标题、难度星级和适用年级范围。点击卡片可进入实验详情页。
class VirtualLabScreen extends ConsumerWidget {
  const VirtualLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExperiments = ref.watch(virtualLabExperimentsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('虚拟实验室'),
        backgroundColor: AppColors.tech,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncExperiments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.science_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无实验数据',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '实验内容正在准备中，敬请期待',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        data: (experiments) {
          if (experiments.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.science_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无实验数据',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          return _ExperimentGrid(experiments: experiments);
        },
      ),
    );
  }
}

/// 实验卡片网格布局组件。
class _ExperimentGrid extends StatelessWidget {
  const _ExperimentGrid({required this.experiments});

  final List<Experiment> experiments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: experiments.length,
      itemBuilder: (context, index) {
        final experiment = experiments[index];
        return _ExperimentCard(experiment: experiment);
      },
    );
  }
}

/// 单个实验卡片组件。
///
/// 展示实验的封面图占位区域、标题、难度星级和年级范围徽章。
class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({required this.experiment});

  final Experiment experiment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _categoryColor(experiment.category);

    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha:0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          '/module/tech/virtual_lab/experiment/${experiment.id}',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图占位区域（彩色容器 + 类别图标）
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha:0.7),
                    color,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _categoryIcon(experiment.category),
                  color: Colors.white.withValues(alpha:0.9),
                  size: 40,
                ),
              ),
            ),
            // 卡片文字内容区域
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 实验标题
                    Text(
                      experiment.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // 难度星级
                    _DifficultyStars(difficulty: experiment.difficulty),
                    const SizedBox(height: 6),
                    // 年级范围徽章
                    _GradeRangeBadge(
                      gradeMin: experiment.gradeMin,
                      gradeMax: experiment.gradeMax,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 难度星级显示组件。
///
/// 根据难度值（1-5）显示对应数量的实心星和空心星。
class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < difficulty ? Icons.star_rounded : Icons.star_border_rounded,
          size: 14,
          color: index < difficulty
              ? AppColors.achievementStar
              : AppColors.textSecondary.withValues(alpha:0.4),
        );
      }),
    );
  }
}

/// 年级范围徽章组件。
///
/// 以小型圆角标签形式显示实验适用的年级范围。
class _GradeRangeBadge extends StatelessWidget {
  const _GradeRangeBadge({
    required this.gradeMin,
    required this.gradeMax,
  });

  final int gradeMin;
  final int gradeMax;

  @override
  Widget build(BuildContext context) {
    final label =
        gradeMin == gradeMax ? '$gradeMin年级' : '$gradeMin-$gradeMax年级';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.techLight.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.tech,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
