// 赏析展示卡片组件。
//
// 答题后显示，包含"赏析"标题、赏析文字和出处背景。
// 支持展开/折叠动画。
import 'package:flutter/material.dart';

import 'package:student_study/app/theme/colors.dart';

/// 赏析展示卡片。
///
/// 展示答题后的赏析文字和出处背景信息，
/// 通过 [AnimatedCrossFade] 实现展开/折叠动画效果。
class AppreciationCard extends StatefulWidget {
  const AppreciationCard({
    super.key,
    required this.appreciation,
    this.context = '',
    this.isCorrect = true,
  });

  /// 赏析文字。
  final String appreciation;

  /// 出处和背景简介。
  final String context;

  /// 用户是否答对（影响标题颜色）。
  final bool isCorrect;

  @override
  State<AppreciationCard> createState() => _AppreciationCardState();
}

class _AppreciationCardState extends State<AppreciationCard>
    with SingleTickerProviderStateMixin {
  /// 是否展开详细内容。
  bool _isExpanded = true;

  /// 展开/折叠动画控制器。
  late final AnimationController _animationController;

  /// 旋转动画（箭头图标）。
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    // 默认展开状态
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 切换展开/折叠状态。
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final headerColor = widget.isCorrect
        ? AppColors.success
        : const Color(0xFFFF8F00);

    return Container(
      decoration: BoxDecoration(
        color: headerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行（可点击切换展开/折叠）
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // 星星图标
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: headerColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // "赏析"标题
                  Text(
                    widget.isCorrect ? '回答正确！来看赏析' : '来看正确答案和赏析',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: headerColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // 展开/折叠箭头
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: headerColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 展开的内容区域
          AnimatedCrossFade(
            firstChild: _buildExpandedContent(theme),
            secondChild: const SizedBox(width: double.infinity, height: 0),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  /// 构建展开后的详细内容。
  Widget _buildExpandedContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分隔线
          Divider(
            color: AppColors.divider.withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 12),
          // 赏析文字
          Text(
            widget.appreciation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.8,
            ),
          ),
          // 出处背景
          if (widget.context.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.context,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
