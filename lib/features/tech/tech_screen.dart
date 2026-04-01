import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';

/// 科技探索模块的子模块信息数据类。
class _SubModuleInfo {
  const _SubModuleInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

/// 科技探索子模块列表定义。
const List<_SubModuleInfo> _subModules = [
  _SubModuleInfo(
    id: 'programming',
    title: '编程练习场',
    subtitle: '学习编程基础',
    icon: Icons.code_rounded,
    color: Color(0xFF5C6BC0),
  ),
  _SubModuleInfo(
    id: 'ai_intro',
    title: 'AI 科普',
    subtitle: '了解人工智能',
    icon: Icons.smart_toy_rounded,
    color: Color(0xFF26A69A),
  ),
  _SubModuleInfo(
    id: 'virtual_lab',
    title: '虚拟实验室',
    subtitle: '动手做实验',
    icon: Icons.science_rounded,
    color: Color(0xFFEF5350),
  ),
  _SubModuleInfo(
    id: 'aerospace',
    title: '航天航空',
    subtitle: '探索宇宙奥秘',
    icon: Icons.rocket_rounded,
    color: Color(0xFFFF7043),
  ),
  _SubModuleInfo(
    id: 'tech_timeline',
    title: '科技时间线',
    subtitle: '科技发展历程',
    icon: Icons.timeline_rounded,
    color: Color(0xFF42A5F5),
  ),
];

/// 科技探索模块主页面。
///
/// 顶部显示紫色主题的模块标题栏，下方使用网格布局展示各子模块卡片。
/// 点击卡片可导航至对应的子模块页面。
class TechScreen extends ConsumerWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 顶部紫色主题标题栏
          _buildHeader(theme),
          // 子模块网格
          _buildSubModuleGrid(context, theme),
        ],
      ),
    );
  }

  /// 构建顶部渐变标题栏，包含火箭图标和模块标题。
  SliverToBoxAdapter _buildHeader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tech,
              Color(0xFF9C27B0),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          children: [
            // 火箭图标容器
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // 标题文字
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '科技探索',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '探索科技世界的奥秘',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha:0.85),
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

  /// 构建子模块网格，每个卡片展示图标、标题和副标题。
  SliverPadding _buildSubModuleGrid(BuildContext context, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.92,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final info = _subModules[index];
            return _SubModuleCard(
              info: info,
              onTap: () => _navigateToSubModule(context, info.id),
            );
          },
          childCount: _subModules.length,
        ),
      ),
    );
  }

  /// 根据子模块 ID 导航到对应页面。
  void _navigateToSubModule(BuildContext context, String subModuleId) {
    context.push('/module/tech/$subModuleId');
  }
}

/// 子模块卡片组件。
///
/// 显示带有主题色图标、标题和副标题的圆角卡片，支持点击交互。
class _SubModuleCard extends StatelessWidget {
  const _SubModuleCard({
    required this.info,
    required this.onTap,
  });

  final _SubModuleInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: info.color.withValues(alpha:0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标容器
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  info.icon,
                  color: info.color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              // 标题
              Text(
                info.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // 副标题
              Text(
                info.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
