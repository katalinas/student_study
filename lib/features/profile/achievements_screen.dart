import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/gamification/achievement.dart';

/// 成就/徽章展示页面，以网格形式展示所有成就。
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementState = ref.watch(achievementProvider);
    final achievements = achievementState.achievements;
    final unlockedCount = achievementState.unlocked.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的成就'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$unlockedCount/${achievements.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.xpGold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _AchievementBadge(
            achievement: achievement,
            onTap: () => _showDetail(context, achievement),
          );
        },
      ),
    );
  }

  /// 显示成就详情对话框
  void _showDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _iconFromName(achievement.iconName),
              color: achievement.isUnlocked
                  ? AppColors.achievementStar
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                achievement.isUnlocked ? achievement.name : '???',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // 进度条
            if (!achievement.isUnlocked && achievement.targetCount > 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '进度',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    '${achievement.currentCount}/${achievement.targetCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.achievementStar),
                ),
              ),
            ],

            // 解锁时间
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                '解锁于 ${_formatDate(achievement.unlockedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],

            // 未解锁提示
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 8),
              Text(
                '继续努力，即可解锁此成就！',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
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

  /// 格式化日期
  String _formatDate(DateTime dt) {
    return '${dt.year}年${dt.month}月${dt.day}日';
  }
}

/// 单个成就徽章组件
class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({
    required this.achievement,
    this.onTap,
  });

  final Achievement achievement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppColors.xpGold.withValues(alpha: 0.08)
              : AppColors.divider.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? AppColors.achievementStar.withValues(alpha: 0.4)
                : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? AppColors.achievementStar.withValues(alpha: 0.2)
                    : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconFromName(achievement.iconName),
                size: 24,
                color: isUnlocked
                    ? AppColors.achievementStar
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),

            // 名称
            Text(
              isUnlocked ? achievement.name : '???',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 解锁日期或进度条
            const SizedBox(height: 4),
            if (isUnlocked && achievement.unlockedAt != null)
              Text(
                '${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
              )
            else if (!isUnlocked && achievement.targetCount > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    minHeight: 4,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.achievementStar),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 根据图标名称字符串获取 IconData。
/// 仅映射成就系统中使用的图标。
IconData _iconFromName(String name) {
  switch (name) {
    case 'login':
      return Icons.login;
    case 'quiz':
      return Icons.quiz;
    case 'local_fire_department':
      return Icons.local_fire_department;
    case 'whatshot':
      return Icons.whatshot;
    case 'military_tech':
      return Icons.military_tech;
    case 'star':
      return Icons.star;
    case 'star_half':
      return Icons.star_half;
    case 'stars':
      return Icons.stars;
    case 'emoji_events':
      return Icons.emoji_events;
    case 'calculate':
      return Icons.calculate;
    case 'menu_book':
      return Icons.menu_book;
    case 'translate':
      return Icons.translate;
    case 'psychology':
      return Icons.psychology;
    case 'science':
      return Icons.science;
    case 'auto_stories':
      return Icons.auto_stories;
    default:
      return Icons.emoji_events;
  }
}
