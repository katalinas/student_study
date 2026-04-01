import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 首页顶部显示的卡片，展示每日名言或诗句、签到按钮和当前连续天数。
class DailyCheckIn extends StatelessWidget {
  const DailyCheckIn({
    super.key,
    required this.isCheckedIn,
    required this.streakDays,
    required this.onCheckIn,
  });

  /// 用户今天是否已签到。
  final bool isCheckedIn;

  /// 用户连续签到的天数。
  final int streakDays;

  /// 用户点击签到按钮时调用。
  final VoidCallback onCheckIn;

  /// 按日期索引轮换的示例名言。
  static const List<String> _quotes = [
    '学而时习之，不亦说乎？',
    '千里之行，始于足下。',
    '书山有路勤为径，学海无涯苦作舟。',
    '不积跬步，无以至千里。',
    '温故而知新，可以为师矣。',
    '少壮不努力，老大徒伤悲。',
    '读书破万卷，下笔如有神。',
  ];

  String get _todayQuote {
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year),
    ).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.moralLight,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 区域标题
            Row(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: AppColors.moral,
                ),
                const SizedBox(width: 8),
                Text(
                  '每日签到',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.moral,
                  ),
                ),
                const Spacer(),
                // 连续天数徽章
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.streakFlame.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.streakFlame,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays天',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.streakFlame,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 名言
            Text(
              _todayQuote,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),

            // 签到按钮
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isCheckedIn ? null : onCheckIn,
                icon: Icon(
                  isCheckedIn ? Icons.check_circle : Icons.touch_app,
                  size: 18,
                ),
                label: Text(isCheckedIn ? '已签到' : '点击签到'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.moral,
                  disabledBackgroundColor:
                      AppColors.moral.withValues(alpha:0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
