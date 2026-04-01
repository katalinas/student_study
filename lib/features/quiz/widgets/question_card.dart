// 可复用的题目展示卡片组件。
//
// 显示题干文本、题干图片、难度星级和分值。
// 适配所有题目子类型，统一展示题目元信息。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/models/question.dart';

/// 题目卡片，突出显示题干内容与元信息。
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  /// 当前展示的题目。
  final Question question;

  /// 当前题号（从 1 开始）。
  final int questionNumber;

  /// 题目总数。
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 题号与元信息行
            Row(
              children: [
                // 题号标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '第 $questionNumber / $totalQuestions 题',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // 难度星级
                _DifficultyStars(difficulty: question.difficulty),
                const SizedBox(width: 12),
                // 分值
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${question.points}分',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 题干图片（如果有）
            if (question.stemImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  question.stemImage!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            // 题干文本
            Text(
              question.stem,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 难度星级显示组件。
class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final isFilled = index < difficulty;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: isFilled ? AppColors.achievementStar : AppColors.divider,
        );
      }),
    );
  }
}
