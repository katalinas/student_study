// 判断题选项组件。
//
// 展示"对"和"错"两个大按钮，并排显示。
// 支持选中、正确、错误三种视觉状态反馈。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 判断题两按钮选项组件。
class TrueFalseOptions extends StatelessWidget {
  const TrueFalseOptions({
    super.key,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isSubmitted,
    required this.onAnswerSelected,
  });

  /// 用户选择的答案，未选择时为 null。
  final bool? selectedAnswer;

  /// 正确答案（提交后用于颜色反馈）。
  final bool? correctAnswer;

  /// 是否已提交答案。
  final bool isSubmitted;

  /// 答案选择回调。
  final ValueChanged<bool> onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // "对" 按钮
        Expanded(
          child: _TrueFalseButton(
            label: '对',
            icon: Icons.check_rounded,
            value: true,
            selectedAnswer: selectedAnswer,
            correctAnswer: correctAnswer,
            isSubmitted: isSubmitted,
            baseColor: AppColors.success,
            onTap: isSubmitted ? null : () => onAnswerSelected(true),
          ),
        ),
        const SizedBox(width: 16),
        // "错" 按钮
        Expanded(
          child: _TrueFalseButton(
            label: '错',
            icon: Icons.close_rounded,
            value: false,
            selectedAnswer: selectedAnswer,
            correctAnswer: correctAnswer,
            isSubmitted: isSubmitted,
            baseColor: AppColors.error,
            onTap: isSubmitted ? null : () => onAnswerSelected(false),
          ),
        ),
      ],
    );
  }
}

/// 判断题单个按钮组件。
class _TrueFalseButton extends StatelessWidget {
  const _TrueFalseButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isSubmitted,
    required this.baseColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool value;
  final bool? selectedAnswer;
  final bool? correctAnswer;
  final bool isSubmitted;
  final Color baseColor;
  final VoidCallback? onTap;

  /// 计算当前按钮的视觉状态。
  _ButtonVisual _computeVisual() {
    final isSelected = selectedAnswer == value;

    if (!isSubmitted) {
      // 未提交状态
      if (isSelected) {
        return _ButtonVisual(
          backgroundColor: baseColor.withValues(alpha: 0.15),
          borderColor: baseColor,
          textColor: baseColor,
          borderWidth: 2.5,
        );
      }
      return _ButtonVisual(
        backgroundColor: Colors.white,
        borderColor: AppColors.divider,
        textColor: AppColors.textSecondary,
        borderWidth: 1.5,
      );
    }

    // 已提交状态
    final isCorrectAnswer = correctAnswer == value;
    if (isCorrectAnswer) {
      return _ButtonVisual(
        backgroundColor: AppColors.success.withValues(alpha: 0.15),
        borderColor: AppColors.success,
        textColor: AppColors.success,
        borderWidth: 2.5,
      );
    }
    if (isSelected && !isCorrectAnswer) {
      return _ButtonVisual(
        backgroundColor: AppColors.error.withValues(alpha: 0.15),
        borderColor: AppColors.error,
        textColor: AppColors.error,
        borderWidth: 2.5,
      );
    }
    return _ButtonVisual(
      backgroundColor: Colors.white,
      borderColor: AppColors.divider,
      textColor: AppColors.textSecondary,
      borderWidth: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = _computeVisual();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: visual.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: visual.borderColor,
            width: visual.borderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: visual.textColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: visual.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 按钮视觉属性的封装。
class _ButtonVisual {
  const _ButtonVisual({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.borderWidth,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;
}
