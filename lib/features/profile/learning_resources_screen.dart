import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:student_study/app/theme/colors.dart';

/// 学习资源分类模型。
class _ResourceCategory {
  const _ResourceCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.resources,
  });

  final String name;
  final IconData icon;
  final Color color;
  final List<_Resource> resources;
}

/// 单个学习资源条目。
class _Resource {
  const _Resource({
    required this.name,
    required this.url,
    required this.description,
  });

  final String name;
  final String url;
  final String description;
}

/// 预置学习资源数据。
const List<_ResourceCategory> _categories = [
  _ResourceCategory(
    name: '国家教育平台',
    icon: Icons.account_balance_rounded,
    color: AppColors.primary,
    resources: [
      _Resource(
        name: '国家中小学智慧教育平台',
        url: 'https://basic.smartedu.cn',
        description: '教育部官方资源，覆盖全学科',
      ),
      _Resource(
        name: '中国教育在线',
        url: 'https://www.eol.cn',
        description: '教育资讯与学习资源',
      ),
      _Resource(
        name: '学科网',
        url: 'https://www.zxxk.com',
        description: '全学科教学资源',
      ),
    ],
  ),
  _ResourceCategory(
    name: '数学学习',
    icon: Icons.calculate_rounded,
    color: AppColors.intellect,
    resources: [
      _Resource(
        name: '洋葱学园',
        url: 'https://yangcong345.com',
        description: '动画讲解数学概念',
      ),
      _Resource(
        name: '可汗学院(中文)',
        url: 'https://zh.khanacademy.org',
        description: '免费视频课程',
      ),
    ],
  ),
  _ResourceCategory(
    name: '语文阅读',
    icon: Icons.menu_book_rounded,
    color: AppColors.moral,
    resources: [
      _Resource(
        name: '古诗文网',
        url: 'https://www.gushiwen.cn',
        description: '古诗词大全与赏析',
      ),
      _Resource(
        name: '中华经典资源库',
        url: 'https://resource.chinesestudy.cn',
        description: '国学经典',
      ),
    ],
  ),
  _ResourceCategory(
    name: '英语学习',
    icon: Icons.translate_rounded,
    color: AppColors.logic,
    resources: [
      _Resource(
        name: '可可英语',
        url: 'https://www.kekenet.com',
        description: '听力与阅读练习',
      ),
      _Resource(
        name: '沪江英语',
        url: 'https://www.hjenglish.com',
        description: '英语学习社区',
      ),
    ],
  ),
  _ResourceCategory(
    name: '科学探索',
    icon: Icons.science_rounded,
    color: AppColors.general,
    resources: [
      _Resource(
        name: '中国科普博览',
        url: 'https://www.kepu.net.cn',
        description: '中科院科普平台',
      ),
      _Resource(
        name: '果壳网',
        url: 'https://www.guokr.com',
        description: '科技趣味知识',
      ),
    ],
  ),
  _ResourceCategory(
    name: '编程学习',
    icon: Icons.code_rounded,
    color: AppColors.tech,
    resources: [
      _Resource(
        name: '编程猫',
        url: 'https://www.codemao.cn',
        description: '青少年编程平台',
      ),
      _Resource(
        name: '扣叮',
        url: 'https://coding.qq.com',
        description: '腾讯青少年编程',
      ),
    ],
  ),
];

/// 学习资源页面 — 提供分类整理的优质教育网站链接。
class LearningResourcesScreen extends StatelessWidget {
  const LearningResourcesScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开链接: $url')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('无法打开链接: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习资源'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategorySection(
            category: category,
            theme: theme,
            onResourceTap: (url) => _openUrl(context, url),
          );
        },
      ),
    );
  }
}

/// 单个分类区块，包含标题和资源卡片列表。
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.theme,
    required this.onResourceTap,
  });

  final _ResourceCategory category;
  final ThemeData theme;
  final ValueChanged<String> onResourceTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分类标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category.icon,
                  size: 22,
                  color: category.color,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: category.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 资源卡片
          ...category.resources.map(
            (resource) => _ResourceCard(
              resource: resource,
              color: category.color,
              theme: theme,
              onTap: () => onResourceTap(resource.url),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个资源卡片 — 显示名称、描述和外链图标。
class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  final _Resource resource;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // 左侧圆形图标
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language_rounded,
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 名称与描述
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          resource.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 右侧箭头
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: color.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
