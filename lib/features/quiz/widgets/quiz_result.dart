// 测验完成结果展示组件。
//
// 显示得分、正确/错误/跳过统计、用时、星级评定，
// 以及"再来一次"和"返回"操作按钮。
// 高分（>80%）时显示庆祝装饰效果。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/app/theme/text_styles.dart';
import 'package:student_study/core/engine/quiz_engine.dart';

/// 测验结果卡片组件。
class QuizResult extends StatefulWidget {
  const QuizResult({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onBack,
  });

  /// 测验最终状态。
  final QuizState state;

  /// "再来一次"回调。
  final VoidCallback onRetry;

  /// "返回"回调。
  final VoidCallback onBack;

  @override
  State<QuizResult> createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.state.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 根据正确率计算星级（1-5 星）。
  int _calculateStars() {
    if (widget.state.totalQuestions == 0) return 0;
    final percentage =
        widget.state.correctCount / widget.state.totalQuestions * 100;
    if (percentage >= 95) return 5;
    if (percentage >= 80) return 4;
    if (percentage >= 60) return 3;
    if (percentage >= 40) return 2;
    return 1;
  }

  /// 判断是否为高分（>80%）。
  bool _isHighScore() {
    if (widget.state.totalQuestions == 0) return false;
    return widget.state.correctCount / widget.state.totalQuestions > 0.8;
  }

  /// 格式化用时显示。
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stars = _calculateStars();
    final isHighScore = _isHighScore();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 高分庆祝装饰
          if (isHighScore) _buildCelebration(theme),
          const SizedBox(height: 16),
          // 结果标题
          Text(
            isHighScore ? '太棒了！' : '继续加油！',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isHighScore ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          // 分数动画展示
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Text(
                '${_scoreAnimation.value.toInt()}',
                style: AppTextStyles.scoreDisplay.copyWith(
                  fontSize: 64,
                  color: AppColors.xpGold,
                ),
              );
            },
          ),
          Text(
            '总分',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // 星级评定
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  index < stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 36,
                  color: index < stars
                      ? AppColors.achievementStar
                      : AppColors.divider,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          // 统计数据卡片
          _buildStatsCard(theme),
          const SizedBox(height: 32),
          // 操作按钮
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  /// 构建高分庆祝装饰。
  Widget _buildCelebration(ThemeData theme) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 装饰圆点（模拟彩纸效果）
          for (int i = 0; i < 12; i++)
            Positioned(
              left: (i % 4) * 80.0 + 20,
              top: (i ~/ 4) * 25.0,
              child: Transform.rotate(
                angle: i * 0.5,
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: [
                    AppColors.xpGold,
                    AppColors.primary,
                    AppColors.success,
                    AppColors.secondary,
                  ][i % 4]
                      .withValues(alpha:0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建统计数据卡片。
  Widget _buildStatsCard(ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 正确数
            _StatRow(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.success,
              label: '正确',
              value: '${widget.state.correctCount}',
            ),
            const Divider(height: 20),
            // 错误数
            _StatRow(
              icon: Icons.cancel_outlined,
              iconColor: AppColors.error,
              label: '错误',
              value: '${widget.state.incorrectCount}',
            ),
            const Divider(height: 20),
            // 跳过数
            _StatRow(
              icon: Icons.skip_next_outlined,
              iconColor: AppColors.warning,
              label: '跳过',
              value: '${widget.state.skippedCount}',
            ),
            const Divider(height: 20),
            // 用时
            _StatRow(
              icon: Icons.timer_outlined,
              iconColor: AppColors.info,
              label: '用时',
              value: _formatTime(widget.state.elapsedSeconds),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮组。
  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "再来一次"主要按钮
        FilledButton.icon(
          onPressed: widget.onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('再来一次'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // "返回"次要按钮
        OutlinedButton.icon(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('返回'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: AppColors.divider),
            textStyle: theme.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

/// 统计行组件。
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
