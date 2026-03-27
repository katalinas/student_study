/// 可交互的数独游戏页面。
///
/// 支持三种难度（4x4、6x6、9x9），包含完整的游戏交互：
/// 选择单元格、放置数字、擦除、提示、检查和计时功能。
/// 完成后展示庆祝动画和得分。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/features/logic/strategy/sudoku_provider.dart';

// ---------------------------------------------------------------------------
// 数独游戏主页面
// ---------------------------------------------------------------------------

/// 数独游戏的完整交互界面。
///
/// 包含难度选择标签页、数独棋盘网格、数字输入面板
/// 和操作按钮（擦除、提示、检查）。
class SudokuScreen extends ConsumerWidget {
  const SudokuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sudokuState = ref.watch(sudokuProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, sudokuState),
            _buildDifficultyTabs(context, ref, sudokuState),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildTimerAndErrors(context, sudokuState),
                    const SizedBox(height: 16),
                    _SudokuGrid(state: sudokuState),
                    const SizedBox(height: 20),
                    _buildNumberPad(context, ref, sudokuState),
                    const SizedBox(height: 16),
                    _buildActionButtons(context, ref, sudokuState),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建页面顶部标题栏。
  Widget _buildHeader(BuildContext context, SudokuState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '数独',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建难度选择标签页（4x4 / 6x6 / 9x9）。
  Widget _buildDifficultyTabs(
    BuildContext context,
    WidgetRef ref,
    SudokuState state,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: SudokuDifficulty.values.map((difficulty) {
          final isActive = state.difficulty == difficulty;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                ref.read(sudokuProvider.notifier).reset(difficulty);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF5C6BC0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    difficulty.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建计时器和错误计数显示行。
  Widget _buildTimerAndErrors(BuildContext context, SudokuState state) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 计时器
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 18,
                color: Color(0xFF5C6BC0),
              ),
              const SizedBox(width: 6),
              Text(
                state.timerText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C6BC0),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // 错误计数
        if (state.errors > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.errors} 处错误',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建数字输入面板，根据当前难度显示对应范围的数字按钮。
  Widget _buildNumberPad(
    BuildContext context,
    WidgetRef ref,
    SudokuState state,
  ) {
    final maxNumber = state.size;
    final notifier = ref.read(sudokuProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(maxNumber, (index) {
        final number = index + 1;
        return GestureDetector(
          onTap: () => notifier.placeNumber(number),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5C6BC0),
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 构建底部操作按钮（擦除、提示、检查）。
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    SudokuState state,
  ) {
    final notifier = ref.read(sudokuProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 擦除按钮
        _ActionButton(
          icon: Icons.backspace_outlined,
          label: '擦除',
          onTap: notifier.erase,
        ),

        // 提示按钮
        _ActionButton(
          icon: Icons.lightbulb_outline_rounded,
          label: '提示 (${state.hintsRemaining})',
          onTap: state.hintsRemaining > 0 ? notifier.useHint : null,
          isDisabled: state.hintsRemaining <= 0,
        ),

        // 检查按钮
        _ActionButton(
          icon: Icons.check_circle_outline_rounded,
          label: '检查',
          onTap: () {
            notifier.checkSolution();
            _showCheckResult(context, state);
          },
        ),
      ],
    );
  }

  /// 显示检查结果的提示消息。
  void _showCheckResult(BuildContext context, SudokuState state) {
    if (state.isComplete) {
      _showCompletionDialog(context, state);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errors > 0
              ? '发现 ${state.errors} 处错误，请检查标红的格子'
              : '目前没有错误，继续加油！',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示完成游戏的庆祝对话框。
  void _showCompletionDialog(BuildContext context, SudokuState state) {
    final theme = Theme.of(context);

    // 根据用时和错误数计算分数
    final baseScore = 1000;
    final timeDeduction = state.elapsedSeconds * 2;
    final errorDeduction = state.errors * 50;
    final finalScore =
        (baseScore - timeDeduction - errorDeduction).clamp(100, 1000);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 庆祝图标
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 48,
                  color: AppColors.xpGold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '恭喜完成！',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5C6BC0),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                '用时: ${state.timerText}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),

              // 分数展示
              Text(
                '得分: $finalScore',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.xpGold,
                ),
              ),
              const SizedBox(height: 20),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('返回'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('再来一局'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 数独棋盘网格组件
// ---------------------------------------------------------------------------

/// 渲染完整的数独棋盘。
///
/// 使用 GridView 绘制棋盘单元格，根据状态呈现不同的视觉效果：
/// - 固定单元格：粗体字、深色背景
/// - 空单元格：浅色背景，可点击
/// - 选中单元格：高亮边框
/// - 冲突单元格：红色色调
class _SudokuGrid extends ConsumerWidget {
  const _SudokuGrid({required this.state});

  final SudokuState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = state.size;
    final notifier = ref.read(sudokuProvider.notifier);

    // 根据棋盘大小计算最大宽度
    final maxWidth = size == 4
        ? 240.0
        : size == 6
            ? 320.0
            : 360.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF5C6BC0),
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
              ),
              itemCount: size * size,
              itemBuilder: (context, index) {
                final row = index ~/ size;
                final col = index % size;
                return _buildCell(context, notifier, row, col);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 构建单个单元格的视觉呈现。
  Widget _buildCell(
    BuildContext context,
    SudokuNotifier notifier,
    int row,
    int col,
  ) {
    final theme = Theme.of(context);
    final value = state.grid[row][col];
    final isFixed = state.isFixed(row, col);
    final isSelected = state.isSelected(row, col);
    final hasConflict = state.hasConflict(row, col);

    // 根据单元格状态确定背景颜色
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = const Color(0xFF5C6BC0).withValues(alpha: 0.15);
    } else if (hasConflict) {
      backgroundColor = AppColors.error.withValues(alpha: 0.12);
    } else if (isFixed) {
      backgroundColor = Colors.grey.shade100;
    } else {
      backgroundColor = Colors.white;
    }

    // 确定文字颜色
    final textColor = hasConflict
        ? AppColors.error
        : isFixed
            ? AppColors.textPrimary
            : const Color(0xFF5C6BC0);

    // 计算宫格边框（加粗宫格分隔线）
    final boxRows = state.difficulty.boxRows;
    final boxCols = state.difficulty.boxCols;
    final isRightBoxEdge = (col + 1) % boxCols == 0 && col < state.size - 1;
    final isBottomBoxEdge = (row + 1) % boxRows == 0 && row < state.size - 1;

    return GestureDetector(
      onTap: () => notifier.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            right: BorderSide(
              color: isRightBoxEdge
                  ? const Color(0xFF5C6BC0).withValues(alpha: 0.6)
                  : Colors.grey.shade300,
              width: isRightBoxEdge ? 2 : 0.5,
            ),
            bottom: BorderSide(
              color: isBottomBoxEdge
                  ? const Color(0xFF5C6BC0).withValues(alpha: 0.6)
                  : Colors.grey.shade300,
              width: isBottomBoxEdge ? 2 : 0.5,
            ),
          ),
        ),
        child: Stack(
          children: [
            // 选中单元格的高亮边框
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF5C6BC0),
                      width: 2,
                    ),
                  ),
                ),
              ),

            // 数字内容
            Center(
              child: value > 0
                  ? Text(
                      '$value',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isFixed ? FontWeight.w800 : FontWeight.w600,
                        color: textColor,
                        fontSize: state.size == 9 ? 16 : 20,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 操作按钮组件
// ---------------------------------------------------------------------------

/// 底部操作区域的单个按钮（擦除/提示/检查）。
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDisabled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        isDisabled ? Colors.grey.shade400 : const Color(0xFF5C6BC0);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: effectiveColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: effectiveColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
