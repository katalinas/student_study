import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 展示今日关键学习统计的水平栏：答题数、正确率和连续天数。
class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.answeredToday,
    required this.correctRate,
    required this.streakDays,
  });

  /// 今日答题数量。
  final int answeredToday;

  /// 今日正确率（0.0 - 1.0）。
  final double correctRate;

  /// 连续活跃天数。
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            label: '今日答题',
            value: '$answeredToday',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            icon: Icons.percent,
            iconColor: AppColors.info,
            label: '正确率',
            value: '${(correctRate * 100).round()}%',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatItem(
            icon: Icons.local_fire_department,
            iconColor: AppColors.streakFlame,
            label: '连续天数',
            value: '$streakDays',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
