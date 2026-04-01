import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_provider.dart';

/// 成长树的七个阶段枚举。
enum TreeStage {
  /// 种子阶段
  seed('种子', 0),

  /// 发芽阶段
  sprout('发芽', 50),

  /// 小树苗阶段
  sapling('小树苗', 150),

  /// 小树阶段
  youngTree('小树', 350),

  /// 大树阶段
  tree('大树', 600),

  /// 开花树阶段
  floweringTree('开花树', 1000),

  /// 结果树阶段
  fruitTree('结果树', 1500);

  const TreeStage(this.label, this.threshold);

  /// 阶段的中文名称
  final String label;

  /// 达到此阶段所需的最低经验值
  final int threshold;
}

/// 成长树的不可变状态模型。
class GrowthTreeState {
  const GrowthTreeState({
    this.stage = TreeStage.seed,
    this.experience = 0,
    this.waterDrops = 0,
    this.sunshine = 0,
    this.streakBonus = 0,
  });

  /// 当前树的阶段
  final TreeStage stage;

  /// 累计经验值
  final int experience;

  /// 水滴数（答题获得）
  final int waterDrops;

  /// 阳光数（每日签到获得）
  final int sunshine;

  /// 连续学习奖励
  final int streakBonus;

  /// 当前阶段的经验进度百分比（0.0 ~ 1.0）
  double get stageProgress {
    final currentThreshold = stage.threshold;
    final nextStage = _nextStage;
    if (nextStage == null) return 1.0;
    final nextThreshold = nextStage.threshold;
    final range = nextThreshold - currentThreshold;
    if (range <= 0) return 1.0;
    return ((experience - currentThreshold) / range).clamp(0.0, 1.0);
  }

  /// 获取下一个阶段，若已到最高阶段则返回 null
  TreeStage? get _nextStage {
    final idx = stage.index;
    if (idx >= TreeStage.values.length - 1) return null;
    return TreeStage.values[idx + 1];
  }

  /// 到达下一阶段还需多少经验值
  int get experienceToNextStage {
    final next = _nextStage;
    if (next == null) return 0;
    return (next.threshold - experience).clamp(0, next.threshold);
  }

  /// 根据经验值计算应处于的阶段
  static TreeStage calculateStage(int exp) {
    var result = TreeStage.seed;
    for (final s in TreeStage.values) {
      if (exp >= s.threshold) {
        result = s;
      } else {
        break;
      }
    }
    return result;
  }

  /// 增加经验值并重新计算阶段，返回新状态
  GrowthTreeState addExperience(int amount) {
    final newExp = experience + amount;
    return GrowthTreeState(
      stage: calculateStage(newExp),
      experience: newExp,
      waterDrops: waterDrops,
      sunshine: sunshine,
      streakBonus: streakBonus,
    );
  }

  /// 增加水滴（答题奖励），同时增加经验
  GrowthTreeState water(int drops) {
    final expGain = drops * 2;
    final newExp = experience + expGain;
    return GrowthTreeState(
      stage: calculateStage(newExp),
      experience: newExp,
      waterDrops: waterDrops + drops,
      sunshine: sunshine,
      streakBonus: streakBonus,
    );
  }

  /// 增加阳光（每日签到），同时增加经验
  GrowthTreeState addSunshine() {
    const sunshineExp = 10;
    final newExp = experience + sunshineExp;
    return GrowthTreeState(
      stage: calculateStage(newExp),
      experience: newExp,
      waterDrops: waterDrops,
      sunshine: sunshine + 1,
      streakBonus: streakBonus,
    );
  }

  /// 设置连续学习奖励加成
  GrowthTreeState withStreakBonus(int bonus) {
    return GrowthTreeState(
      stage: stage,
      experience: experience,
      waterDrops: waterDrops,
      sunshine: sunshine,
      streakBonus: bonus,
    );
  }

  /// 序列化为 JSON 映射
  Map<String, dynamic> toJson() => {
        'stage': stage.index,
        'experience': experience,
        'waterDrops': waterDrops,
        'sunshine': sunshine,
        'streakBonus': streakBonus,
      };

  /// 从 JSON 映射反序列化
  factory GrowthTreeState.fromJson(Map<String, dynamic> json) {
    final exp = (json['experience'] as int?) ?? 0;
    return GrowthTreeState(
      stage: calculateStage(exp),
      experience: exp,
      waterDrops: (json['waterDrops'] as int?) ?? 0,
      sunshine: (json['sunshine'] as int?) ?? 0,
      streakBonus: (json['streakBonus'] as int?) ?? 0,
    );
  }
}

/// 成长树状态管理器，负责状态变更和持久化。
class GrowthTreeNotifier extends StateNotifier<GrowthTreeState> {
  GrowthTreeNotifier(this._prefs, this._userId)
      : super(const GrowthTreeState()) {
    _load();
  }

  final SharedPreferences _prefs;
  final String _userId;

  /// 存储键
  String get _storageKey => 'growth_tree_$_userId';

  /// 从 SharedPreferences 加载状态
  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      state = GrowthTreeState.fromJson(json);
    } catch (_) {
      // 数据损坏时保持默认状态
    }
  }

  /// 保存状态到 SharedPreferences
  Future<void> _save() async {
    await _prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 增加经验值
  Future<void> addExperience(int amount) async {
    state = state.addExperience(amount);
    await _save();
  }

  /// 答题获得水滴
  Future<void> water(int drops) async {
    state = state.water(drops);
    await _save();
  }

  /// 每日签到获得阳光
  Future<void> addSunshine() async {
    state = state.addSunshine();
    await _save();
  }

  /// 更新连续学习奖励
  Future<void> updateStreakBonus(int bonus) async {
    state = state.withStreakBonus(bonus);
    await _save();
  }
}

/// 成长树状态提供者
final growthTreeProvider =
    StateNotifierProvider<GrowthTreeNotifier, GrowthTreeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final user = ref.watch(activeUserProvider).valueOrNull;
  final userId = user?.id ?? 'default';
  return GrowthTreeNotifier(prefs, userId);
});
