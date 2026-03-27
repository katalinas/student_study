// 智育模块主页面。
//
// 展示数学、语文、英语三个学科卡片入口，
// 每个卡片显示学科名称、年级描述、题目数量和"开始学习"按钮。
// 点击学科卡片导航至对应的学科详情页面。
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';

/// 智育模块首页，展示三个学科入口。
class IntellectModuleScreen extends StatelessWidget {
  const IntellectModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部标题栏
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.intellect,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '智育',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.intellect,
                      AppColors.intellect.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 学科列表
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                // 数学学科卡片
                _SubjectCard(
                  icon: Icons.calculate_rounded,
                  name: '数学',
                  description: '培养逻辑思维与计算能力',
                  questionCount: 120,
                  color: const Color(0xFF1565C0),
                  onTap: () => context.push('/module/intellect/math'),
                ),
                const SizedBox(height: 16),
                // 语文学科卡片
                _SubjectCard(
                  icon: Icons.menu_book_rounded,
                  name: '语文',
                  description: '提升阅读理解与写作表达',
                  questionCount: 95,
                  color: const Color(0xFFC62828),
                  onTap: () => context.push('/module/intellect/chinese'),
                ),
                const SizedBox(height: 16),
                // 英语学科卡片
                _SubjectCard(
                  icon: Icons.translate_rounded,
                  name: '英语',
                  description: '掌握英语基础词汇与语法',
                  questionCount: 80,
                  color: const Color(0xFF2E7D32),
                  onTap: () => context.push('/module/intellect/english'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 学科卡片组件。
class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.icon,
    required this.name,
    required this.description,
    required this.questionCount,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final String description;
  final int questionCount;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 学科图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              // 学科信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 题目数量标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$questionCount 道题目',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // "开始学习"箭头
              Column(
                children: [
                  FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '开始学习',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
