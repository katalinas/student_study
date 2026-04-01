/// 所有题目子类型的评分逻辑。
///
/// 每个评分函数返回表示正确性的布尔值。
/// [calculatePoints] 将正确性和元数据转换为整数分数。
library;

import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'package:student_study/core/content/models/question.dart';

// ---------------------------------------------------------------------------
// 子类型评分器
// ---------------------------------------------------------------------------

/// 选择题评分。
///
/// [answer] 是所选选项的 id。
/// [correctAnswer] 是正确选项的 id。
bool scoreChoice(String answer, String correctAnswer) {
  return answer == correctAnswer;
}

/// 填空题评分。
///
/// [answers] 是空白 id 到用户填写文本的映射。
/// [blanks] 定义了正确答案和可接受的替代答案。
///
/// 所有空白必须正确回答，题目才算正确。
/// 比较时不区分大小写，且去除首尾空格。
bool scoreFillBlank(
  Map<String, String> answers,
  List<BlankAnswer> blanks,
) {
  if (answers.length != blanks.length) return false;

  for (final blank in blanks) {
    final userAnswer = answers[blank.id]?.trim().toLowerCase();
    if (userAnswer == null) return false;

    final correct = blank.correctAnswer.trim().toLowerCase();
    final acceptable =
        blank.acceptableAnswers.map((a) => a.trim().toLowerCase()).toSet();

    if (userAnswer != correct && !acceptable.contains(userAnswer)) {
      return false;
    }
  }

  return true;
}

/// 判断题评分。
bool scoreTrueFalse(bool answer, bool correct) {
  return answer == correct;
}

/// 配对题评分（与顺序无关）。
///
/// [pairs] 是用户的配对列表。
/// [correctPairs] 是预期的正确配对集合。
///
/// 顺序无关紧要；所有配对都必须匹配才算正确。
bool scoreMatching(
  List<MatchPair> pairs,
  List<MatchPair> correctPairs,
) {
  if (pairs.length != correctPairs.length) return false;

  final userSet = pairs
      .map((p) => '${p.leftId}:${p.rightId}')
      .toSet();
  final correctSet = correctPairs
      .map((p) => '${p.leftId}:${p.rightId}')
      .toSet();

  return const SetEquality<String>().equals(userSet, correctSet);
}

/// 拖拽排序题评分。
///
/// [order] 是用户提交的排序。
/// [correctOrder] 是预期的正确排序。
///
/// 各项必须按序完全匹配。
bool scoreDragOrder(List<String> order, List<String> correctOrder) {
  if (order.length != correctOrder.length) return false;

  for (var i = 0; i < order.length; i++) {
    if (order[i] != correctOrder[i]) return false;
  }

  return true;
}

// ---------------------------------------------------------------------------
// 统一评分器
// ---------------------------------------------------------------------------

/// 通过分发到对应子类型评分器来评分任意题目。
///
/// [userAnswer] 类型取决于 [question.subtype]：
/// - 选择题：`String`（选项 id）
/// - 填空题：`Map<String, String>`（空白 id -> 答案）
/// - 判断题：`bool`
/// - 配对题：`List<MatchPair>`
/// - 排序题：`List<String>`
///
/// 答案正确返回 `true`。
bool scoreQuestion(Question question, dynamic userAnswer) {
  switch (question.subtype) {
    case QuestionSubtype.choice:
      // 类型不匹配时返回 false，避免强转崩溃
      if (userAnswer is! String) return false;
      if (question.answer is! String) return false;
      return scoreChoice(userAnswer, question.answer as String);

    case QuestionSubtype.fillBlank:
      // 类型不匹配时返回 false
      if (userAnswer is! Map) return false;
      return scoreFillBlank(
        userAnswer.cast<String, String>(),
        question.blanks,
      );

    case QuestionSubtype.trueFalse:
      // 类型不匹配时返回 false
      if (userAnswer is! bool) return false;
      if (question.answer is! bool) return false;
      return scoreTrueFalse(userAnswer, question.answer as bool);

    case QuestionSubtype.matching:
      // 类型不匹配时返回 false
      if (userAnswer is! List) return false;
      return scoreMatching(
        userAnswer.cast<MatchPair>(),
        question.correctPairs,
      );

    case QuestionSubtype.dragOrder:
      // 类型不匹配时返回 false
      if (userAnswer is! List) return false;
      return scoreDragOrder(
        userAnswer.cast<String>(),
        question.correctOrder,
      );
  }
}

// ---------------------------------------------------------------------------
// 分数计算
// ---------------------------------------------------------------------------

/// 计算一道题的得分。
///
/// [isCorrect] - 答案是否正确。
/// [difficulty] - 题目难度（1-5），作为乘数。
/// [timeBonus] - 剩余奖励秒数（0 = 无奖励）。每剩余 10 秒
///   增加 1 个奖励分，上限为基础分值。
/// [basePoints] - 题目的基础分值（默认 10）。
///
/// 答案错误返回 0。
int calculatePoints({
  required bool isCorrect,
  required int difficulty,
  int timeBonus = 0,
  int basePoints = 10,
}) {
  if (!isCorrect) return 0;

  final difficultyMultiplier = 1.0 + (difficulty - 1) * 0.25;
  final base = (basePoints * difficultyMultiplier).round();

  final timeBonusPoints = math.min(timeBonus ~/ 10, basePoints);

  return base + timeBonusPoints;
}
