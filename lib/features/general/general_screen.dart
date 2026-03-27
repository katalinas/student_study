import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';

/// 通识百科分类数据模型。
class _CategoryInfo {
  const _CategoryInfo({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.itemCount,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int itemCount;
}

/// 通识百科的四个分类。
const List<_CategoryInfo> _categories = [
  _CategoryInfo(
    id: 'astronomy_geography',
    name: '天文地理',
    subtitle: '探索地球与宇宙',
    icon: Icons.public,
    color: Color(0xFF1976D2),
    itemCount: 8,
  ),
  _CategoryInfo(
    id: 'history',
    name: '历史长河',
    subtitle: '穿越时空之旅',
    icon: Icons.history_edu,
    color: Color(0xFF6D4C41),
    itemCount: 6,
  ),
  _CategoryInfo(
    id: 'art',
    name: '艺术鉴赏',
    subtitle: '发现美的世界',
    icon: Icons.palette,
    color: Color(0xFFAD1457),
    itemCount: 5,
  ),
  _CategoryInfo(
    id: 'life_skills',
    name: '生活技能',
    subtitle: '实用生活知识',
    icon: Icons.handyman,
    color: Color(0xFF2E7D32),
    itemCount: 7,
  ),
];

/// 通识百科模块主页面。
///
/// 显示四个分类卡片的网格布局，点击后进入对应分类的卡片浏览页面。
class GeneralScreen extends ConsumerWidget {
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题区域
              _buildHeader(theme),
              const SizedBox(height: 24),

              // 分类网格卡片
              _buildCategoryGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建页面顶部标题和图标。
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.general.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_stories,
            color: AppColors.general,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '通识百科',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.general,
          ),
        ),
      ],
    );
  }

  /// 构建分类卡片网格。
  Widget _buildCategoryGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return _CategoryCard(
          category: category,
          onTap: () {
            context.push(
              '/general/cards/${category.id}',
              extra: category.name,
            );
          },
        );
      },
    );
  }
}

/// 分类卡片组件，展示分类图标、名称、描述和内容数量。
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final _CategoryInfo category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分类图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),

              // 分类名称
              Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              // 分类描述
              Expanded(
                child: Text(
                  category.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 内容数量标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${category.itemCount}个知识卡片',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
