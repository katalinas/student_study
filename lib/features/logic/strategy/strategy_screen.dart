/// 策略谷页面，展示可用的策略类游戏列表。
///
/// 提供数独、24点、华容道、汉诺塔等经典策略游戏入口，
/// 每个游戏卡片展示游戏名称、图标、描述和难度范围。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';

// ---------------------------------------------------------------------------
// 游戏数据模型
// ---------------------------------------------------------------------------

/// 描述策略谷中单个游戏的不可变数据类。
class _GameInfo {
  const _GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficultyMin,
    required this.difficultyMax,
  });

  /// 游戏唯一标识
  final String id;

  /// 游戏名称
  final String name;

  /// 游戏简介
  final String description;

  /// 显示图标
  final IconData icon;

  /// 主题颜色
  final Color color;

  /// 最低难度等级
  final int difficultyMin;

  /// 最高难度等级
  final int difficultyMax;
}

/// 策略谷中的全部游戏列表
const List<_GameInfo> _games = [
  _GameInfo(
    id: 'sudoku',
    name: '数独',
    description: '用数字填满格子',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF5C6BC0),
    difficultyMin: 1,
    difficultyMax: 5,
  ),
  _GameInfo(
    id: 'twenty_four',
    name: '24点',
    description: '四则运算凑24',
    icon: Icons.calculate_rounded,
    color: Color(0xFFEF5350),
    difficultyMin: 1,
    difficultyMax: 4,
  ),
  _GameInfo(
    id: 'klotski',
    name: '华容道',
    description: '移动方块解谜',
    icon: Icons.swap_calls_rounded,
    color: Color(0xFF26A69A),
    difficultyMin: 2,
    difficultyMax: 5,
  ),
  _GameInfo(
    id: 'hanoi',
    name: '汉诺塔',
    description: '移动圆盘',
    icon: Icons.stacked_bar_chart_rounded,
    color: Color(0xFFFFA726),
    difficultyMin: 1,
    difficultyMax: 5,
  ),
];

// ---------------------------------------------------------------------------
// 策略谷主页面
// ---------------------------------------------------------------------------

/// 策略谷游戏列表页面。
///
/// 展示所有可用的策略类游戏，用户可点击游戏卡片
/// 进入对应的游戏界面。
class StrategyScreen extends ConsumerWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _games.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _GameCard(
                    game: game,
                    onTap: () => _navigateToGame(context, game),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建页面顶部标题栏。
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)],
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

          // 区域图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.extension_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '策略谷',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '挑战经典策略游戏',
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

  /// 导航至选中的游戏页面。
  void _navigateToGame(BuildContext context, _GameInfo game) {
    if (game.id == 'sudoku') {
      // 使用已注册的路由 /module/logic/sudoku，避免导航到未注册路由崩溃
      context.push('/module/logic/sudoku');
    }
    // 其他游戏待实现，点击暂不跳转
  }
}

// ---------------------------------------------------------------------------
// 游戏卡片组件
// ---------------------------------------------------------------------------

/// 游戏列表中的单个游戏卡片。
///
/// 展示游戏图标、名称、描述和难度范围星级指示。
class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onTap,
  });

  final _GameInfo game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: game.color.withValues(alpha:0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: game.color.withValues(alpha:0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 游戏图标
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: game.color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(game.icon, color: game.color, size: 28),
            ),
            const SizedBox(width: 14),

            // 游戏信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 难度星级指示
                  _buildDifficultyIndicator(theme),
                ],
              ),
            ),

            // 右侧箭头
            Icon(
              Icons.chevron_right_rounded,
              color: game.color.withValues(alpha:0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建难度范围的星级指示器。
  Widget _buildDifficultyIndicator(ThemeData theme) {
    return Row(
      children: [
        Text(
          '难度 ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              Icons.star_rounded,
              size: 14,
              color: i >= game.difficultyMin && i <= game.difficultyMax
                  ? game.color
                  : Colors.grey.shade300,
            ),
          ),
      ],
    );
  }
}
