// 选择题选项组件。
//
// 以 2x2 网格布局展示 A/B/C/D 四个选项按钮。
// 支持默认、选中、正确、错误四种视觉状态，
// 提交答案后自动禁用交互。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/models/question.dart';

/// 选项的视觉状态枚举。
enum OptionState {
  /// 默认未选中状态。
  idle,

  /// 用户已选中但未提交。
  selected,

  /// 答案正确（提交后）。
  correct,

  /// 答案错误（提交后）。
  incorrect,
}

/// 选择题 2x2 网格选项组件。
class ChoiceOptions extends StatelessWidget {
  const ChoiceOptions({
    super.key,
    required this.options,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.isSubmitted,
    required this.onOptionSelected,
  });

  /// 选项列表。
  final List<QuestionOption> options;

  /// 当前选中的选项 ID，未选择时为 null。
  final String? selectedOptionId;

  /// 正确选项的 ID（提交后用于高亮正确答案）。
  final String? correctOptionId;

  /// 是否已提交答案。
  final bool isSubmitted;

  /// 选项点击回调。
  final ValueChanged<String> onOptionSelected;

  /// 选项标签列表。
  static const List<String> _labels = ['A', 'B', 'C', 'D'];

  /// 根据选项状态获取对应的视觉状态。
  OptionState _getOptionState(String optionId) {
    if (!isSubmitted) {
      return optionId == selectedOptionId
          ? OptionState.selected
          : OptionState.idle;
    }
    // 已提交状态
    if (optionId == correctOptionId) {
      return OptionState.correct;
    }
    if (optionId == selectedOptionId && optionId != correctOptionId) {
      return OptionState.incorrect;
    }
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final label = index < _labels.length ? _labels[index] : '${index + 1}';
        final optionState = _getOptionState(option.id);

        return _OptionButton(
          label: label,
          text: option.text,
          state: optionState,
          onTap: isSubmitted ? null : () => onOptionSelected(option.id),
        );
      },
    );
  }
}

/// 单个选项按钮组件，带动画颜色切换效果。
class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  final String label;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  /// 根据状态获取边框颜色。
  Color _borderColor() {
    switch (state) {
      case OptionState.idle:
        return AppColors.divider;
      case OptionState.selected:
        return AppColors.primary;
      case OptionState.correct:
        return AppColors.success;
      case OptionState.incorrect:
        return AppColors.error;
    }
  }

  /// 根据状态获取背景颜色。
  Color _backgroundColor() {
    switch (state) {
      case OptionState.idle:
        return Colors.white;
      case OptionState.selected:
        return AppColors.primary.withValues(alpha: 0.08);
      case OptionState.correct:
        return AppColors.success.withValues(alpha: 0.1);
      case OptionState.incorrect:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  /// 根据状态获取标签背景颜色。
  Color _labelBackgroundColor() {
    switch (state) {
      case OptionState.idle:
        return AppColors.background;
      case OptionState.selected:
        return AppColors.primary;
      case OptionState.correct:
        return AppColors.success;
      case OptionState.incorrect:
        return AppColors.error;
    }
  }

  /// 根据状态获取标签文字颜色。
  Color _labelTextColor() {
    switch (state) {
      case OptionState.idle:
        return AppColors.textSecondary;
      case OptionState.selected:
      case OptionState.correct:
      case OptionState.incorrect:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: _backgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _borderColor(),
            width: state == OptionState.idle ? 1.5 : 2.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 选项标签（A/B/C/D）
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _labelBackgroundColor(),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _labelTextColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 选项文本
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 状态图标
                if (state == OptionState.correct)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                if (state == OptionState.incorrect)
                  const Icon(Icons.cancel, color: AppColors.error, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
