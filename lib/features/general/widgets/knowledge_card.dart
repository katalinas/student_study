import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 百科知识详情卡片数据模型。
class KnowledgeCardData {
  const KnowledgeCardData({
    required this.title,
    required this.summary,
    this.detailSections = const {},
    this.funFacts = const [],
    this.categoryIcon = Icons.auto_stories,
    this.categoryColor = AppColors.general,
  });

  /// 卡片标题。
  final String title;

  /// 摘要内容。
  final String summary;

  /// 详情分节，键为小标题，值为段落内容。
  final Map<String, String> detailSections;

  /// 趣味知识列表。
  final List<String> funFacts;

  /// 所属分类的图标。
  final IconData categoryIcon;

  /// 所属分类的颜色。
  final Color categoryColor;
}

/// 可复用的百科知识卡片组件，用于 PageView 中展示单张知识卡片。
///
/// 包含标题、封面图区域、摘要、可展开的详情分节和趣味知识标签。
/// 卡片内部支持滚动，适配内容较长的场景。
class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({
    super.key,
    required this.data,
  });

  final KnowledgeCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 卡片标题
            Text(
              data.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // 封面图占位区域（使用分类颜色和图标）
            _buildCoverArea(theme),
            const SizedBox(height: 16),

            // 摘要文本
            Text(
              data.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // 展开详情区域
            if (data.detailSections.isNotEmpty) ...[
              _buildDetailSections(theme),
              const SizedBox(height: 16),
            ],

            // 趣味知识标签
            if (data.funFacts.isNotEmpty) _buildFunFacts(theme),
          ],
        ),
      ),
    );
  }

  /// 构建封面图占位区域，显示分类图标和渐变背景。
  Widget _buildCoverArea(ThemeData theme) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.categoryColor.withValues(alpha:0.2),
            data.categoryColor.withValues(alpha:0.08),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          data.categoryIcon,
          size: 64,
          color: data.categoryColor.withValues(alpha:0.5),
        ),
      ),
    );
  }

  /// 构建可展开的详情分节列表。
  Widget _buildDetailSections(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分节标题
        Row(
          children: [
            Icon(
              Icons.expand_more,
              size: 20,
              color: data.categoryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '展开详情',
              style: theme.textTheme.titleSmall?.copyWith(
                color: data.categoryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 各详情小节使用 ExpansionTile 展开
        ...data.detailSections.entries.map((entry) {
          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha:0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 14),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              title: Text(
                entry.key,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              children: [
                Text(
                  entry.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 构建趣味知识彩色标签区域。
  Widget _buildFunFacts(ThemeData theme) {
    /// 趣味知识标签的配色列表。
    final chipColors = [
      AppColors.intellect,
      AppColors.tech,
      AppColors.logic,
      AppColors.general,
      AppColors.moral,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: AppColors.general,
            ),
            const SizedBox(width: 4),
            Text(
              '趣味知识',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.general,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(data.funFacts.length, (index) {
            final color = chipColors[index % chipColors.length];
            return Chip(
              label: Text(
                data.funFacts[index],
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                ),
              ),
              backgroundColor: color.withValues(alpha:0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            );
          }),
        ),
      ],
    );
  }
}
