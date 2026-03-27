/// 动手实践/虚拟实验室教育内容的不可变实验模型。
library;

// ---------------------------------------------------------------------------
// 辅助类
// ---------------------------------------------------------------------------

/// 实验所需的材料或组件。
class ExperimentComponent {
  const ExperimentComponent({
    required this.id,
    required this.name,
    this.quantity,
    this.unit,
    this.image,
    this.isOptional = false,
  });

  final String id;
  final String name;
  final int? quantity;
  final String? unit;
  final String? image;
  final bool isOptional;

  factory ExperimentComponent.fromJson(Map<String, dynamic> json) {
    return ExperimentComponent(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int?,
      unit: json['unit'] as String?,
      image: json['image'] as String?,
      isOptional: json['is_optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
        if (image != null) 'image': image,
        'is_optional': isOptional,
      };

  ExperimentComponent copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? image,
    bool? isOptional,
  }) =>
      ExperimentComponent(
        id: id ?? this.id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        image: image ?? this.image,
        isOptional: isOptional ?? this.isOptional,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentComponent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          quantity == other.quantity &&
          unit == other.unit &&
          isOptional == other.isOptional;

  @override
  int get hashCode => Object.hash(id, name, quantity, unit, isOptional);

  @override
  String toString() => 'ExperimentComponent(id: $id, name: $name)';
}

/// 实验步骤中的单个操作步骤。
class ExperimentStep {
  const ExperimentStep({
    required this.order,
    required this.instruction,
    this.image,
    this.tip,
    this.durationSeconds,
  });

  final int order;
  final String instruction;
  final String? image;
  final String? tip;
  final int? durationSeconds;

  factory ExperimentStep.fromJson(Map<String, dynamic> json) {
    return ExperimentStep(
      order: json['order'] as int,
      instruction: json['instruction'] as String,
      image: json['image'] as String?,
      tip: json['tip'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order,
        'instruction': instruction,
        if (image != null) 'image': image,
        if (tip != null) 'tip': tip,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
      };

  ExperimentStep copyWith({
    int? order,
    String? instruction,
    String? image,
    String? tip,
    int? durationSeconds,
  }) =>
      ExperimentStep(
        order: order ?? this.order,
        instruction: instruction ?? this.instruction,
        image: image ?? this.image,
        tip: tip ?? this.tip,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperimentStep &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          instruction == other.instruction;

  @override
  int get hashCode => Object.hash(order, instruction);

  @override
  String toString() => 'ExperimentStep(order: $order)';
}

// ---------------------------------------------------------------------------
// 实验模型
// ---------------------------------------------------------------------------

class Experiment {
  const Experiment({
    required this.id,
    required this.module,
    this.type = 'experiment',
    required this.gradeMin,
    required this.gradeMax,
    required this.difficulty,
    this.tags = const [],
    required this.title,
    required this.category,
    this.coverImage,
    required this.description,
    this.learningGoals = const [],
    this.components = const [],
    this.steps = const [],
    this.successCondition,
    this.funFacts = const [],
    this.followUpQuestions = const [],
    this.points = 20,
  })  : assert(difficulty >= 1 && difficulty <= 5,
            'difficulty must be between 1 and 5'),
        assert(gradeMin <= gradeMax, 'gradeMin must be <= gradeMax');

  final String id;
  final String module;
  final String type;
  final int gradeMin;
  final int gradeMax;
  final int difficulty;
  final List<String> tags;
  final String title;
  final String category;
  final String? coverImage;
  final String description;
  final List<String> learningGoals;
  final List<ExperimentComponent> components;
  final List<ExperimentStep> steps;
  final String? successCondition;
  final List<String> funFacts;
  final List<String> followUpQuestions;
  final int points;

  // -------------------------------------------------------------------------
  // JSON 序列化
  // -------------------------------------------------------------------------

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      id: json['id'] as String,
      module: json['module'] as String,
      type: json['type'] as String? ?? 'experiment',
      gradeMin: json['grade_min'] as int,
      gradeMax: json['grade_max'] as int,
      difficulty: json['difficulty'] as int,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      title: json['title'] as String,
      category: json['category'] as String,
      coverImage: json['cover_image'] as String?,
      description: json['description'] as String,
      learningGoals: (json['learning_goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      components: (json['components'] as List<dynamic>?)
              ?.map((e) =>
                  ExperimentComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map(
                  (e) => ExperimentStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      successCondition: json['success_condition'] as String?,
      funFacts: (json['fun_facts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      points: json['points'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'module': module,
        'type': type,
        'grade_min': gradeMin,
        'grade_max': gradeMax,
        'difficulty': difficulty,
        'tags': tags,
        'title': title,
        'category': category,
        if (coverImage != null) 'cover_image': coverImage,
        'description': description,
        'learning_goals': learningGoals,
        'components': components.map((e) => e.toJson()).toList(),
        'steps': steps.map((e) => e.toJson()).toList(),
        if (successCondition != null) 'success_condition': successCondition,
        'fun_facts': funFacts,
        'follow_up_questions': followUpQuestions,
        'points': points,
      };

  // -------------------------------------------------------------------------
  // 复制方法
  // -------------------------------------------------------------------------

  Experiment copyWith({
    String? id,
    String? module,
    String? type,
    int? gradeMin,
    int? gradeMax,
    int? difficulty,
    List<String>? tags,
    String? title,
    String? category,
    String? coverImage,
    String? description,
    List<String>? learningGoals,
    List<ExperimentComponent>? components,
    List<ExperimentStep>? steps,
    String? successCondition,
    List<String>? funFacts,
    List<String>? followUpQuestions,
    int? points,
  }) =>
      Experiment(
        id: id ?? this.id,
        module: module ?? this.module,
        type: type ?? this.type,
        gradeMin: gradeMin ?? this.gradeMin,
        gradeMax: gradeMax ?? this.gradeMax,
        difficulty: difficulty ?? this.difficulty,
        tags: tags ?? this.tags,
        title: title ?? this.title,
        category: category ?? this.category,
        coverImage: coverImage ?? this.coverImage,
        description: description ?? this.description,
        learningGoals: learningGoals ?? this.learningGoals,
        components: components ?? this.components,
        steps: steps ?? this.steps,
        successCondition: successCondition ?? this.successCondition,
        funFacts: funFacts ?? this.funFacts,
        followUpQuestions: followUpQuestions ?? this.followUpQuestions,
        points: points ?? this.points,
      );

  // -------------------------------------------------------------------------
  // 相等性判断
  // -------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Experiment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          module == other.module &&
          type == other.type &&
          gradeMin == other.gradeMin &&
          gradeMax == other.gradeMax &&
          difficulty == other.difficulty &&
          title == other.title &&
          category == other.category;

  @override
  int get hashCode => Object.hash(
        id,
        module,
        type,
        gradeMin,
        gradeMax,
        difficulty,
        title,
        category,
      );

  @override
  String toString() =>
      'Experiment(id: $id, title: $title, category: $category, difficulty: $difficulty)';

  /// 判断给定的 [grade] 是否在此实验的年级范围内。
  bool isForGrade(int grade) => grade >= gradeMin && grade <= gradeMax;
}
