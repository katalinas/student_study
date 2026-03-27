/// 教育应用内容系统的不可变题目模型。
///
/// 支持多种题目子类型：选择题、填空题、判断题、
/// 配对题和排序题。每种子类型使用相关的字段子集。
library;

import 'package:collection/collection.dart';

// ---------------------------------------------------------------------------
// 枚举
// ---------------------------------------------------------------------------

enum QuestionSubtype {
  choice,
  fillBlank,
  trueFalse,
  matching,
  dragOrder;

  factory QuestionSubtype.fromJson(String value) {
    switch (value) {
      case 'choice':
        return QuestionSubtype.choice;
      case 'fill_blank':
        return QuestionSubtype.fillBlank;
      case 'true_false':
        return QuestionSubtype.trueFalse;
      case 'matching':
        return QuestionSubtype.matching;
      case 'drag_order':
        return QuestionSubtype.dragOrder;
      default:
        throw ArgumentError('Unknown QuestionSubtype: $value');
    }
  }

  String toJson() {
    switch (this) {
      case QuestionSubtype.choice:
        return 'choice';
      case QuestionSubtype.fillBlank:
        return 'fill_blank';
      case QuestionSubtype.trueFalse:
        return 'true_false';
      case QuestionSubtype.matching:
        return 'matching';
      case QuestionSubtype.dragOrder:
        return 'drag_order';
    }
  }
}

// ---------------------------------------------------------------------------
// 辅助类
// ---------------------------------------------------------------------------

/// 选择题中的单个选项。
class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.text,
    this.image,
  });

  final String id;
  final String text;
  final String? image;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      text: json['text'] as String,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        if (image != null) 'image': image,
      };

  QuestionOption copyWith({
    String? id,
    String? text,
    String? image,
  }) =>
      QuestionOption(
        id: id ?? this.id,
        text: text ?? this.text,
        image: image ?? this.image,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          image == other.image;

  @override
  int get hashCode => Object.hash(id, text, image);

  @override
  String toString() => 'QuestionOption(id: $id, text: $text, image: $image)';
}

/// 填空题中的单个空白项。
class BlankAnswer {
  const BlankAnswer({
    required this.id,
    required this.correctAnswer,
    this.acceptableAnswers = const [],
    this.hint,
  });

  final String id;
  final String correctAnswer;
  final List<String> acceptableAnswers;
  final String? hint;

  factory BlankAnswer.fromJson(Map<String, dynamic> json) {
    return BlankAnswer(
      id: json['id'] as String,
      correctAnswer: json['correct_answer'] as String,
      acceptableAnswers: (json['acceptable_answers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hint: json['hint'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'correct_answer': correctAnswer,
        'acceptable_answers': acceptableAnswers,
        if (hint != null) 'hint': hint,
      };

  BlankAnswer copyWith({
    String? id,
    String? correctAnswer,
    List<String>? acceptableAnswers,
    String? hint,
  }) =>
      BlankAnswer(
        id: id ?? this.id,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        acceptableAnswers: acceptableAnswers ?? this.acceptableAnswers,
        hint: hint ?? this.hint,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlankAnswer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          correctAnswer == other.correctAnswer &&
          const DeepCollectionEquality()
              .equals(acceptableAnswers, other.acceptableAnswers) &&
          hint == other.hint;

  @override
  int get hashCode => Object.hash(
        id,
        correctAnswer,
        const DeepCollectionEquality().hash(acceptableAnswers),
        hint,
      );

  @override
  String toString() =>
      'BlankAnswer(id: $id, correctAnswer: $correctAnswer)';
}

/// 配对题中某一侧的选项。
class MatchItem {
  const MatchItem({
    required this.id,
    required this.text,
    this.image,
  });

  final String id;
  final String text;
  final String? image;

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      id: json['id'] as String,
      text: json['text'] as String,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        if (image != null) 'image': image,
      };

  MatchItem copyWith({
    String? id,
    String? text,
    String? image,
  }) =>
      MatchItem(
        id: id ?? this.id,
        text: text ?? this.text,
        image: image ?? this.image,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          image == other.image;

  @override
  int get hashCode => Object.hash(id, text, image);

  @override
  String toString() => 'MatchItem(id: $id, text: $text)';
}

/// 配对题中的一组正确配对。
class MatchPair {
  const MatchPair({
    required this.leftId,
    required this.rightId,
  });

  final String leftId;
  final String rightId;

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      leftId: json['left_id'] as String,
      rightId: json['right_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'left_id': leftId,
        'right_id': rightId,
      };

  MatchPair copyWith({
    String? leftId,
    String? rightId,
  }) =>
      MatchPair(
        leftId: leftId ?? this.leftId,
        rightId: rightId ?? this.rightId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchPair &&
          runtimeType == other.runtimeType &&
          leftId == other.leftId &&
          rightId == other.rightId;

  @override
  int get hashCode => Object.hash(leftId, rightId);

  @override
  String toString() => 'MatchPair(leftId: $leftId, rightId: $rightId)';
}

// ---------------------------------------------------------------------------
// 题目模型
// ---------------------------------------------------------------------------

class Question {
  const Question({
    required this.id,
    required this.module,
    this.type = 'question',
    required this.subtype,
    required this.gradeMin,
    required this.gradeMax,
    required this.difficulty,
    this.tags = const [],
    required this.subject,
    required this.stem,
    this.stemImage,
    this.options = const [],
    this.blanks = const [],
    this.answer,
    this.leftItems = const [],
    this.rightItems = const [],
    this.correctPairs = const [],
    this.items = const [],
    this.correctOrder = const [],
    this.explanation,
    this.hint,
    this.timeLimitSeconds = 60,
    this.points = 10,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(difficulty >= 1 && difficulty <= 5,
            'difficulty must be between 1 and 5'),
        assert(gradeMin <= gradeMax, 'gradeMin must be <= gradeMax');

  final String id;
  final String module;
  final String type;
  final QuestionSubtype subtype;
  final int gradeMin;
  final int gradeMax;
  final int difficulty;
  final List<String> tags;
  final String subject;
  final String stem;
  final String? stemImage;

  /// [QuestionSubtype.choice] 选择题的选项列表。
  final List<QuestionOption> options;

  /// [QuestionSubtype.fillBlank] 填空题的空白项列表。
  final List<BlankAnswer> blanks;

  /// 正确答案。类型取决于 [subtype]：
  /// - 选择题：[String]（选项 id）
  /// - 判断题：[bool]
  /// - 填空题：[List<String>] 或通过 [blanks] 处理
  /// - 配对题 / 排序题：通过专用字段处理
  final dynamic answer;

  /// [QuestionSubtype.matching] 配对题的左侧项。
  final List<MatchItem> leftItems;

  /// [QuestionSubtype.matching] 配对题的右侧项。
  final List<MatchItem> rightItems;

  /// [QuestionSubtype.matching] 配对题的正确配对。
  final List<MatchPair> correctPairs;

  /// [QuestionSubtype.dragOrder] 排序题的项目列表。
  final List<String> items;

  /// [QuestionSubtype.dragOrder] 排序题的正确顺序。
  final List<String> correctOrder;

  final String? explanation;
  final String? hint;
  final int timeLimitSeconds;
  final int points;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  // -------------------------------------------------------------------------
  // JSON 序列化
  // -------------------------------------------------------------------------

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      module: json['module'] as String,
      type: json['type'] as String? ?? 'question',
      subtype: QuestionSubtype.fromJson(json['subtype'] as String),
      gradeMin: json['grade_min'] as int,
      gradeMax: json['grade_max'] as int,
      difficulty: json['difficulty'] as int,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subject: json['subject'] as String,
      stem: json['stem'] as String,
      stemImage: json['stem_image'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      blanks: (json['blanks'] as List<dynamic>?)
              ?.map((e) => BlankAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      answer: json['answer'],
      leftItems: (json['left_items'] as List<dynamic>?)
              ?.map((e) => MatchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rightItems: (json['right_items'] as List<dynamic>?)
              ?.map((e) => MatchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      correctPairs: (json['correct_pairs'] as List<dynamic>?)
              ?.map((e) => MatchPair.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctOrder: (json['correct_order'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
      timeLimitSeconds: json['time_limit_seconds'] as int? ?? 60,
      points: json['points'] as int? ?? 10,
      version: json['version'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'type': type,
        'subtype': subtype.toJson(),
        'grade_min': gradeMin,
        'grade_max': gradeMax,
        'difficulty': difficulty,
        'tags': tags,
        'subject': subject,
        'stem': stem,
        if (stemImage != null) 'stem_image': stemImage,
        if (options.isNotEmpty)
          'options': options.map((e) => e.toJson()).toList(),
        if (blanks.isNotEmpty)
          'blanks': blanks.map((e) => e.toJson()).toList(),
        if (answer != null) 'answer': answer,
        if (leftItems.isNotEmpty)
          'left_items': leftItems.map((e) => e.toJson()).toList(),
        if (rightItems.isNotEmpty)
          'right_items': rightItems.map((e) => e.toJson()).toList(),
        if (correctPairs.isNotEmpty)
          'correct_pairs': correctPairs.map((e) => e.toJson()).toList(),
        if (items.isNotEmpty) 'items': items,
        if (correctOrder.isNotEmpty) 'correct_order': correctOrder,
        if (explanation != null) 'explanation': explanation,
        if (hint != null) 'hint': hint,
        'time_limit_seconds': timeLimitSeconds,
        'points': points,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  // -------------------------------------------------------------------------
  // 复制方法
  // -------------------------------------------------------------------------

  Question copyWith({
    String? id,
    String? module,
    String? type,
    QuestionSubtype? subtype,
    int? gradeMin,
    int? gradeMax,
    int? difficulty,
    List<String>? tags,
    String? subject,
    String? stem,
    String? stemImage,
    List<QuestionOption>? options,
    List<BlankAnswer>? blanks,
    dynamic answer,
    List<MatchItem>? leftItems,
    List<MatchItem>? rightItems,
    List<MatchPair>? correctPairs,
    List<String>? items,
    List<String>? correctOrder,
    String? explanation,
    String? hint,
    int? timeLimitSeconds,
    int? points,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Question(
        id: id ?? this.id,
        module: module ?? this.module,
        type: type ?? this.type,
        subtype: subtype ?? this.subtype,
        gradeMin: gradeMin ?? this.gradeMin,
        gradeMax: gradeMax ?? this.gradeMax,
        difficulty: difficulty ?? this.difficulty,
        tags: tags ?? this.tags,
        subject: subject ?? this.subject,
        stem: stem ?? this.stem,
        stemImage: stemImage ?? this.stemImage,
        options: options ?? this.options,
        blanks: blanks ?? this.blanks,
        answer: answer ?? this.answer,
        leftItems: leftItems ?? this.leftItems,
        rightItems: rightItems ?? this.rightItems,
        correctPairs: correctPairs ?? this.correctPairs,
        items: items ?? this.items,
        correctOrder: correctOrder ?? this.correctOrder,
        explanation: explanation ?? this.explanation,
        hint: hint ?? this.hint,
        timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
        points: points ?? this.points,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // -------------------------------------------------------------------------
  // 相等性判断
  // -------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          module == other.module &&
          type == other.type &&
          subtype == other.subtype &&
          gradeMin == other.gradeMin &&
          gradeMax == other.gradeMax &&
          difficulty == other.difficulty &&
          subject == other.subject &&
          stem == other.stem &&
          version == other.version;

  @override
  int get hashCode => Object.hash(
        id,
        module,
        type,
        subtype,
        gradeMin,
        gradeMax,
        difficulty,
        subject,
        stem,
        version,
      );

  @override
  String toString() =>
      'Question(id: $id, subtype: $subtype, stem: $stem, difficulty: $difficulty)';

  /// 判断给定的 [grade] 是否在此题目的年级范围内。
  bool isForGrade(int grade) => grade >= gradeMin && grade <= gradeMax;
}
