/// 自适应难度引擎，根据学习者的连续表现调整题目难度。
///
/// 规则：
/// - 连续答对 [upgradeThreshold] 题后提升难度。
/// - 连续答错 [downgradeThreshold] 题后降低难度。
/// - 难度限制在 [minDifficulty]..[maxDifficulty]（默认 1-5）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/core/content/models/question.dart';

// ---------------------------------------------------------------------------
// 状态
// ---------------------------------------------------------------------------

/// 自适应难度状态的不可变快照。
class DifficultyState {
  const DifficultyState({
    this.currentDifficulty = 1,
    this.consecutiveCorrect = 0,
    this.consecutiveIncorrect = 0,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
    this.history = const [],
  });

  /// 当前难度等级（1-5）。
  final int currentDifficulty;

  /// 连续正确答案的计数。
  final int consecutiveCorrect;

  /// 连续错误答案的计数。
  final int consecutiveIncorrect;

  /// 本次会话的总正确次数。
  final int totalCorrect;

  /// 本次会话的总错误次数。
  final int totalIncorrect;

  /// 难度等级变化历史：每个条目是调整后的难度等级，按时间顺序排列。
  final List<int> history;

  /// 正确率比例（0.0 - 1.0）。无记录时返回 0。
  double get accuracy {
    final total = totalCorrect + totalIncorrect;
    return total > 0 ? totalCorrect / total : 0.0;
  }

  DifficultyState copyWith({
    int? currentDifficulty,
    int? consecutiveCorrect,
    int? consecutiveIncorrect,
    int? totalCorrect,
    int? totalIncorrect,
    List<int>? history,
  }) =>
      DifficultyState(
        currentDifficulty: currentDifficulty ?? this.currentDifficulty,
        consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
        consecutiveIncorrect:
            consecutiveIncorrect ?? this.consecutiveIncorrect,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalIncorrect: totalIncorrect ?? this.totalIncorrect,
        history: history ?? this.history,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyState &&
          runtimeType == other.runtimeType &&
          currentDifficulty == other.currentDifficulty &&
          consecutiveCorrect == other.consecutiveCorrect &&
          consecutiveIncorrect == other.consecutiveIncorrect &&
          totalCorrect == other.totalCorrect &&
          totalIncorrect == other.totalIncorrect;

  @override
  int get hashCode => Object.hash(
        currentDifficulty,
        consecutiveCorrect,
        consecutiveIncorrect,
        totalCorrect,
        totalIncorrect,
      );

  @override
  String toString() =>
      'DifficultyState(level: $currentDifficulty, '
      'streak: +$consecutiveCorrect/-$consecutiveIncorrect, '
      'accuracy: ${(accuracy * 100).toStringAsFixed(1)}%)';
}

// ---------------------------------------------------------------------------
// 状态通知器
// ---------------------------------------------------------------------------

/// 根据学习者的表现管理自适应难度调整。
class AdaptiveDifficultyEngine extends Notifier<DifficultyState> {
  AdaptiveDifficultyEngine({
    int initialDifficulty = 1,
    this.upgradeThreshold = 3,
    this.downgradeThreshold = 2,
    this.minDifficulty = 1,
    this.maxDifficulty = 5,
  })  : assert(initialDifficulty >= 1 && initialDifficulty <= 5),
        assert(upgradeThreshold >= 1),
        assert(downgradeThreshold >= 1),
        assert(minDifficulty < maxDifficulty),
        _initialDifficulty = initialDifficulty;

  final int _initialDifficulty;

  @override
  DifficultyState build() => DifficultyState(currentDifficulty: _initialDifficulty);

  /// 提升难度所需的连续正确次数。
  final int upgradeThreshold;

  /// 降低难度所需的连续错误次数。
  final int downgradeThreshold;

  /// 最低难度等级。
  final int minDifficulty;

  /// 最高难度等级。
  final int maxDifficulty;

  // -------------------------------------------------------------------------
  // 公共 API
  // -------------------------------------------------------------------------

  /// 记录一次正确答案，可能提升难度。
  void recordCorrect() {
    final newConsecutiveCorrect = state.consecutiveCorrect + 1;
    final newTotalCorrect = state.totalCorrect + 1;

    var newDifficulty = state.currentDifficulty;
    var resetStreak = false;

    if (newConsecutiveCorrect >= upgradeThreshold) {
      newDifficulty = (state.currentDifficulty + 1).clamp(
        minDifficulty,
        maxDifficulty,
      );
      resetStreak = true;
    }

    final updatedHistory = newDifficulty != state.currentDifficulty
        ? [...state.history, newDifficulty]
        : state.history;

    state = state.copyWith(
      currentDifficulty: newDifficulty,
      consecutiveCorrect: resetStreak ? 0 : newConsecutiveCorrect,
      consecutiveIncorrect: 0,
      totalCorrect: newTotalCorrect,
      history: updatedHistory,
    );
  }

  /// 记录一次错误答案，可能降低难度。
  void recordIncorrect() {
    final newConsecutiveIncorrect = state.consecutiveIncorrect + 1;
    final newTotalIncorrect = state.totalIncorrect + 1;

    var newDifficulty = state.currentDifficulty;
    var resetStreak = false;

    if (newConsecutiveIncorrect >= downgradeThreshold) {
      newDifficulty = (state.currentDifficulty - 1).clamp(
        minDifficulty,
        maxDifficulty,
      );
      resetStreak = true;
    }

    final updatedHistory = newDifficulty != state.currentDifficulty
        ? [...state.history, newDifficulty]
        : state.history;

    state = state.copyWith(
      currentDifficulty: newDifficulty,
      consecutiveCorrect: 0,
      consecutiveIncorrect: resetStreak ? 0 : newConsecutiveIncorrect,
      totalIncorrect: newTotalIncorrect,
      history: updatedHistory,
    );
  }

  /// 筛选 [questions] 列表，只保留匹配当前难度等级的题目。
  ///
  /// 如果没有完全匹配当前难度的题目，
  /// 回退返回当前等级 +/- 1 范围内的题目。
  List<Question> filterByDifficulty(List<Question> questions) {
    final exact = questions
        .where((q) => q.difficulty == state.currentDifficulty)
        .toList();

    if (exact.isNotEmpty) return exact;

    // 回退：返回难度 +/- 1 范围内的题目。
    return questions
        .where((q) =>
            (q.difficulty - state.currentDifficulty).abs() <= 1)
        .toList();
  }

  /// 设置难度为指定 [level]（限制在有效范围内）。
  void setDifficulty(int level) {
    final clamped = level.clamp(minDifficulty, maxDifficulty);
    if (clamped == state.currentDifficulty) return;

    state = state.copyWith(
      currentDifficulty: clamped,
      consecutiveCorrect: 0,
      consecutiveIncorrect: 0,
      history: [...state.history, clamped],
    );
  }

  /// 重置为初始状态，使用给定的 [difficulty]（默认 1）。
  void reset({int difficulty = 1}) {
    state = DifficultyState(
      currentDifficulty: difficulty.clamp(minDifficulty, maxDifficulty),
    );
  }
}

// ---------------------------------------------------------------------------
// Riverpod 提供者
// ---------------------------------------------------------------------------

/// 自适应难度引擎的提供者。
///
/// 用法：
/// ```dart
/// final diffState = ref.watch(adaptiveDifficultyProvider);
/// final engine = ref.read(adaptiveDifficultyProvider.notifier);
/// engine.recordCorrect();
/// final filtered = engine.filterByDifficulty(allQuestions);
/// ```
final adaptiveDifficultyProvider =
    NotifierProvider<AdaptiveDifficultyEngine, DifficultyState>(
  AdaptiveDifficultyEngine.new,
);

/// 创建自定义阈值引擎的便捷提供者。
///
/// 示例：
/// ```dart
/// final custom = ref.watch(
///   customDifficultyProvider(
///     (initialDifficulty: 2, upgradeThreshold: 5, downgradeThreshold: 3),
///   ),
/// );
/// ```
final customDifficultyProvider = Provider.family<
    AdaptiveDifficultyEngine,
    ({int initialDifficulty, int upgradeThreshold, int downgradeThreshold})>(
  (ref, params) => AdaptiveDifficultyEngine(
    initialDifficulty: params.initialDifficulty,
    upgradeThreshold: params.upgradeThreshold,
    downgradeThreshold: params.downgradeThreshold,
  ),
);
