import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_provider.dart';

/// 每日任务类型枚举
enum TaskType {
  /// 答题
  quiz('答题'),

  /// 阅读
  read('阅读'),

  /// 实验
  experiment('实验'),

  /// 游戏
  game('游戏');

  const TaskType(this.label);

  /// 类型的中文名称
  final String label;
}

/// 每日任务模型
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.moduleId,
    required this.taskType,
    required this.targetCount,
    this.currentCount = 0,
    this.points = 10,
  });

  /// 任务唯一标识
  final String id;

  /// 任务标题
  final String title;

  /// 任务描述
  final String description;

  /// 所属模块标识
  final String moduleId;

  /// 任务类型
  final TaskType taskType;

  /// 目标完成数量
  final int targetCount;

  /// 当前完成数量
  final int currentCount;

  /// 完成后获得的积分
  final int points;

  /// 是否已完成
  bool get isComplete => currentCount >= targetCount;

  /// 更新进度，返回新实例
  DailyTask addProgress(int amount) {
    final newCount = (currentCount + amount).clamp(0, targetCount);
    return DailyTask(
      id: id,
      title: title,
      description: description,
      moduleId: moduleId,
      taskType: taskType,
      targetCount: targetCount,
      currentCount: newCount,
      points: points,
    );
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'moduleId': moduleId,
        'taskType': taskType.index,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'points': points,
      };

  /// 从 JSON 反序列化
  factory DailyTask.fromJson(Map<String, dynamic> json) => DailyTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        moduleId: json['moduleId'] as String,
        taskType: TaskType.values[(json['taskType'] as int?) ?? 0],
        targetCount: (json['targetCount'] as int?) ?? 1,
        currentCount: (json['currentCount'] as int?) ?? 0,
        points: (json['points'] as int?) ?? 10,
      );
}

/// 每日任务状态
class DailyTaskState {
  const DailyTaskState({
    required this.tasks,
    required this.generatedDate,
  });

  /// 今日任务列表
  final List<DailyTask> tasks;

  /// 任务生成日期（用于判断是否需要刷新）
  final String generatedDate;

  /// 所有任务是否都已完成
  bool get allComplete => tasks.isNotEmpty && tasks.every((t) => t.isComplete);

  /// 已完成的任务数
  int get completedCount => tasks.where((t) => t.isComplete).length;

  /// 总可获得积分
  int get totalPoints => tasks.fold(0, (sum, t) => sum + t.points);

  /// 已获得积分
  int get earnedPoints =>
      tasks.where((t) => t.isComplete).fold(0, (sum, t) => sum + t.points);

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'generatedDate': generatedDate,
      };

  /// 从 JSON 反序列化
  factory DailyTaskState.fromJson(Map<String, dynamic> json) {
    final taskList = (json['tasks'] as List<dynamic>?)
            ?.map((t) => DailyTask.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [];
    return DailyTaskState(
      tasks: taskList,
      generatedDate: (json['generatedDate'] as String?) ?? '',
    );
  }

  /// 空状态
  factory DailyTaskState.empty() => const DailyTaskState(
        tasks: [],
        generatedDate: '',
      );
}

/// 每日任务生成器。
/// 根据用户年级、模块进度和任务类型生成 3~5 个每日任务。
class DailyTaskGenerator {
  const DailyTaskGenerator._();

  /// 模块定义：(模块id, 模块名称, 可用任务类型)
  static const _modules = [
    ('intellect', '智力开发', [TaskType.quiz, TaskType.game]),
    ('tech', '科技探索', [TaskType.quiz, TaskType.experiment]),
    ('logic', '逻辑思维', [TaskType.quiz, TaskType.game]),
    ('general', '百科知识', [TaskType.quiz, TaskType.read]),
    ('moral', '品德教育', [TaskType.read, TaskType.quiz]),
  ];

  /// 根据用户信息和模块进度生成每日任务
  static List<DailyTask> generate({
    required int grade,
    Map<String, double> moduleProgress = const {},
    int streak = 0,
  }) {
    final rng = Random();
    final tasks = <DailyTask>[];

    // 按进度升序排序模块（优先弱项）
    final sortedModules = List.of(_modules)
      ..sort((a, b) {
        final pa = moduleProgress[a.$1] ?? 0.0;
        final pb = moduleProgress[b.$1] ?? 0.0;
        return pa.compareTo(pb);
      });

    // 基础任务数：3~4个
    final baseCount = 3 + (rng.nextBool() ? 1 : 0);

    for (var i = 0; i < baseCount && i < sortedModules.length; i++) {
      final module = sortedModules[i];
      final types = module.$3;
      final type = types[rng.nextInt(types.length)];
      final target = _targetForGrade(grade, type);

      tasks.add(DailyTask(
        id: 'daily_${module.$1}_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: '${type.label}${module.$2}',
        description: _descriptionForType(type, module.$2, target),
        moduleId: module.$1,
        taskType: type,
        targetCount: target,
        points: _pointsForType(type, target),
      ));
    }

    // 连续学习3天以上额外奖励任务
    if (streak >= 3) {
      final bonusModule = sortedModules[rng.nextInt(sortedModules.length)];
      tasks.add(DailyTask(
        id: 'daily_bonus_${DateTime.now().millisecondsSinceEpoch}',
        title: '连续学习奖励',
        description: '连续学习$streak天奖励：完成${bonusModule.$2}的额外挑战',
        moduleId: bonusModule.$1,
        taskType: TaskType.quiz,
        targetCount: 3,
        points: 20,
      ));
    }

    return tasks;
  }

  /// 根据年级和类型确定目标数量
  static int _targetForGrade(int grade, TaskType type) {
    switch (type) {
      case TaskType.quiz:
        return 5 + (grade ~/ 3); // 低年级5题，高年级7-8题
      case TaskType.read:
        return 1 + (grade ~/ 4); // 1~3篇
      case TaskType.experiment:
        return 1;
      case TaskType.game:
        return 2 + (grade ~/ 3); // 2~4轮
    }
  }

  /// 生成任务描述
  static String _descriptionForType(TaskType type, String moduleName, int target) {
    switch (type) {
      case TaskType.quiz:
        return '完成$moduleName的$target道题目';
      case TaskType.read:
        return '阅读$target篇$moduleName文章';
      case TaskType.experiment:
        return '完成$target个$moduleName小实验';
      case TaskType.game:
        return '完成$target轮$moduleName游戏';
    }
  }

  /// 根据任务类型和目标数计算积分
  static int _pointsForType(TaskType type, int target) {
    switch (type) {
      case TaskType.quiz:
        return target * 2;
      case TaskType.read:
        return target * 5;
      case TaskType.experiment:
        return 15;
      case TaskType.game:
        return target * 3;
    }
  }
}

/// 每日任务状态管理器。
class DailyTaskNotifier extends Notifier<DailyTaskState> {
  late SharedPreferences _prefs;
  late String _userId;
  late int _grade;

  @override
  DailyTaskState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final user = ref.watch(activeUserProvider).value;
    _userId = user?.id ?? 'default';
    _grade = user?.grade ?? 1;
    return _loadOrGenerate();
  }

  /// 存储键
  String get _storageKey => 'daily_tasks_$_userId';

  /// 获取今日日期字符串
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 加载或生成今日任务，返回状态
  DailyTaskState _loadOrGenerate() {
    final today = _todayKey();
    final raw = _prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = DailyTaskState.fromJson(json);
        // 如果是今天生成的任务则直接使用
        if (loaded.generatedDate == today) {
          return loaded;
        }
      } catch (_) {
        // 数据损坏时重新生成
      }
    }

    // 生成新的每日任务
    return _buildNewTasks();
  }

  /// 生成新的每日任务状态（不保存）
  DailyTaskState _buildNewTasks({
    Map<String, double> moduleProgress = const {},
    int streak = 0,
  }) {
    final tasks = DailyTaskGenerator.generate(
      grade: _grade,
      moduleProgress: moduleProgress,
      streak: streak,
    );
    return DailyTaskState(
      tasks: tasks,
      generatedDate: _todayKey(),
    );
  }

  /// 生成新的每日任务
  void _generateNewTasks({
    Map<String, double> moduleProgress = const {},
    int streak = 0,
  }) {
    state = _buildNewTasks(moduleProgress: moduleProgress, streak: streak);
    _save();
  }

  /// 保存状态
  Future<void> _save() async {
    await _prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  /// 更新指定任务的进度
  Future<void> updateTaskProgress(String taskId, int amount) async {
    final updatedTasks = state.tasks.map((t) {
      if (t.id == taskId) return t.addProgress(amount);
      return t;
    }).toList();
    state = DailyTaskState(
      tasks: updatedTasks,
      generatedDate: state.generatedDate,
    );
    await _save();
  }

  /// 强制刷新任务（用于手动刷新或传入新的进度数据）
  Future<void> refresh({
    Map<String, double> moduleProgress = const {},
    int streak = 0,
  }) async {
    _generateNewTasks(moduleProgress: moduleProgress, streak: streak);
  }
}

/// 每日任务提供者
final dailyTaskProvider =
    NotifierProvider<DailyTaskNotifier, DailyTaskState>(
  DailyTaskNotifier.new,
);
