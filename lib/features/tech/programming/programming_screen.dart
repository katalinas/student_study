import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';

/// 编程学习路径信息数据类。
class _LearningTrack {
  const _LearningTrack({
    required this.title,
    required this.gradeRange,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String gradeRange;
  final String description;
  final IconData icon;
  final Color color;
}

/// 编程学习路径列表定义。
const List<_LearningTrack> _learningTracks = [
  _LearningTrack(
    title: '积木编程',
    gradeRange: '小学1-3年级',
    description: '通过拖拽积木块学习编程逻辑，培养计算思维基础，'
        '用可视化方式理解顺序、循环和条件判断。',
    icon: Icons.extension_rounded,
    color: Color(0xFFFF7043),
  ),
  _LearningTrack(
    title: 'Python 入门',
    gradeRange: '小学4-6年级',
    description: '从简单的代码开始，学习变量、函数和数据结构，'
        '用 Python 编写有趣的小游戏和工具程序。',
    icon: Icons.terminal_rounded,
    color: Color(0xFF42A5F5),
  ),
  _LearningTrack(
    title: '算法基础',
    gradeRange: '初中7-9年级',
    description: '学习常见的排序、搜索算法和数据结构，'
        '培养解决复杂问题的能力，为信息学竞赛做准备。',
    icon: Icons.data_object_rounded,
    color: Color(0xFF66BB6A),
  ),
];

/// 编程练习场页面。
///
/// 展示三个编程学习路径卡片，每个卡片包含路径名称、适用年级、
/// 简要描述和"即将上线"徽章。底部有渐变装饰区域。
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
            // 底部装饰区域
            _buildBottomIllustration(theme),
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
            AppColors.tech.withValues(alpha:0.1),
            AppColors.techLight.withValues(alpha:0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 编程图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tech.withValues(alpha:0.15),
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

  /// 构建底部渐变装饰区域，带有代码图标作为视觉点缀。
  Widget _buildBottomIllustration(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tech.withValues(alpha:0.08),
            AppColors.techLight.withValues(alpha:0.2),
            AppColors.tech.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // 装饰图标
          Positioned(
            right: 20,
            bottom: 16,
            child: Icon(
              Icons.laptop_mac_rounded,
              size: 64,
              color: AppColors.tech.withValues(alpha:0.15),
            ),
          ),
          Positioned(
            left: 24,
            top: 20,
            child: Icon(
              Icons.code_rounded,
              size: 40,
              color: AppColors.tech.withValues(alpha:0.12),
            ),
          ),
          // 文字内容
          Positioned(
            left: 24,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '更多精彩内容',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.tech.withValues(alpha:0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '持续更新中，敬请期待...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha:0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 学习路径卡片组件。
///
/// 展示路径名称、图标、年级范围、描述文字和"即将上线"徽章。
class _TrackCard extends StatelessWidget {
  const _TrackCard({required this.track});

  final _LearningTrack track;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: track.color.withValues(alpha:0.2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧图标
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: track.color.withValues(alpha:0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                track.icon,
                color: track.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // 右侧文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行（标题 + 即将上线徽章）
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
                      // "即将上线"徽章
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha:0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '即将上线',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 年级范围
                  Text(
                    track.gradeRange,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: track.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 描述文字
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
    );
  }
}
