/// 所有内容类型（题目、故事、实验）的标记联合包装器。
///
/// 使用密封类层次结构，利用 Dart 的穷举性检查确保
/// 在 switch/case 表达式中处理了每种内容类型。
library;

import 'package:student_study/core/content/models/experiment.dart';
import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/core/content/models/story.dart';

/// 通用内容处理的基础密封类。
///
/// 用法：
/// ```dart
/// switch (item) {
///   case QuestionContent(:final question):
///     // 处理题目
///   case StoryContent(:final story):
///     // 处理故事
///   case ExperimentContent(:final experiment):
///     // 处理实验
/// }
/// ```
sealed class ContentItem {
  const ContentItem();

  /// 底层内容的唯一标识符。
  String get id;

  /// 此内容所属的模块（如 'intellect'、'tech'）。
  String get module;

  /// 内容类型标识符（如 'question'、'story'、'experiment'）。
  String get type;

  /// 此内容的最低年级要求。
  int get gradeMin;

  /// 此内容的最高年级要求。
  int get gradeMax;

  /// 难度等级 1-5。
  int get difficulty;

  /// 用于筛选和发现的关联标签。
  List<String> get tags;

  /// 判断给定的 [grade] 是否在此内容的年级范围内。
  bool isForGrade(int grade) => grade >= gradeMin && grade <= gradeMax;

  /// 使用 `type` 标识符从 JSON 反序列化 [ContentItem]。
  ///
  /// 不支持的类型（card/word_game/game 等）返回 `null`，
  /// 由调用方过滤。
  static ContentItem? tryFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) return null;
    switch (type) {
      case 'question':
        return QuestionContent(Question.fromJson(json));
      case 'story':
        return StoryContent(Story.fromJson(json));
      case 'experiment':
        return ExperimentContent(Experiment.fromJson(json));
      default:
        // card, word_game, game 等类型不作为 ContentItem 处理
        return null;
    }
  }

  /// 兼容旧调用方，内部委托给 [tryFromJson]。
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final item = tryFromJson(json);
    if (item != null) return item;
    throw ArgumentError('Unsupported content type: ${json['type']}');
  }

  /// 序列化为 JSON。委托给被包装模型的 toJson() 方法。
  Map<String, dynamic> toJson();
}

// ---------------------------------------------------------------------------
// 具体变体
// ---------------------------------------------------------------------------

/// 包装 [Question] 的内容项。
final class QuestionContent extends ContentItem {
  const QuestionContent(this.question);

  final Question question;

  @override
  String get id => question.id;

  @override
  String get module => question.module;

  @override
  String get type => question.type;

  @override
  int get gradeMin => question.gradeMin;

  @override
  int get gradeMax => question.gradeMax;

  @override
  int get difficulty => question.difficulty;

  @override
  List<String> get tags => question.tags;

  @override
  Map<String, dynamic> toJson() => question.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionContent &&
          runtimeType == other.runtimeType &&
          question == other.question;

  @override
  int get hashCode => question.hashCode;

  @override
  String toString() => 'QuestionContent($question)';
}

/// 包装 [Story] 的内容项。
final class StoryContent extends ContentItem {
  const StoryContent(this.story);

  final Story story;

  @override
  String get id => story.id;

  @override
  String get module => story.module;

  @override
  String get type => story.type;

  @override
  int get gradeMin => story.gradeMin;

  @override
  int get gradeMax => story.gradeMax;

  @override
  int get difficulty => story.difficulty;

  @override
  List<String> get tags => story.tags;

  @override
  Map<String, dynamic> toJson() => story.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoryContent &&
          runtimeType == other.runtimeType &&
          story == other.story;

  @override
  int get hashCode => story.hashCode;

  @override
  String toString() => 'StoryContent($story)';
}

/// 包装 [Experiment] 的内容项。
final class ExperimentContent extends ContentItem {
  const ExperimentContent(this.experiment);

  final Experiment experiment;

  @override
  String get id => experiment.id;

  @override
  String get module => experiment.module;

  @override
  String get type => experiment.type;

  @override
  int get gradeMin => experiment.gradeMin;

  @override
  int get gradeMax => experiment.gradeMax;

  @override
  int get difficulty => experiment.difficulty;

  @override
  List<String> get tags => experiment.tags;

  @override
  Map<String, dynamic> toJson() => experiment.toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentContent &&
          runtimeType == other.runtimeType &&
          experiment == other.experiment;

  @override
  int get hashCode => experiment.hashCode;

  @override
  String toString() => 'ExperimentContent($experiment)';
}
