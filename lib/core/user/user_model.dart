/// 少年研学应用的不可变用户资料模型。
///
/// 每个本地用户拥有唯一 [id]、显示 [name]、选择的 [avatarIndex]、
/// 当前学校 [grade]（1-9年级）和 [createdAt] 创建时间戳。
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarIndex,
    required this.grade,
    required this.createdAt,
  });

  /// 唯一标识符（UUID v4）。
  final String id;

  /// 孩子选择的显示名称。
  final String name;

  /// 预设头像列表的索引（从 0 开始）。
  final int avatarIndex;

  /// 学校年级，1 到 9。
  final int grade;

  /// 此资料首次创建的时间。
  final DateTime createdAt;

  /// 可用预设头像的总数量。
  static const int avatarCount = 12;

  // ---------------------------------------------------------------------------
  // 序列化
  // ---------------------------------------------------------------------------

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarIndex: json['avatarIndex'] as int,
      grade: json['grade'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarIndex': avatarIndex,
      'grade': grade,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // 复制方法
  // ---------------------------------------------------------------------------

  UserProfile copyWith({
    String? id,
    String? name,
    int? avatarIndex,
    int? grade,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      grade: grade ?? this.grade,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // 相等性判断
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.avatarIndex == avatarIndex &&
        other.grade == grade &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, avatarIndex, grade, createdAt);
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, avatarIndex: $avatarIndex, '
        'grade: $grade, createdAt: $createdAt)';
  }
}
