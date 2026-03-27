// 美句展示卡片组件。
//
// 使用富文本渲染：普通文字 + 空白占位符（金色下划线）。
// 答题后：空白处替换为正确词语（正确绿色，错误红色）。
// 底部显示来源和作者信息。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 美句展示卡片。
///
/// 将 [displayText] 中的 `___` 占位符渲染为金色下划线空白，
/// 答题后替换为用户的答案或正确答案。
class SentenceCard extends StatelessWidget {
  const SentenceCard({
    super.key,
    required this.displayText,
    required this.originalText,
    required this.correctAnswer,
    this.userAnswer,
    this.isAnswered = false,
    this.source = '',
    this.author = '',
  });

  /// 含有 `___` 占位符的显示文本。
  final String displayText;

  /// 完整原句。
  final String originalText;

  /// 正确答案。
  final String correctAnswer;

  /// 用户选择的答案（答题后才有值）。
  final String? userAnswer;

  /// 是否已答题。
  final bool isAnswered;

  /// 来源/出处。
  final String source;

  /// 作者。
  final String author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE0B2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFE0B2).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 富文本美句
          _buildRichSentence(theme),
          // 来源信息
          if (source.isNotEmpty || author.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _buildAttribution(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建富文本美句，将 `___` 替换为特殊样式。
  Widget _buildRichSentence(ThemeData theme) {
    final parts = displayText.split('___');
    final spans = <InlineSpan>[];

    // 普通文本样式
    final normalStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppColors.textPrimary,
      height: 2.0,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < parts.length; i++) {
      // 添加普通文本段
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i], style: normalStyle));
      }

      // 在各段之间插入空白占位符（最后一段之后不添加）
      if (i < parts.length - 1) {
        if (isAnswered) {
          // 答题后显示答案
          spans.add(_buildAnsweredSpan(theme));
        } else {
          // 未答题时显示金色下划线空白
          spans.add(_buildBlankSpan(theme));
        }
      }
    }

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  /// 构建未答题时的金色下划线空白占位符。
  InlineSpan _buildBlankSpan(ThemeData theme) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFFF8F00),
              width: 2,
            ),
          ),
        ),
        child: Text(
          '　　　',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.transparent,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  /// 构建答题后的答案显示。
  InlineSpan _buildAnsweredSpan(ThemeData theme) {
    final isCorrect = userAnswer == correctAnswer;
    final displayWord = isCorrect ? correctAnswer : userAnswer ?? '';

    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border(
            bottom: BorderSide(
              color: isCorrect ? AppColors.success : AppColors.error,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayWord,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isCorrect ? AppColors.success : AppColors.error,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            // 答错时额外显示正确答案
            if (!isCorrect) ...[
              const SizedBox(width: 4),
              Text(
                '→$correctAnswer',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建来源归属文字。
  String _buildAttribution() {
    if (author.isNotEmpty && source.isNotEmpty) {
      return '——$source';
    }
    if (author.isNotEmpty) {
      return '——$author';
    }
    return '——$source';
  }
}
