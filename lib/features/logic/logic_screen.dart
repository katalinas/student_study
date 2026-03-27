/// 逻辑训练营主页面，展示岛屿地图风格的训练区域选择界面。
///
/// 包含四个主题岛屿：规律岛、推理城、策略谷、空间站，
/// 岛屿之间通过虚线路径连接，呈现冒险地图的视觉效果。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';

// ---------------------------------------------------------------------------
// 岛屿数据模型
// ---------------------------------------------------------------------------

/// 描述逻辑训练地图中单个岛屿的不可变数据类。
class _IslandInfo {
  const _IslandInfo({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.completedLevels,
    required this.totalLevels,
    required this.isUnlocked,
    required this.alignment,
  });

  /// 岛屿唯一标识，用于路由导航
  final String id;

  /// 岛屿名称
  final String name;

  /// 岛屿副标题（训练类型说明）
  final String subtitle;

  /// 显示图标
  final IconData icon;

  /// 主题颜色
  final Color color;

  /// 已完成关卡数
  final int completedLevels;

  /// 总关卡数
  final int totalLevels;

  /// 是否已解锁
  final bool isUnlocked;

  /// 在地图中的水平对齐位置（-1.0到1.0）
  final double alignment;
}

// ---------------------------------------------------------------------------
// 逻辑训练营主页面
// ---------------------------------------------------------------------------

/// 逻辑训练营的主入口页面。
///
/// 采用岛屿地图主题，展示四个训练区域作为可探索的"岛屿"，
/// 并通过虚线路径将它们连接起来，营造冒险地图的视觉感受。
class LogicScreen extends ConsumerWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 当前所有岛屿默认解锁，后续可接入进度系统控制解锁逻辑
    final islands = [
      const _IslandInfo(
        id: 'pattern',
        name: '规律岛',
        subtitle: '模式识别',
        icon: Icons.pattern,
        color: Color(0xFF43A047),
        completedLevels: 0,
        totalLevels: 20,
        isUnlocked: true,
        alignment: -0.4,
      ),
      const _IslandInfo(
        id: 'deduction',
        name: '推理城',
        subtitle: '演绎推理',
        icon: Icons.lightbulb_rounded,
        color: Color(0xFF1E88E5),
        completedLevels: 0,
        totalLevels: 20,
        isUnlocked: true,
        alignment: 0.4,
      ),
      const _IslandInfo(
        id: 'strategy',
        name: '策略谷',
        subtitle: '策略游戏',
        icon: Icons.extension_rounded,
        color: Color(0xFFFB8C00),
        completedLevels: 0,
        totalLevels: 20,
        isUnlocked: true,
        alignment: -0.3,
      ),
      const _IslandInfo(
        id: 'spatial',
        name: '空间站',
        subtitle: '空间思维',
        icon: Icons.view_in_ar_rounded,
        color: Color(0xFF8E24AA),
        completedLevels: 0,
        totalLevels: 20,
        isUnlocked: true,
        alignment: 0.3,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildIslandMap(context, islands),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建页面顶部标题栏，包含模块名称和图标。
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.logic, Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '逻辑训练营',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '探索思维的奥秘',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建岛屿地图区域，包含虚线路径连接和可交互的岛屿卡片。
  Widget _buildIslandMap(BuildContext context, List<_IslandInfo> islands) {
    return CustomPaint(
      painter: _DottedPathPainter(
        islandCount: islands.length,
        alignments: islands.map((i) => i.alignment).toList(),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            for (int i = 0; i < islands.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              Align(
                alignment: Alignment(islands[i].alignment, 0),
                child: _IslandCard(
                  island: islands[i],
                  onTap: () => _navigateToIsland(context, islands[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 导航至选中的岛屿详情页面。
  void _navigateToIsland(BuildContext context, _IslandInfo island) {
    if (!island.isUnlocked) return;

    final route = '/module/logic/${island.id}';
    context.push(route);
  }
}

// ---------------------------------------------------------------------------
// 虚线路径绘制器
// ---------------------------------------------------------------------------

/// 在岛屿之间绘制虚线连接路径的自定义画笔。
class _DottedPathPainter extends CustomPainter {
  const _DottedPathPainter({
    required this.islandCount,
    required this.alignments,
  });

  /// 岛屿数量
  final int islandCount;

  /// 每个岛屿的水平对齐值列表
  final List<double> alignments;

  @override
  void paint(Canvas canvas, Size size) {
    if (islandCount < 2) return;

    final paint = Paint()
      ..color = AppColors.logic.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // 计算每个岛屿卡片中心的垂直位置（含间距）
    const cardHeight = 100.0;
    const spacing = 16.0;
    const topPadding = 20.0;

    for (int i = 0; i < islandCount - 1; i++) {
      final startY = topPadding + i * (cardHeight + spacing) + cardHeight / 2;
      final endY =
          topPadding + (i + 1) * (cardHeight + spacing) + cardHeight / 2;

      // 根据对齐值计算水平位置
      final startX = size.width / 2 + alignments[i] * size.width / 3;
      final endX = size.width / 2 + alignments[i + 1] * size.width / 3;

      // 绘制虚线贝塞尔曲线
      _drawDottedCurve(
        canvas,
        paint,
        Offset(startX, startY),
        Offset(endX, endY),
      );
    }
  }

  /// 绘制由短线段组成的虚线曲线。
  void _drawDottedCurve(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
  ) {
    const dashLength = 6.0;
    const gapLength = 4.0;

    // 计算贝塞尔曲线的控制点
    final midY = (start.dy + end.dy) / 2;
    final controlX = (start.dx + end.dx) / 2;
    final controlPoint1 = Offset(start.dx, midY);
    final controlPoint2 = Offset(controlX, midY);

    // 沿曲线采样绘制虚线段
    const steps = 60;
    var drawDash = true;
    var dashRemaining = dashLength;

    for (int step = 0; step < steps; step++) {
      final t1 = step / steps;
      final t2 = (step + 1) / steps;

      final p1 = _cubicBezier(t1, start, controlPoint1, controlPoint2, end);
      final p2 = _cubicBezier(t2, start, controlPoint1, controlPoint2, end);

      final segmentLength =
          math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));

      if (drawDash) {
        canvas.drawLine(p1, p2, paint);
      }

      dashRemaining -= segmentLength;
      if (dashRemaining <= 0) {
        drawDash = !drawDash;
        dashRemaining = drawDash ? dashLength : gapLength;
      }
    }
  }

  /// 计算三次贝塞尔曲线上参数 t 对应的点坐标。
  Offset _cubicBezier(
    double t,
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
  ) {
    final oneMinusT = 1.0 - t;
    final oneMinusT2 = oneMinusT * oneMinusT;
    final oneMinusT3 = oneMinusT2 * oneMinusT;
    final t2 = t * t;
    final t3 = t2 * t;

    return Offset(
      oneMinusT3 * p0.dx +
          3 * oneMinusT2 * t * p1.dx +
          3 * oneMinusT * t2 * p2.dx +
          t3 * p3.dx,
      oneMinusT3 * p0.dy +
          3 * oneMinusT2 * t * p1.dy +
          3 * oneMinusT * t2 * p2.dy +
          t3 * p3.dy,
    );
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter oldDelegate) =>
      islandCount != oldDelegate.islandCount;
}

// ---------------------------------------------------------------------------
// 岛屿卡片组件
// ---------------------------------------------------------------------------

/// 地图中单个岛屿的可交互卡片。
///
/// 展示岛屿名称、图标、进度和锁定状态，
/// 解锁状态下可点击进入对应训练区域。
class _IslandCard extends StatelessWidget {
  const _IslandCard({
    required this.island,
    required this.onTap,
  });

  final _IslandInfo island;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = !island.isUnlocked;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked
              ? Colors.grey.shade200
              : island.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isLocked
                ? Colors.grey.shade300
                : island.color.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: island.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 岛屿图标
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey.shade300
                    : island.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock_rounded : island.icon,
                color: isLocked ? Colors.grey.shade500 : island.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),

            // 岛屿名称
            Text(
              island.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isLocked ? Colors.grey.shade500 : island.color,
              ),
            ),
            const SizedBox(height: 2),

            // 副标题
            Text(
              island.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isLocked
                    ? Colors.grey.shade400
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // 进度显示
            Text(
              isLocked
                  ? '未解锁'
                  : '${island.completedLevels}/${island.totalLevels}关',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.grey.shade400 : island.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
