import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_provider.dart';

/// 成就/徽章模型。
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    this.targetCount = 1,
    this.currentCount = 0,
  });

  /// 成就唯一标识
  final String id;

  /// 成就名称
  final String name;

  /// 成就描述
  final String description;

  /// 图标名称（对应 Icons 中的名称）
  final String iconName;

  /// 是否已解锁
  final bool isUnlocked;

  /// 解锁时间
  final DateTime? unlockedAt;

  /// 达成目标数量
  final int targetCount;

  /// 当前进度数量
  final int currentCount;

  /// 进度百分比（0.0 ~ 1.0）
  double get progress =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  /// 解锁此成就，返回新实例
  Achievement unlock() => Achievement(
        id: id,
        name: name,
        description: description,
        iconName: iconName,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        targetCount: targetCount,
        currentCount: targetCount,
      );

  /// 更新进度，返回新实例
  Achievement withProgress(int count) {
    final clamped = count.clamp(0, targetCount);
    return Achievement(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      isUnlocked: clamped >= targetCount,
      unlockedAt: clamped >= targetCount ? (unlockedAt ?? DateTime.now()) : null,
      targetCount: targetCount,
      currentCount: clamped,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'iconName': iconName,
        'isUnlocked': isUnlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'targetCount': targetCount,
        'currentCount': currentCount,
      };

  /// 从 JSON 反序列化
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        iconName: json['iconName'] as String,
        isUnlocked: (json['isUnlocked'] as bool?) ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.tryParse(json['unlockedAt'] as String)
            : null,
        targetCount: (json['targetCount'] as int?) ?? 1,
        currentCount: (json['currentCount'] as int?) ?? 0,
      );
}

/// 预定义成就列表
const List<Achievement> predefinedAchievements = [
  // 登录与签到
  Achievement(
    id: 'first_login',
    name: '初次登录',
    description: '第一次登录应用，开始学习之旅',
    iconName: 'login',
    targetCount: 1,
  ),
  Achievement(
    id: 'first_answer',
    name: '首次答题',
    description: '完成第一道题目',
    iconName: 'quiz',
    targetCount: 1,
  ),
  Achievement(
    id: 'streak_3',
    name: '连续3天',
    description: '连续学习3天，坚持就是胜利',
    iconName: 'local_fire_department',
    targetCount: 3,
  ),
  Achievement(
    id: 'streak_7',
    name: '连续7天',
    description: '连续学习一周，真了不起',
    iconName: 'whatshot',
    targetCount: 7,
  ),
  Achievement(
    id: 'streak_30',
    name: '连续30天',
    description: '连续学习一个月，学霸诞生',
    iconName: 'military_tech',
    targetCount: 30,
  ),

  // 答题数量
  Achievement(
    id: 'answer_100',
    name: '答对100题',
    description: '累计答对100道题目',
    iconName: 'star',
    targetCount: 100,
  ),
  Achievement(
    id: 'answer_500',
    name: '答对500题',
    description: '累计答对500道题目，知识丰富',
    iconName: 'star_half',
    targetCount: 500,
  ),
  Achievement(
    id: 'answer_1000',
    name: '答对1000题',
    description: '累计答对1000道题目，学识渊博',
    iconName: 'stars',
    targetCount: 1000,
  ),

  // 学科成就
  Achievement(
    id: 'all_modules',
    name: '全科达人',
    description: '完成所有学科模块的学习',
    iconName: 'emoji_events',
    targetCount: 5,
  ),
  Achievement(
    id: 'math_expert',
    name: '数学小能手',
    description: '在数学模块答对50道题',
    iconName: 'calculate',
    targetCount: 50,
  ),
  Achievement(
    id: 'chinese_expert',
    name: '语文小达人',
    description: '在语文模块答对50道题',
    iconName: 'menu_book',
    targetCount: 50,
  ),
  Achievement(
    id: 'english_expert',
    name: '英语小明星',
    description: '在英语模块答对50道题',
    iconName: 'translate',
    targetCount: 50,
  ),
  Achievement(
    id: 'logic_master',
    name: '逻辑大师',
    description: '在逻辑思维模块答对50道题',
    iconName: 'psychology',
    targetCount: 50,
  ),
  Achievement(
    id: 'science_explorer',
    name: '科学探索者',
    description: '在科学模块答对50道题',
    iconName: 'science',
    targetCount: 50,
  ),
  Achievement(
    id: 'encyclopedia',
    name: '百科全书',
    description: '在百科知识模块答对50道题',
    iconName: 'auto_stories',
    targetCount: 50,
  ),
];

/// 成就系统状态：成就列表
class AchievementState {
  const AchievementState({required this.achievements});

  /// 所有成就
  final List<Achievement> achievements;

  /// 已解锁的成就
  List<Achievement> get unlocked =>
      achievements.where((a) => a.isUnlocked).toList();

  /// 未解锁的成就
  List<Achievement> get locked =>
      achievements.where((a) => !a.isUnlocked).toList();

  /// 根据 id 获取成就
  Achievement? getById(String id) {
    try {
      return achievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 序列化为 JSON
  List<Map<String, dynamic>> toJson() =>
      achievements.map((a) => a.toJson()).toList();

  /// 从 JSON 反序列化
  factory AchievementState.fromJson(List<dynamic> json) {
    final saved = <String, Achievement>{};
    for (final item in json) {
      final a = Achievement.fromJson(item as Map<String, dynamic>);
      saved[a.id] = a;
    }

    // 合并预定义成就与已保存的进度
    final merged = predefinedAchievements.map((def) {
      final savedAchievement = saved[def.id];
      if (savedAchievement != null) {
        return savedAchievement;
      }
      return def;
    }).toList();

    return AchievementState(achievements: merged);
  }

  /// 默认状态（所有预定义成就均未解锁）
  factory AchievementState.initial() =>
      AchievementState(achievements: List.of(predefinedAchievements));
}

/// 成就系统状态管理器。
class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier(this._prefs, this._userId)
      : super(AchievementState.initial()) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _userId;

  /// 存储键
  String get _storageKey => 'achievements_$_userId';

  /// 从 SharedPreferences 加载
  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw) as List<dynamic>;
      state = AchievementState.fromJson(json);
    } catch (_) {
      // 数据损坏时保持默认状态
    }
  }

  /// 保存到 SharedPreferences
  Future<void> _save() async {
    await _prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 解锁指定成就
  Future<void> unlockAchievement(String id) async {
    final updated = state.achievements.map((a) {
      if (a.id == id && !a.isUnlocked) return a.unlock();
      return a;
    }).toList();
    state = AchievementState(achievements: updated);
    await _save();
  }

  /// 更新指定成就的进度
  Future<void> updateProgress(String id, int count) async {
    final updated = state.achievements.map((a) {
      if (a.id == id) return a.withProgress(count);
      return a;
    }).toList();
    state = AchievementState(achievements: updated);
    await _save();
  }

  /// 根据学习数据批量检查并更新成就状态
  Future<void> checkAndUpdate({
    int totalCorrect = 0,
    int streak = 0,
    Map<String, int> moduleCorrect = const {},
    int modulesCompleted = 0,
    bool hasLoggedIn = false,
    bool hasAnswered = false,
  }) async {
    var changed = false;
    final updated = state.achievements.map((a) {
      Achievement result = a;
      switch (a.id) {
        case 'first_login':
          if (hasLoggedIn && !a.isUnlocked) {
            result = a.unlock();
            changed = true;
          }
        case 'first_answer':
          if (hasAnswered && !a.isUnlocked) {
            result = a.unlock();
            changed = true;
          }
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
          final newA = a.withProgress(streak);
          if (newA.isUnlocked != a.isUnlocked || newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'answer_100':
        case 'answer_500':
        case 'answer_1000':
          final newA = a.withProgress(totalCorrect);
          if (newA.isUnlocked != a.isUnlocked || newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'all_modules':
          final newA = a.withProgress(modulesCompleted);
          if (newA.isUnlocked != a.isUnlocked || newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'math_expert':
          final count = moduleCorrect['math'] ?? moduleCorrect['intellect'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'chinese_expert':
          final count = moduleCorrect['chinese'] ?? moduleCorrect['general'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'english_expert':
          final count = moduleCorrect['english'] ?? moduleCorrect['tech'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'logic_master':
          final count = moduleCorrect['logic'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'science_explorer':
          final count = moduleCorrect['science'] ?? moduleCorrect['moral'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
        case 'encyclopedia':
          final count = moduleCorrect['encyclopedia'] ?? moduleCorrect['general'] ?? 0;
          final newA = a.withProgress(count);
          if (newA.currentCount != a.currentCount) {
            result = newA;
            changed = true;
          }
      }
      return result;
    }).toList();

    if (changed) {
      state = AchievementState(achievements: updated);
      await _save();
    }
  }
}

/// 成就系统提供者
final achievementProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final user = ref.watch(activeUserProvider).valueOrNull;
  final userId = user?.id ?? 'default';
  return AchievementNotifier(prefs, userId);
});
