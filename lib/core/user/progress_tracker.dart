import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 按用户追踪学习进度：模块完成度、正确率、连续天数和学习时长。
///
/// 所有数据以用户 id 为键，确保多个本地资料互相独立。
class ProgressTracker {
  const ProgressTracker(this._prefs, this._userId);

  final SharedPreferences _prefs;
  final String _userId;

  // ---------------------------------------------------------------------------
  // 存储键
  // ---------------------------------------------------------------------------

  String _key(String suffix) => 'progress_${_userId}_$suffix';
  String get _moduleStatsKey => _key('module_stats');
  String get _dailyStatsKey => _key('daily_stats');
  String get _streakKey => _key('streak');
  String get _lastActiveDateKey => _key('last_active');
  String get _timeSpentKey => _key('time_spent');

  // ---------------------------------------------------------------------------
  // 记录答案
  // ---------------------------------------------------------------------------

  /// 记录 [module] 的单次答题。更新模块统计、每日统计和连续天数信息。
  Future<void> recordAnswer(String module, {required bool isCorrect}) async {
    await _updateModuleStats(module, isCorrect: isCorrect);
    await _updateDailyStats(isCorrect: isCorrect);
    await _updateStreak();
  }

  // ---------------------------------------------------------------------------
  // 模块进度
  // ---------------------------------------------------------------------------

  /// 返回指定 [module] 的进度数据。
  ///
  /// 返回的映射包含：
  /// - `totalAnswered`（int）总答题数
  /// - `correctCount`（int）正确数
  /// - `completionPercent`（double，0.0 - 1.0，基于 100 题目标计算）
  Map<String, dynamic> getModuleProgress(String module) {
    final allStats = _readMap(_moduleStatsKey);
    final moduleData =
        (allStats[module] as Map<String, dynamic>?) ?? <String, dynamic>{};

    final total = (moduleData['totalAnswered'] as int?) ?? 0;
    final correct = (moduleData['correctCount'] as int?) ?? 0;
    const targetQuestions = 100;
    final completion = (total / targetQuestions).clamp(0.0, 1.0);

    return {
      'totalAnswered': total,
      'correctCount': correct,
      'completionPercent': completion,
    };
  }

  /// 返回模块 id 到完成百分比（0.0 - 1.0）的映射。
  Map<String, double> getAllModuleProgress() {
    final allStats = _readMap(_moduleStatsKey);
    final result = <String, double>{};

    for (final entry in allStats.entries) {
      final data = entry.value as Map<String, dynamic>? ?? <String, dynamic>{};
      final total = (data['totalAnswered'] as int?) ?? 0;
      result[entry.key] = (total / 100).clamp(0.0, 1.0);
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // 每日统计
  // ---------------------------------------------------------------------------

  /// 返回今日统计数据。
  ///
  /// 返回的映射包含：
  /// - `answeredToday`（int）今日答题数
  /// - `correctToday`（int）今日正确数
  /// - `correctRate`（double，0.0 - 1.0）正确率
  Map<String, dynamic> getDailyStats() {
    final stats = _readMap(_dailyStatsKey);
    final today = _todayKey();

    final dayData =
        (stats[today] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final answered = (dayData['answered'] as int?) ?? 0;
    final correct = (dayData['correct'] as int?) ?? 0;
    final rate = answered > 0 ? correct / answered : 0.0;

    return {
      'answeredToday': answered,
      'correctToday': correct,
      'correctRate': rate,
    };
  }

  // ---------------------------------------------------------------------------
  // 连续天数
  // ---------------------------------------------------------------------------

  /// 返回当前每日学习的连续天数。
  int getStreak() {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  // ---------------------------------------------------------------------------
  // 时间追踪
  // ---------------------------------------------------------------------------

  /// 将 [duration] 累加到 [module] 的学习时长中。
  Future<void> addTimeSpent(String module, Duration duration) async {
    final data = _readMap(_timeSpentKey);
    final current = (data[module] as int?) ?? 0;
    final updated = {
      ...data,
      module: current + duration.inSeconds,
    };
    await _writeMap(_timeSpentKey, updated);
  }

  /// 返回 [module] 的总学习时长。
  Duration getTimeSpent(String module) {
    final data = _readMap(_timeSpentKey);
    final seconds = (data[module] as int?) ?? 0;
    return Duration(seconds: seconds);
  }

  // ---------------------------------------------------------------------------
  // 签到
  // ---------------------------------------------------------------------------

  /// 如果用户今天已签到则返回 `true`。
  bool hasCheckedInToday() {
    final lastActive = _prefs.getString(_lastActiveDateKey);
    return lastActive == _todayKey();
  }

  /// 标记今天为已签到并更新连续天数。
  Future<void> checkIn() async {
    await _updateStreak();
  }

  // ---------------------------------------------------------------------------
  // 内部辅助方法
  // ---------------------------------------------------------------------------

  Future<void> _updateModuleStats(
    String module, {
    required bool isCorrect,
  }) async {
    final allStats = _readMap(_moduleStatsKey);
    final moduleData = Map<String, dynamic>.from(
      (allStats[module] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );

    moduleData['totalAnswered'] =
        ((moduleData['totalAnswered'] as int?) ?? 0) + 1;
    if (isCorrect) {
      moduleData['correctCount'] =
          ((moduleData['correctCount'] as int?) ?? 0) + 1;
    }

    final updated = {...allStats, module: moduleData};
    await _writeMap(_moduleStatsKey, updated);
  }

  Future<void> _updateDailyStats({required bool isCorrect}) async {
    final stats = _readMap(_dailyStatsKey);
    final today = _todayKey();

    final dayData = Map<String, dynamic>.from(
      (stats[today] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );

    dayData['answered'] = ((dayData['answered'] as int?) ?? 0) + 1;
    if (isCorrect) {
      dayData['correct'] = ((dayData['correct'] as int?) ?? 0) + 1;
    }

    // 只保留最近 30 天的数据，避免无限增长。
    final cleaned = <String, dynamic>{};
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    for (final entry in stats.entries) {
      final date = DateTime.tryParse(entry.key);
      if (date != null && date.isAfter(cutoff)) {
        cleaned[entry.key] = entry.value;
      }
    }
    cleaned[today] = dayData;

    await _writeMap(_dailyStatsKey, cleaned);
  }

  Future<void> _updateStreak() async {
    final lastActive = _prefs.getString(_lastActiveDateKey);
    final today = _todayKey();

    if (lastActive == today) return; // 今天已计数。

    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    final currentStreak = _prefs.getInt(_streakKey) ?? 0;

    final newStreak = (lastActive == yesterday) ? currentStreak + 1 : 1;

    await _prefs.setInt(_streakKey, newStreak);
    await _prefs.setString(_lastActiveDateKey, today);
  }

  // ---------------------------------------------------------------------------
  // JSON 辅助方法
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _readMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _writeMap(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, json.encode(data));
  }

  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
