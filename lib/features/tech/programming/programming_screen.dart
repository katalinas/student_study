import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/content_loader.dart';
import 'package:student_study/core/content/models/question.dart';

/// 编程学习路径信息数据类。
class _LearningTrack {
  const _LearningTrack({
    required this.id,
    required this.title,
    required this.gradeRange,
    required this.description,
    required this.icon,
    required this.color,
    required this.subject,
  });

  final String id;
  final String title;
  final String gradeRange;
  final String description;
  final IconData icon;
  final Color color;
  final String subject;
}

/// 编程学习路径列表定义。
const List<_LearningTrack> _learningTracks = [
  _LearningTrack(
    id: 'blocks',
    title: '积木编程',
    gradeRange: '小学1-3年级',
    description: '通过拖拽积木块学习编程逻辑，培养计算思维基础，'
        '用可视化方式理解顺序、循环和条件判断。',
    icon: Icons.extension_rounded,
    color: Color(0xFFFF7043),
    subject: 'blocks',
  ),
  _LearningTrack(
    id: 'python',
    title: 'Python 入门',
    gradeRange: '小学4-6年级',
    description: '从简单的代码开始，学习变量、函数和数据结构，'
        '用 Python 编写有趣的小游戏和工具程序。',
    icon: Icons.terminal_rounded,
    color: Color(0xFF42A5F5),
    subject: 'python',
  ),
  _LearningTrack(
    id: 'algorithm',
    title: '算法基础',
    gradeRange: '初中7-9年级',
    description: '学习常见的排序、搜索算法和数据结构，'
        '培养解决复杂问题的能力，为信息学竞赛做准备。',
    icon: Icons.data_object_rounded,
    color: Color(0xFF66BB6A),
    subject: 'algorithm',
  ),
];

/// 编程题目的提供者，按学科加载。
final _programmingQuestionsProvider = FutureProvider.autoDispose
    .family<List<Question>, String>((ref, tag) async {
  final loader = ContentLoader();
  return loader.loadQuestions('tech', tag: tag);
});

/// 编程练习场页面。
///
/// 展示三个编程学习路径卡片，每个卡片包含路径名称、适用年级、
/// 简要描述和题目数量。点击可进入对应的练习题目。
class ProgrammingScreen extends ConsumerWidget {
  const ProgrammingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编程练习场'),
        backgroundColor: AppColors.tech,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 顶部说明区域
            _buildHeaderBanner(theme),
            // 学习路径卡片列表
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _learningTracks
                    .map((track) => _TrackCard(track: track))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            // 底部统计区域
            _buildStatsSection(ref, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建顶部说明横幅，展示编程图标和引导文字。
  Widget _buildHeaderBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tech.withValues(alpha: 0.1),
            AppColors.techLight.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tech.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: AppColors.tech,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择你的编程之路',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.tech,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '根据年级选择适合的学习路径，从零开始成为编程小达人',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部统计区域，显示各路径题目数量。
  Widget _buildStatsSection(WidgetRef ref, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tech.withValues(alpha: 0.08),
            AppColors.techLight.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '学习资源',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.tech,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _learningTracks.map((track) {
              final asyncQuestions =
                  ref.watch(_programmingQuestionsProvider(track.subject));
              final count = asyncQuestions.when(
                data: (q) => q.length,
                loading: () => 0,
                error: (e, s) => 0,
              );
              return Expanded(
                child: Column(
                  children: [
                    Icon(track.icon, color: track.color, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      '$count 题',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: track.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      track.title,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// 学习路径卡片组件。
///
/// 展示路径名称、图标、年级范围、描述文字和题目数量标签。
/// 点击进入对应的编程练习。
class _TrackCard extends ConsumerWidget {
  const _TrackCard({required this.track});

  final _LearningTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncQuestions =
        ref.watch(_programmingQuestionsProvider(track.subject));
    final questionCount = asyncQuestions.when(
      data: (q) => q.length,
      loading: () => 0,
      error: (e, s) => 0,
    );

    return Card(
      elevation: 2,
      shadowColor: track.color.withValues(alpha: 0.2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final questions = asyncQuestions.when(
            data: (q) => q,
            loading: () => <Question>[],
            error: (e, s) => <Question>[],
          );
          if (questions.isNotEmpty) {
            context.push('/quiz/tech', extra: questions);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: track.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  track.icon,
                  color: track.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: track.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$questionCount 题',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: track.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.gradeRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: track.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      track.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
