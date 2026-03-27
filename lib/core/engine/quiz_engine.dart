/// 管理测验生命周期、答案提交和评分的测验引擎。
///
/// 使用 Riverpod [StateNotifier] 发出不可变的 [QuizState] 快照。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/core/engine/scoring.dart';

// ---------------------------------------------------------------------------
// 状态
// ---------------------------------------------------------------------------

/// 单个已回答题目的状态。
enum AnswerStatus { correct, incorrect, skipped }

/// 一道题目的已记录答案。
class QuizAnswer {
  const QuizAnswer({
    required this.questionId,
    required this.answer,
    required this.status,
    required this.pointsAwarded,
    required this.timeSpentSeconds,
  });

  final String questionId;
  final dynamic answer;
  final AnswerStatus status;
  final int pointsAwarded;
  final int timeSpentSeconds;

  QuizAnswer copyWith({
    String? questionId,
    dynamic answer,
    AnswerStatus? status,
    int? pointsAwarded,
    int? timeSpentSeconds,
  }) =>
      QuizAnswer(
        questionId: questionId ?? this.questionId,
        answer: answer ?? this.answer,
        status: status ?? this.status,
        pointsAwarded: pointsAwarded ?? this.pointsAwarded,
        timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizAnswer &&
          runtimeType == other.runtimeType &&
          questionId == other.questionId &&
          status == other.status &&
          pointsAwarded == other.pointsAwarded;

  @override
  int get hashCode => Object.hash(questionId, status, pointsAwarded);
}

/// 整个测验状态的不可变快照。
class QuizState {
  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.score = 0,
    this.isComplete = false,
    this.elapsedSeconds = 0,
    this.timeRemainingSeconds,
  });

  /// 本次测验会话中的有序题目列表。
  final List<Question> questions;

  /// 当前显示题目的索引。
  final int currentIndex;

  /// 题目 id 到用户已记录答案的映射。
  final Map<String, QuizAnswer> answers;

  /// 累计得分。
  final int score;

  /// 测验是否已完成（所有题目已回答或时间用尽）。
  final bool isComplete;

  /// 测验开始以来的总经过时间（秒）。
  final int elapsedSeconds;

  /// 剩余时间（秒），不限时测验为 null。
  final int? timeRemainingSeconds;

  // -------------------------------------------------------------------------
  // 派生属性
  // -------------------------------------------------------------------------

  /// 当前题目，如果测验没有题目则为 `null`。
  Question? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  /// 题目总数。
  int get totalQuestions => questions.length;

  /// 正确回答的题目数量。
  int get correctCount =>
      answers.values.where((a) => a.status == AnswerStatus.correct).length;

  /// 回答错误的题目数量。
  int get incorrectCount =>
      answers.values.where((a) => a.status == AnswerStatus.incorrect).length;

  /// 跳过的题目数量。
  int get skippedCount =>
      answers.values.where((a) => a.status == AnswerStatus.skipped).length;

  /// 已回答或跳过的题目数量。
  int get answeredCount => answers.length;

  /// 进度比例（0.0 - 1.0）。
  double get progress =>
      totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;

  /// 用户是否已回答当前题目。
  bool get currentQuestionAnswered =>
      currentQuestion != null && answers.containsKey(currentQuestion!.id);

  // -------------------------------------------------------------------------
  // 复制方法
  // -------------------------------------------------------------------------

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    Map<String, QuizAnswer>? answers,
    int? score,
    bool? isComplete,
    int? elapsedSeconds,
    int? timeRemainingSeconds,
  }) =>
      QuizState(
        questions: questions ?? this.questions,
        currentIndex: currentIndex ?? this.currentIndex,
        answers: answers ?? this.answers,
        score: score ?? this.score,
        isComplete: isComplete ?? this.isComplete,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
        timeRemainingSeconds:
            timeRemainingSeconds ?? this.timeRemainingSeconds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizState &&
          runtimeType == other.runtimeType &&
          currentIndex == other.currentIndex &&
          score == other.score &&
          isComplete == other.isComplete &&
          elapsedSeconds == other.elapsedSeconds;

  @override
  int get hashCode =>
      Object.hash(currentIndex, score, isComplete, elapsedSeconds);

  @override
  String toString() =>
      'QuizState(index: $currentIndex/$totalQuestions, score: $score, '
      'complete: $isComplete)';
}

// ---------------------------------------------------------------------------
// 状态通知器
// ---------------------------------------------------------------------------

/// 管理测验会话的生命周期。
///
/// 用法：
/// ```dart
/// final quizProvider = StateNotifierProvider<QuizEngine, QuizState>(
///   (ref) => QuizEngine(),
/// );
/// ```
class QuizEngine extends StateNotifier<QuizState> {
  QuizEngine() : super(const QuizState());

  /// 记录测验开始时的实际时间。
  DateTime? _startTime;

  /// 记录当前题目显示时的实际时间。
  DateTime? _questionStartTime;

  // -------------------------------------------------------------------------
  // 测验生命周期
  // -------------------------------------------------------------------------

  /// 使用给定的 [questions] 开始新的测验。
  ///
  /// 可选地提供 [timeLimitSeconds] 用于限时测验。
  void startQuiz(
    List<Question> questions, {
    int? timeLimitSeconds,
  }) {
    if (questions.isEmpty) return;

    _startTime = DateTime.now();
    _questionStartTime = DateTime.now();

    state = QuizState(
      questions: List.unmodifiable(questions),
      currentIndex: 0,
      answers: const {},
      score: 0,
      isComplete: false,
      elapsedSeconds: 0,
      timeRemainingSeconds: timeLimitSeconds,
    );
  }

  /// 提交当前题目的答案。
  ///
  /// 评分并记录答案，更新累计分数。
  /// 如果测验已完成或当前题目已回答，则不执行任何操作。
  void submitAnswer(dynamic answer) {
    if (state.isComplete) return;

    final question = state.currentQuestion;
    if (question == null) return;
    if (state.answers.containsKey(question.id)) return;

    final timeSpent = _questionTimeSpent();
    final isCorrect = scoreQuestion(question, answer);
    final timeBonus = question.timeLimitSeconds > 0
        ? (question.timeLimitSeconds - timeSpent).clamp(0, question.timeLimitSeconds)
        : 0;
    final points = calculatePoints(
      isCorrect: isCorrect,
      difficulty: question.difficulty,
      timeBonus: timeBonus,
      basePoints: question.points,
    );

    final quizAnswer = QuizAnswer(
      questionId: question.id,
      answer: answer,
      status: isCorrect ? AnswerStatus.correct : AnswerStatus.incorrect,
      pointsAwarded: points,
      timeSpentSeconds: timeSpent,
    );

    final updatedAnswers = {...state.answers, question.id: quizAnswer};
    final updatedScore = state.score + points;
    final elapsed = _totalElapsed();

    state = state.copyWith(
      answers: Map.unmodifiable(updatedAnswers),
      score: updatedScore,
      elapsedSeconds: elapsed,
      isComplete: updatedAnswers.length >= state.totalQuestions,
    );
  }

  /// 跳过当前题目，不计分。
  void skipQuestion() {
    if (state.isComplete) return;

    final question = state.currentQuestion;
    if (question == null) return;
    if (state.answers.containsKey(question.id)) return;

    final timeSpent = _questionTimeSpent();

    final quizAnswer = QuizAnswer(
      questionId: question.id,
      answer: null,
      status: AnswerStatus.skipped,
      pointsAwarded: 0,
      timeSpentSeconds: timeSpent,
    );

    final updatedAnswers = {...state.answers, question.id: quizAnswer};
    final elapsed = _totalElapsed();

    state = state.copyWith(
      answers: Map.unmodifiable(updatedAnswers),
      elapsedSeconds: elapsed,
      isComplete: updatedAnswers.length >= state.totalQuestions,
    );
  }

  /// 导航到下一题。
  ///
  /// 导航成功返回 `true`，已在最后一题或测验已完成返回 `false`。
  bool nextQuestion() {
    if (state.isComplete) return false;
    if (state.currentIndex >= state.totalQuestions - 1) return false;

    _questionStartTime = DateTime.now();

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      elapsedSeconds: _totalElapsed(),
    );
    return true;
  }

  /// 导航到上一题。
  ///
  /// 导航成功返回 `true`，已在第一题返回 `false`。
  bool previousQuestion() {
    if (state.currentIndex <= 0) return false;

    _questionStartTime = DateTime.now();

    state = state.copyWith(
      currentIndex: state.currentIndex - 1,
      elapsedSeconds: _totalElapsed(),
    );
    return true;
  }

  /// 通过 [index] 导航到指定题目。
  ///
  /// 索引有效且导航成功返回 `true`。
  bool goToQuestion(int index) {
    if (index < 0 || index >= state.totalQuestions) return false;
    if (index == state.currentIndex) return false;

    _questionStartTime = DateTime.now();

    state = state.copyWith(
      currentIndex: index,
      elapsedSeconds: _totalElapsed(),
    );
    return true;
  }

  /// 无论剩余题目数量，标记测验为已完成。
  void finishQuiz() {
    if (state.isComplete) return;

    state = state.copyWith(
      isComplete: true,
      elapsedSeconds: _totalElapsed(),
    );
  }

  /// 更新剩余时间（由外部计时器调用）。
  ///
  /// 时间用尽时自动完成测验。
  void tick(int remainingSeconds) {
    if (state.isComplete) return;

    final elapsed = _totalElapsed();

    if (remainingSeconds <= 0) {
      state = state.copyWith(
        timeRemainingSeconds: 0,
        elapsedSeconds: elapsed,
        isComplete: true,
      );
    } else {
      state = state.copyWith(
        timeRemainingSeconds: remainingSeconds,
        elapsedSeconds: elapsed,
      );
    }
  }

  /// 重置引擎到初始空状态。
  void reset() {
    _startTime = null;
    _questionStartTime = null;
    state = const QuizState();
  }

  // -------------------------------------------------------------------------
  // 辅助方法
  // -------------------------------------------------------------------------

  int _totalElapsed() {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }

  int _questionTimeSpent() {
    if (_questionStartTime == null) return 0;
    return DateTime.now().difference(_questionStartTime!).inSeconds;
  }
}

// ---------------------------------------------------------------------------
// Riverpod 提供者
// ---------------------------------------------------------------------------

/// 测验引擎的全局提供者。
///
/// 在组件中的用法：
/// ```dart
/// final quizState = ref.watch(quizEngineProvider);
/// final engine = ref.read(quizEngineProvider.notifier);
/// engine.startQuiz(questions);
/// ```
final quizEngineProvider =
    StateNotifierProvider<QuizEngine, QuizState>((ref) => QuizEngine());
