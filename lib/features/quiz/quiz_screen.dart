// 完整的测验交互页面。
//
// 包含进度条、计时器、题目卡片、答题选项、
// 解析展示和结果页面的全流程测验体验。
// 通过路由 extra 参数接收题目列表，使用 QuizEngine 管理状态。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/core/engine/quiz_engine.dart';
import 'package:student_study/features/quiz/widgets/choice_options.dart';
import 'package:student_study/features/quiz/widgets/fill_blank_input.dart';
import 'package:student_study/features/quiz/widgets/question_card.dart';
import 'package:student_study/features/quiz/widgets/quiz_result.dart';
import 'package:student_study/features/quiz/widgets/true_false_options.dart';

/// 测验交互主页面。
///
/// 从路由 extra 参数获取 `List<Question>` 题目列表。
/// 使用 [quizEngineProvider] 管理测验生命周期。
class QuizInteractionScreen extends ConsumerStatefulWidget {
  const QuizInteractionScreen({
    super.key,
    required this.questions,
  });

  /// 本次测验的题目列表。
  final List<Question> questions;

  @override
  ConsumerState<QuizInteractionScreen> createState() =>
      _QuizInteractionScreenState();
}

class _QuizInteractionScreenState extends ConsumerState<QuizInteractionScreen> {
  /// 选择题当前选中的选项 ID。
  String? _selectedChoiceId;

  /// 判断题当前选中的答案。
  bool? _selectedTrueFalse;

  /// 页面控制器，用于题目间滑动切换动画。
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // 延迟启动测验，避免在 initState 中直接修改提供者状态。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizEngineProvider.notifier).startQuiz(widget.questions);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 提交当前题目的答案。
  void _submitAnswer(dynamic answer) {
    ref.read(quizEngineProvider.notifier).submitAnswer(answer);
  }

  /// 跳过当前题目。
  void _skipQuestion() {
    ref.read(quizEngineProvider.notifier).skipQuestion();
  }

  /// 前进到下一题，带滑动动画。
  void _goToNextQuestion() {
    final engine = ref.read(quizEngineProvider.notifier);
    final moved = engine.nextQuestion();
    if (moved) {
      _resetSelections();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 重置用户的临时选择状态。
  void _resetSelections() {
    setState(() {
      _selectedChoiceId = null;
      _selectedTrueFalse = null;
    });
  }

  /// 重新开始测验。
  void _retryQuiz() {
    _resetSelections();
    _pageController.jumpToPage(0);
    ref.read(quizEngineProvider.notifier).startQuiz(widget.questions);
  }

  /// 返回上一页。
  void _goBack() {
    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizEngineProvider);

    // 测验尚未初始化时显示加载指示器
    if (quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 测验完成时显示结果页面
    if (quizState.isComplete) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('测验结果'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _goBack,
          ),
        ),
        body: QuizResult(
          state: quizState,
          onRetry: _retryQuiz,
          onBack: _goBack,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('答题'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          // 计时器显示
          _TimerDisplay(elapsedSeconds: quizState.elapsedSeconds),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          _ProgressBar(
            current: quizState.currentIndex + 1,
            total: quizState.totalQuestions,
          ),
          // 题目内容区域（带滑动动画）
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizState.totalQuestions,
              itemBuilder: (context, index) {
                final question = quizState.questions[index];
                final isCurrentQuestion = index == quizState.currentIndex;
                if (!isCurrentQuestion) {
                  return const SizedBox.shrink();
                }
                return _buildQuestionPage(context, quizState, question);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建单个题目页面。
  Widget _buildQuestionPage(
    BuildContext context,
    QuizState quizState,
    Question question,
  ) {
    final isAnswered = quizState.currentQuestionAnswered;
    final answer = quizState.answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 题目卡片
          QuestionCard(
            question: question,
            questionNumber: quizState.currentIndex + 1,
            totalQuestions: quizState.totalQuestions,
          ),
          const SizedBox(height: 20),
          // 答题选项区域
          _buildOptionsArea(question, isAnswered),
          const SizedBox(height: 16),
          // 答案解析（仅提交后显示）
          if (isAnswered && question.explanation != null)
            _ExplanationCard(
              isCorrect: answer?.status == AnswerStatus.correct,
              explanation: question.explanation!,
            ),
          const SizedBox(height: 16),
          // 底部操作按钮
          _buildBottomActions(isAnswered, question),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 构建答题选项区域，根据题目类型渲染不同组件。
  Widget _buildOptionsArea(Question question, bool isAnswered) {
    switch (question.subtype) {
      case QuestionSubtype.choice:
        return ChoiceOptions(
          options: question.options,
          selectedOptionId: _selectedChoiceId,
          correctOptionId: isAnswered ? question.answer as String? : null,
          isSubmitted: isAnswered,
          onOptionSelected: (id) {
            setState(() => _selectedChoiceId = id);
          },
        );
      case QuestionSubtype.trueFalse:
        return TrueFalseOptions(
          selectedAnswer: _selectedTrueFalse,
          correctAnswer: isAnswered ? question.answer as bool? : null,
          isSubmitted: isAnswered,
          onAnswerSelected: (value) {
            setState(() => _selectedTrueFalse = value);
          },
        );
      case QuestionSubtype.fillBlank:
        return FillBlankInput(
          isSubmitted: isAnswered,
          isCorrect: isAnswered
              ? ref.read(quizEngineProvider).answers[question.id]?.status ==
                  AnswerStatus.correct
              : null,
          hint: question.blanks.isNotEmpty ? question.blanks.first.hint : null,
          onSubmit: (text) {
            // 填空题答案封装为 Map，与评分器对应
            final answerMap = <String, String>{};
            if (question.blanks.isNotEmpty) {
              answerMap[question.blanks.first.id] = text;
            }
            _submitAnswer(answerMap);
          },
        );
      case QuestionSubtype.matching:
      case QuestionSubtype.dragOrder:
        // 配对题和排序题暂用占位提示
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '该题型暂不支持在线作答',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }

  /// 构建底部操作按钮区域。
  Widget _buildBottomActions(bool isAnswered, Question question) {
    if (isAnswered) {
      // 已回答：显示"下一题"按钮
      return FilledButton.icon(
        onPressed: _goToNextQuestion,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('下一题'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    // 未回答：显示"提交答案"和"跳过"按钮
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 提交答案按钮
        FilledButton(
          onPressed: _canSubmit(question) ? () => _doSubmit(question) : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.divider,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('提交答案'),
        ),
        const SizedBox(height: 8),
        // 跳过按钮
        TextButton(
          onPressed: () {
            _skipQuestion();
            _goToNextQuestion();
          },
          child: Text(
            '跳过',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }

  /// 判断当前题目是否可以提交。
  bool _canSubmit(Question question) {
    switch (question.subtype) {
      case QuestionSubtype.choice:
        return _selectedChoiceId != null;
      case QuestionSubtype.trueFalse:
        return _selectedTrueFalse != null;
      case QuestionSubtype.fillBlank:
        // 填空题通过输入框内部的提交按钮触发，此按钮不可用
        return false;
      case QuestionSubtype.matching:
      case QuestionSubtype.dragOrder:
        return false;
    }
  }

  /// 执行答案提交。
  void _doSubmit(Question question) {
    switch (question.subtype) {
      case QuestionSubtype.choice:
        if (_selectedChoiceId != null) {
          _submitAnswer(_selectedChoiceId);
        }
      case QuestionSubtype.trueFalse:
        if (_selectedTrueFalse != null) {
          _submitAnswer(_selectedTrueFalse);
        }
      case QuestionSubtype.fillBlank:
      case QuestionSubtype.matching:
      case QuestionSubtype.dragOrder:
        break;
    }
  }

  /// 显示退出确认对话框。
  void _showExitDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('确认退出'),
          content: const Text('测验进度将不会保存，确定要退出吗？'),
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
                ref.read(quizEngineProvider.notifier).reset();
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

/// 进度条组件，显示当前题号和总题数。
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 题号文本
          Text(
            '$current / $total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          // 进度条
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 计时器显示组件。
class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.elapsedSeconds});

  final int elapsedSeconds;

  @override
  Widget build(BuildContext context) {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            timeText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
          ),
        ],
      ),
    );
  }
}

/// 答案解析卡片组件。
class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.isCorrect,
    required this.explanation,
  });

  final bool isCorrect;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor =
        isCorrect ? AppColors.success.withValues(alpha:0.1) : AppColors.error.withValues(alpha:0.1);
    final borderColor = isCorrect ? AppColors.success : AppColors.error;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final title = isCorrect ? '回答正确！' : '回答错误';

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha:0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: borderColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
