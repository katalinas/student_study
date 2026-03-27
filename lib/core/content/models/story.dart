/// 叙事类教育内容的不可变故事模型。
library;

// ---------------------------------------------------------------------------
// 辅助类
// ---------------------------------------------------------------------------

/// 故事中的单个段落（如正文段落、插图、对话等）。
class StorySection {
  const StorySection({
    required this.id,
    required this.content,
    this.image,
    this.audio,
    this.type = 'paragraph',
  });

  final String id;
  final String content;
  final String? image;
  final String? audio;

  /// 段落类型：正文、对话、插图、标题。
  final String type;

  factory StorySection.fromJson(Map<String, dynamic> json) {
    return StorySection(
      id: json['id'] as String,
      content: json['content'] as String,
      image: json['image'] as String?,
      audio: json['audio'] as String?,
      type: json['type'] as String? ?? 'paragraph',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        if (image != null) 'image': image,
        if (audio != null) 'audio': audio,
        'type': type,
      };

  StorySection copyWith({
    String? id,
    String? content,
    String? image,
    String? audio,
    String? type,
  }) =>
      StorySection(
        id: id ?? this.id,
        content: content ?? this.content,
        image: image ?? this.image,
        audio: audio ?? this.audio,
        type: type ?? this.type,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorySection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          image == other.image &&
          audio == other.audio &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, content, image, audio, type);

  @override
  String toString() => 'StorySection(id: $id, type: $type)';
}

// ---------------------------------------------------------------------------
// 故事模型
// ---------------------------------------------------------------------------

class Story {
  const Story({
    required this.id,
    required this.module,
    this.type = 'story',
    required this.gradeMin,
    required this.gradeMax,
    required this.difficulty,
    this.tags = const [],
    required this.title,
    required this.category,
    this.coverImage,
    this.audio,
    this.readTimeMinutes = 5,
    this.sections = const [],
    this.moral,
    this.followUpQuestions = const [],
    this.relatedIdiom,
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
  final String? audio;
  final int readTimeMinutes;
  final List<StorySection> sections;
  final String? moral;
  final List<String> followUpQuestions;
  final String? relatedIdiom;

  // -------------------------------------------------------------------------
  // JSON 序列化
  // -------------------------------------------------------------------------

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      module: json['module'] as String,
      type: json['type'] as String? ?? 'story',
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
      audio: json['audio'] as String?,
      readTimeMinutes: json['read_time_minutes'] as int? ?? 5,
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => StorySection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      moral: json['moral'] as String?,
      followUpQuestions: (json['follow_up_questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      relatedIdiom: json['related_idiom'] as String?,
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
        if (audio != null) 'audio': audio,
        'read_time_minutes': readTimeMinutes,
        'sections': sections.map((e) => e.toJson()).toList(),
        if (moral != null) 'moral': moral,
        'follow_up_questions': followUpQuestions,
        if (relatedIdiom != null) 'related_idiom': relatedIdiom,
      };

  // -------------------------------------------------------------------------
  // 复制方法
  // -------------------------------------------------------------------------

  Story copyWith({
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
    String? audio,
    int? readTimeMinutes,
    List<StorySection>? sections,
    String? moral,
    List<String>? followUpQuestions,
    String? relatedIdiom,
  }) =>
      Story(
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
        audio: audio ?? this.audio,
        readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
        sections: sections ?? this.sections,
        moral: moral ?? this.moral,
        followUpQuestions: followUpQuestions ?? this.followUpQuestions,
        relatedIdiom: relatedIdiom ?? this.relatedIdiom,
      );

  // -------------------------------------------------------------------------
  // 相等性判断
  // -------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Story &&
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
      'Story(id: $id, title: $title, category: $category, difficulty: $difficulty)';

  /// 判断给定的 [grade] 是否在此故事的年级范围内。
  bool isForGrade(int grade) => grade >= gradeMin && grade <= gradeMax;
}
