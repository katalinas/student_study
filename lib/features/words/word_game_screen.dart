// 好词好句填词游戏交互页面。
//
// 显示美句并留白，学生从四个选项中选择正确词语。
// 答对后展示赏析，答错后显示正确答案并展示赏析。
// 全部完成后显示总结页面。
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/features/words/widgets/appreciation_card.dart';
import 'package:student_study/features/words/widgets/sentence_card.dart';

/// 填词游戏页面。
///
/// 从 [assetPath] 加载题目数据，逐题展示并交互。
class WordGameScreen extends ConsumerStatefulWidget {
  const WordGameScreen({
    super.key,
    required this.categoryName,
    required this.assetPath,
    required this.themeColor,
  });

  /// 分类名称，显示在顶部。
  final String categoryName;

  /// 题目数据的 asset 路径。
  final String assetPath;

  /// 主题颜色。
  final Color themeColor;

  @override
  ConsumerState<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends ConsumerState<WordGameScreen> {
  /// 所有题目数据。
  List<Map<String, dynamic>> _items = [];

  /// 当前题目索引。
  int _currentIndex = 0;

  /// 用户选择的选项（null 表示尚未选择）。
  String? _selectedOption;

  /// 是否已提交答案。
  bool _isAnswered = false;

  /// 答对题数统计。
  int _correctCount = 0;

  /// 总得分。
  int _totalScore = 0;

  /// 是否已完成所有题目。
  bool _isComplete = false;

  /// 加载状态。
  bool _isLoading = true;

  /// 已作答题目的赏析列表（用于完成页面）。
  final List<Map<String, dynamic>> _answeredItems = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  /// 从 asset 文件加载题目数据。
  Future<void> _loadItems() async {
    try {
      final jsonString = await rootBundle.loadString(widget.assetPath);
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      setState(() {
        _items = decoded.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取当前题目数据。
  Map<String, dynamic>? get _currentItem {
    if (_items.isEmpty || _currentIndex >= _items.length) return null;
    return _items[_currentIndex];
  }

  /// 获取当前题目的正确答案。
  String _getCorrectAnswer(Map<String, dynamic> item) {
    final blanks = item['blanks'] as List<dynamic>?;
    if (blanks == null || blanks.isEmpty) return '';
    final firstBlank = blanks[0] as Map<String, dynamic>;
    return firstBlank['answer'] as String? ?? '';
  }

  /// 获取当前题目的选项列表。
  List<String> _getOptions(Map<String, dynamic> item) {
    final blanks = item['blanks'] as List<dynamic>?;
    if (blanks == null || blanks.isEmpty) return [];
    final firstBlank = blanks[0] as Map<String, dynamic>;
    final options = firstBlank['options'] as List<dynamic>?;
    return options?.map((e) => e.toString()).toList() ?? [];
  }

  /// 用户选择一个选项。
  void _selectOption(String option) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = option;
    });
  }

  /// 提交答案。
  void _submitAnswer() {
    if (_selectedOption == null || _isAnswered) return;

    final item = _currentItem;
    if (item == null) return;

    final correctAnswer = _getCorrectAnswer(item);
    final isCorrect = _selectedOption == correctAnswer;

    setState(() {
      _isAnswered = true;
      if (isCorrect) {
        _correctCount++;
        _totalScore += (item['points'] as int?) ?? 15;
      }
      _answeredItems.add({
        ...item,
        'user_answer': _selectedOption,
        'is_correct': isCorrect,
      });
    });
  }

  /// 进入下一题。
  void _nextQuestion() {
    if (_currentIndex + 1 >= _items.length) {
      setState(() {
        _isComplete = true;
      });
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _isAnswered = false;
    });
  }

  /// 返回上一页。
  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.categoryName)),
        body: const Center(child: Text('暂无题目数据')),
      );
    }

    // 完成页面
    if (_isComplete) {
      return _buildCompletionPage(context);
    }

    return _buildGamePage(context);
  }

  /// 构建游戏答题页面。
  Widget _buildGamePage(BuildContext context) {
    final theme = Theme.of(context);
    final item = _currentItem;
    if (item == null) return const SizedBox.shrink();

    final displayText = item['display_text'] as String? ?? '';
    final originalText = item['original_text'] as String? ?? '';
    final source = item['source'] as String? ?? '';
    final author = item['author'] as String? ?? '';
    final appreciation = item['appreciation'] as String? ?? '';
    final contextText = item['context'] as String? ?? '';
    final correctAnswer = _getCorrectAnswer(item);
    final options = _getOptions(item);
    final hint = _getHint(item);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => _showExitDialog(context),
        ),
      ),
      body: Column(
        children: [
          // 进度条
          _ProgressBar(
            current: _currentIndex + 1,
            total: _items.length,
            color: widget.themeColor,
          ),
          // 题目内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 美句卡片
                  SentenceCard(
                    displayText: displayText,
                    originalText: originalText,
                    correctAnswer: correctAnswer,
                    userAnswer: _isAnswered ? _selectedOption : null,
                    isAnswered: _isAnswered,
                    source: source,
                    author: author,
                  ),
                  const SizedBox(height: 8),
                  // 提示
                  if (!_isAnswered && hint.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '提示：$hint',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // 选项区域（2x2 网格）
                  _buildOptionsGrid(theme, options, correctAnswer),
                  const SizedBox(height: 16),
                  // 赏析卡片（答题后显示）
                  if (_isAnswered && appreciation.isNotEmpty)
                    AppreciationCard(
                      appreciation: appreciation,
                      context: contextText,
                      isCorrect: _selectedOption == correctAnswer,
                    ),
                  const SizedBox(height: 16),
                  // 底部按钮
                  _buildBottomActions(theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取当前题目的提示文字。
  String _getHint(Map<String, dynamic> item) {
    final blanks = item['blanks'] as List<dynamic>?;
    if (blanks == null || blanks.isEmpty) return '';
    final firstBlank = blanks[0] as Map<String, dynamic>;
    return firstBlank['hint'] as String? ?? '';
  }

  /// 构建 2x2 选项网格。
  Widget _buildOptionsGrid(
    ThemeData theme,
    List<String> options,
    String correctAnswer,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: _OptionChip(
            text: option,
            isSelected: _selectedOption == option,
            isCorrect: _isAnswered && option == correctAnswer,
            isWrong: _isAnswered &&
                _selectedOption == option &&
                option != correctAnswer,
            isAnswered: _isAnswered,
            onTap: () => _selectOption(option),
          ),
        );
      }).toList(),
    );
  }

  /// 构建底部操作按钮。
  Widget _buildBottomActions(ThemeData theme) {
    if (_isAnswered) {
      return FilledButton.icon(
        onPressed: _nextQuestion,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          _currentIndex + 1 >= _items.length ? '查看总结' : '下一题',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: widget.themeColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: _selectedOption != null ? _submitAnswer : null,
      style: FilledButton.styleFrom(
        backgroundColor: widget.themeColor,
        disabledBackgroundColor: AppColors.divider,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text('确认选择'),
    );
  }

  /// 构建完成总结页面。
  Widget _buildCompletionPage(BuildContext context) {
    final theme = Theme.of(context);
    final accuracy = _items.isNotEmpty
        ? (_correctCount / _items.length * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('练习总结'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 成绩概览卡片
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.themeColor,
                    widget.themeColor.withValues(alpha:0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // 得分
                  Text(
                    '$_totalScore',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '总积分',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha:0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 统计行
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        label: '答对',
                        value: '$_correctCount/${_items.length}',
                      ),
                      _StatItem(
                        label: '正确率',
                        value: '$accuracy%',
                      ),
                      _StatItem(
                        label: '今日积累',
                        value: '${_items.length}句',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 今日积累标题
            Text(
              '今日积累',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // 已答题目的赏析列表
            ...List.generate(_answeredItems.length, (index) {
              final item = _answeredItems[index];
              final originalText = item['original_text'] as String? ?? '';
              final appreciation = item['appreciation'] as String? ?? '';
              final source = item['source'] as String? ?? '';
              final isCorrect = item['is_correct'] as bool? ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SummaryItem(
                  index: index + 1,
                  originalText: originalText,
                  appreciation: appreciation,
                  source: source,
                  isCorrect: isCorrect,
                ),
              );
            }),
            const SizedBox(height: 16),
            // 返回按钮
            FilledButton(
              onPressed: _goBack,
              style: FilledButton.styleFrom(
                backgroundColor: widget.themeColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('返回'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 显示退出确认对话框。
  void _showExitDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('当前进度将不会保存，确定要退出吗？'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('继续答题'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                _goBack();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }
}

/// 进度条组件。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.current,
    required this.total,
    required this.color,
  });

  final int current;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$current / $total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 选项卡片组件。
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isAnswered,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isAnswered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 根据状态决定颜色
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (isCorrect) {
      backgroundColor = AppColors.success.withValues(alpha:0.1);
      borderColor = AppColors.success;
      textColor = AppColors.success;
      trailingIcon = Icons.check_circle_rounded;
    } else if (isWrong) {
      backgroundColor = AppColors.error.withValues(alpha:0.1);
      borderColor = AppColors.error;
      textColor = AppColors.error;
      trailingIcon = Icons.cancel_rounded;
    } else if (isSelected) {
      backgroundColor = AppColors.primary.withValues(alpha:0.08);
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else {
      backgroundColor = AppColors.surface;
      borderColor = AppColors.divider;
      textColor = AppColors.textPrimary;
    }

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
      ),
      child: InkWell(
        onTap: isAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                Icon(trailingIcon, size: 18, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 统计项组件（完成页面中使用）。
class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha:0.7),
          ),
        ),
      ],
    );
  }
}

/// 总结列表项组件。
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.index,
    required this.originalText,
    required this.appreciation,
    required this.source,
    required this.isCorrect,
  });

  final int index;
  final String originalText;
  final String appreciation;
  final String source;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 序号和状态
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppColors.success.withValues(alpha:0.1)
                      : AppColors.error.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect
                      ? Icons.check_rounded
                      : Icons.close_rounded,
                  size: 14,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  originalText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (appreciation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              appreciation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (source.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '——$source',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary.withValues(alpha:0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
