import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/gamification/growth_tree.dart';

/// 成长树可视化组件。
/// 根据当前成长阶段绘制不同形态的树，并显示经验进度条。
class GrowthTreeWidget extends ConsumerWidget {
  const GrowthTreeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeState = ref.watch(growthTreeProvider);

    return GestureDetector(
      onTap: () => _showDetailDialog(context, treeState),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.park, color: AppColors.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '我的成长树',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    treeState.stage.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.tertiaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 树的绘制区域
            SizedBox(
              height: 160,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 800),
                child: CustomPaint(
                  key: ValueKey(treeState.stage),
                  size: const Size(double.infinity, 160),
                  painter: _GrowthTreePainter(
                    stage: treeState.stage,
                    progress: treeState.stageProgress,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 经验进度条
            _ExperienceBar(
              experience: treeState.experience,
              progress: treeState.stageProgress,
              toNext: treeState.experienceToNextStage,
            ),
          ],
        ),
      ),
    );
  }

  /// 显示成长树详情对话框
  void _showDetailDialog(BuildContext context, GrowthTreeState treeState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.park, color: AppColors.tertiary),
            const SizedBox(width: 8),
            const Text('成长树详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: '当前阶段', value: treeState.stage.label),
            _DetailRow(label: '总经验值', value: '${treeState.experience}'),
            _DetailRow(label: '水滴数', value: '${treeState.waterDrops}'),
            _DetailRow(label: '阳光数', value: '${treeState.sunshine}'),
            _DetailRow(label: '连续奖励', value: '${treeState.streakBonus}'),
            if (treeState.experienceToNextStage > 0)
              _DetailRow(
                label: '距下一阶段',
                value: '还需 ${treeState.experienceToNextStage} 经验',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 详情行组件
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// 经验进度条组件
class _ExperienceBar extends StatelessWidget {
  const _ExperienceBar({
    required this.experience,
    required this.progress,
    required this.toNext,
  });

  final int experience;
  final double progress;
  final int toNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '经验: $experience',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            if (toNext > 0)
              Text(
                '还需 $toNext',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
          ),
        ),
      ],
    );
  }
}

/// 成长树画笔，根据不同阶段绘制不同形态的树。
class _GrowthTreePainter extends CustomPainter {
  _GrowthTreePainter({required this.stage, required this.progress});

  /// 当前阶段
  final TreeStage stage;

  /// 当前阶段内的进度
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final groundY = size.height - 20;

    // 绘制地面
    _drawGround(canvas, size, groundY);

    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas, cx, groundY);
      case TreeStage.sprout:
        _drawSprout(canvas, cx, groundY);
      case TreeStage.sapling:
        _drawSapling(canvas, cx, groundY);
      case TreeStage.youngTree:
        _drawYoungTree(canvas, cx, groundY);
      case TreeStage.tree:
        _drawTree(canvas, cx, groundY);
      case TreeStage.floweringTree:
        _drawFloweringTree(canvas, cx, groundY);
      case TreeStage.fruitTree:
        _drawFruitTree(canvas, cx, groundY);
    }
  }

  /// 绘制地面
  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY, size.width, 20),
        const Radius.circular(10),
      ),
      groundPaint,
    );

    // 草地层
    final grassPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, groundY - 4, size.width, 8),
        const Radius.circular(4),
      ),
      grassPaint,
    );
  }

  /// 种子：泥土中的小棕色圆点
  void _drawSeed(Canvas canvas, double cx, double groundY) {
    final seedPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, groundY - 2), width: 12, height: 8),
      seedPaint,
    );
  }

  /// 发芽：小绿色嫩芽
  void _drawSprout(Canvas canvas, double cx, double groundY) {
    final stemPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 茎
    canvas.drawLine(
      Offset(cx, groundY - 4),
      Offset(cx, groundY - 30),
      stemPaint,
    );

    // 两片小叶子
    final leafPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - 8, groundY - 25), width: 14, height: 8),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + 8, groundY - 28), width: 14, height: 8),
      leafPaint,
    );
  }

  /// 小树苗：细树干 + 少量叶子
  void _drawSapling(Canvas canvas, double cx, double groundY) {
    _drawTrunk(canvas, cx, groundY, height: 50, width: 6);
    _drawLeaves(canvas, cx, groundY - 50, radius: 20, count: 5);
  }

  /// 小树：中等树干 + 更多叶子
  void _drawYoungTree(Canvas canvas, double cx, double groundY) {
    _drawTrunk(canvas, cx, groundY, height: 70, width: 10);
    // 简单树枝
    _drawBranch(canvas, cx, groundY - 45, -25, -15, width: 4);
    _drawBranch(canvas, cx, groundY - 55, 25, -10, width: 4);
    _drawLeaves(canvas, cx, groundY - 70, radius: 30, count: 8);
  }

  /// 大树：粗壮树干 + 树冠
  void _drawTree(Canvas canvas, double cx, double groundY) {
    _drawTrunk(canvas, cx, groundY, height: 85, width: 14);
    _drawBranch(canvas, cx, groundY - 50, -30, -20, width: 6);
    _drawBranch(canvas, cx, groundY - 60, 35, -15, width: 6);
    _drawBranch(canvas, cx, groundY - 70, -20, -10, width: 4);
    _drawCanopy(canvas, cx, groundY - 85, radiusX: 50, radiusY: 35);
  }

  /// 开花树：大树 + 粉色花朵
  void _drawFloweringTree(Canvas canvas, double cx, double groundY) {
    _drawTrunk(canvas, cx, groundY, height: 90, width: 14);
    _drawBranch(canvas, cx, groundY - 50, -30, -20, width: 6);
    _drawBranch(canvas, cx, groundY - 60, 35, -15, width: 6);
    _drawBranch(canvas, cx, groundY - 70, -20, -10, width: 4);
    _drawCanopy(canvas, cx, groundY - 90, radiusX: 55, radiusY: 38);
    _drawFlowers(canvas, cx, groundY - 90, radius: 50);
  }

  /// 结果树：大树 + 彩色果实
  void _drawFruitTree(Canvas canvas, double cx, double groundY) {
    _drawTrunk(canvas, cx, groundY, height: 90, width: 16);
    _drawBranch(canvas, cx, groundY - 50, -35, -20, width: 7);
    _drawBranch(canvas, cx, groundY - 60, 38, -15, width: 7);
    _drawBranch(canvas, cx, groundY - 72, -22, -10, width: 5);
    _drawCanopy(canvas, cx, groundY - 90, radiusX: 58, radiusY: 40);
    _drawFruits(canvas, cx, groundY - 90, radius: 50);
  }

  /// 绘制树干
  void _drawTrunk(Canvas canvas, double cx, double groundY,
      {required double height, required double width}) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, groundY - height / 2),
            width: width,
            height: height),
        Radius.circular(width / 3),
      ),
      trunkPaint,
    );
  }

  /// 绘制树枝
  void _drawBranch(Canvas canvas, double cx, double y, double dx, double dy,
      {required double width}) {
    final branchPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, y), Offset(cx + dx, y + dy), branchPaint);
  }

  /// 绘制散落的叶子（圆形）
  void _drawLeaves(Canvas canvas, double cx, double cy,
      {required double radius, required int count}) {
    final leafPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;
    final darkLeafPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.fill;

    final rng = Random(42); // 固定种子保证一致性
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;
      final r = radius * (0.5 + rng.nextDouble() * 0.5);
      final lx = cx + cos(angle) * r;
      final ly = cy + sin(angle) * r * 0.6;
      final leafR = 8.0 + rng.nextDouble() * 6;
      canvas.drawCircle(
          Offset(lx, ly), leafR, i.isEven ? leafPaint : darkLeafPaint);
    }
  }

  /// 绘制树冠（大椭圆）
  void _drawCanopy(Canvas canvas, double cx, double cy,
      {required double radiusX, required double radiusY}) {
    // 底层深色
    final darkPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy + 4),
          width: radiusX * 2,
          height: radiusY * 2),
      darkPaint,
    );

    // 上层亮色
    final lightPaint = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, cy - 2),
          width: radiusX * 1.8,
          height: radiusY * 1.6),
      lightPaint,
    );

    // 高光
    final highlightPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - radiusX * 0.2, cy - radiusY * 0.3),
          width: radiusX * 0.8,
          height: radiusY * 0.7),
      highlightPaint,
    );
  }

  /// 绘制花朵
  void _drawFlowers(Canvas canvas, double cx, double cy,
      {required double radius}) {
    final flowerPaint = Paint()
      ..color = const Color(0xFFF48FB1)
      ..style = PaintingStyle.fill;
    final centerPaint = Paint()
      ..color = const Color(0xFFFFEB3B)
      ..style = PaintingStyle.fill;

    final rng = Random(123);
    const flowerCount = 8;
    for (var i = 0; i < flowerCount; i++) {
      final angle = (i / flowerCount) * 2 * pi + 0.3;
      final r = radius * (0.4 + rng.nextDouble() * 0.5);
      final fx = cx + cos(angle) * r;
      final fy = cy + sin(angle) * r * 0.6;
      // 花瓣
      canvas.drawCircle(Offset(fx, fy), 5, flowerPaint);
      // 花心
      canvas.drawCircle(Offset(fx, fy), 2, centerPaint);
    }
  }

  /// 绘制果实
  void _drawFruits(Canvas canvas, double cx, double cy,
      {required double radius}) {
    final fruitColors = [
      const Color(0xFFE53935), // 红色
      const Color(0xFFFF9800), // 橙色
      const Color(0xFFFFEB3B), // 黄色
    ];

    final rng = Random(456);
    const fruitCount = 7;
    for (var i = 0; i < fruitCount; i++) {
      final angle = (i / fruitCount) * 2 * pi + 0.5;
      final r = radius * (0.3 + rng.nextDouble() * 0.6);
      final fx = cx + cos(angle) * r;
      final fy = cy + sin(angle) * r * 0.6;
      final paint = Paint()
        ..color = fruitColors[i % fruitColors.length]
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(fx, fy), 5, paint);
      // 果实高光
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha:0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(fx - 1.5, fy - 1.5), 2, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthTreePainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.progress != progress;
}
