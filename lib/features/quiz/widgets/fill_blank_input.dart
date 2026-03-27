// 填空题输入组件。
//
// 提供圆角输入框和提交按钮，支持已提交后的
// 正确/错误视觉反馈。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 填空题文本输入组件。
class FillBlankInput extends StatefulWidget {
  const FillBlankInput({
    super.key,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onSubmit,
    this.hint,
  });

  /// 是否已提交答案。
  final bool isSubmitted;

  /// 提交后答案是否正确（未提交时为 null）。
  final bool? isCorrect;

  /// 提交答案回调，参数为用户输入的文本。
  final ValueChanged<String> onSubmit;

  /// 输入框提示文字。
  final String? hint;

  @override
  State<FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<FillBlankInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 处理提交操作，忽略空白输入。
  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
  }

  /// 根据提交状态获取输入框边框颜色。
  Color _borderColor() {
    if (!widget.isSubmitted) return AppColors.primary;
    if (widget.isCorrect == true) return AppColors.success;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 输入框
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(),
              width: 2,
            ),
            color: widget.isSubmitted
                ? _borderColor().withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              // 文本输入区域
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.isSubmitted,
                  textInputAction: TextInputAction.done,
                  onSubmitted: widget.isSubmitted ? null : (_) => _handleSubmit(),
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint ?? '请输入答案',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    // 提交后显示状态图标
                    suffixIcon: widget.isSubmitted
                        ? Icon(
                            widget.isCorrect == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _borderColor(),
                          )
                        : null,
                  ),
                ),
              ),
              // 提交按钮（仅未提交时显示）
              if (!widget.isSubmitted)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('提交'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
