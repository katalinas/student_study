import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_provider.dart';

/// 错题记录模型
class WrongAnswer {
  const WrongAnswer({
    required this.questionId,
    required this.moduleId,
    required this.subject,
    required this.stem,
    required this.userAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.timestamp,
    this.reviewCount = 0,
    this.isResolved = false,
    this.lastReviewAt,
  });

  /// 题目唯一标识
  final String questionId;

  /// 所属模块标识
  final String moduleId;

  /// 学科名称
  final String subject;

  /// 题干内容
  final String stem;

  /// 用户的错误答案
  final String userAnswer;

  /// 正确答案
  final String correctAnswer;

  /// 解析说明
  final String explanation;

  /// 加入错题本的时间
  final DateTime timestamp;

  /// 已复习次数
  final int reviewCount;

  /// 是否已掌握
  final bool isResolved;

  /// 最近一次复习时间
  final DateTime? lastReviewAt;

  /// 间隔重复的复习间隔天数表：1, 3, 7, 14, 30
  static const _reviewIntervals = [1, 3, 7, 14, 30];

  /// 计算下一次应复习的日期
  DateTime get nextReviewDate {
    final base = lastReviewAt ?? timestamp;
    final intervalIndex = reviewCount.clamp(0, _reviewIntervals.length - 1);
    return base.add(Duration(days: _reviewIntervals[intervalIndex]));
  }

  /// 是否到了该复习的时间
  bool get isReviewDue {
    if (isResolved) return false;
    // 只调用一次 DateTime.now()，避免多次调用产生不一致的时间戳
    final now = DateTime.now();
    return now.isAfter(nextReviewDate) ||
        now.day == nextReviewDate.day &&
            now.month == nextReviewDate.month &&
            now.year == nextReviewDate.year;
  }

  /// 获取下次复习的友好文本描述
  String get nextReviewLabel {
    if (isResolved) return '已掌握';
    final now = DateTime.now();
    final diff = nextReviewDate.difference(now).inDays;
    if (diff <= 0) return '待复习';
    if (diff == 1) return '明天';
    return '$diff天后';
  }

  /// 标记为已复习，返回新实例
  WrongAnswer markReviewed({bool resolved = false}) => WrongAnswer(
        questionId: questionId,
        moduleId: moduleId,
        subject: subject,
        stem: stem,
        userAnswer: userAnswer,
        correctAnswer: correctAnswer,
        explanation: explanation,
        timestamp: timestamp,
        reviewCount: reviewCount + 1,
        isResolved: resolved || reviewCount + 1 >= _reviewIntervals.length,
        lastReviewAt: DateTime.now(),
      );

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'moduleId': moduleId,
        'subject': subject,
        'stem': stem,
        'userAnswer': userAnswer,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'timestamp': timestamp.toIso8601String(),
        'reviewCount': reviewCount,
        'isResolved': isResolved,
        'lastReviewAt': lastReviewAt?.toIso8601String(),
      };

  /// 从 JSON 反序列化
  factory WrongAnswer.fromJson(Map<String, dynamic> json) => WrongAnswer(
        questionId: json['questionId'] as String,
        moduleId: json['moduleId'] as String,
        subject: json['subject'] as String,
        stem: json['stem'] as String,
        userAnswer: json['userAnswer'] as String,
        correctAnswer: json['correctAnswer'] as String,
        explanation: json['explanation'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        reviewCount: (json['reviewCount'] as int?) ?? 0,
        isResolved: (json['isResolved'] as bool?) ?? false,
        lastReviewAt: json['lastReviewAt'] != null
            ? DateTime.tryParse(json['lastReviewAt'] as String)
            : null,
      );
}

/// 错题本状态
class WrongAnswerBookState {
  const WrongAnswerBookState({this.answers = const []});

  /// 所有错题记录
  final List<WrongAnswer> answers;

  /// 按模块筛选
  List<WrongAnswer> getByModule(String moduleId) =>
      answers.where((a) => a.moduleId == moduleId).toList();

  /// 获取未掌握的题目
  List<WrongAnswer> get unresolved =>
      answers.where((a) => !a.isResolved).toList();

  /// 获取已掌握的题目
  List<WrongAnswer> get resolved =>
      answers.where((a) => a.isResolved).toList();

  /// 获取需要复习的题目（按间隔重复策略）
  List<WrongAnswer> get reviewDue =>
      answers.where((a) => a.isReviewDue).toList();

  /// 错题总数
  int get totalCount => answers.length;

  /// 未掌握数
  int get unresolvedCount => unresolved.length;
}

/// 错题本状态管理器。
class WrongAnswerBookNotifier extends Notifier<WrongAnswerBookState> {
  late SharedPreferences _prefs;
  late String _userId;

  @override
  WrongAnswerBookState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final user = ref.watch(activeUserProvider).value;
    _userId = user?.id ?? 'default';
    return _loadState();
  }

  /// 存储键
  String get _storageKey => 'wrong_answers_$_userId';

  /// 从 SharedPreferences 加载，返回状态
  WrongAnswerBookState _loadState() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const WrongAnswerBookState();
    try {
      final json = jsonDecode(raw) as List<dynamic>;
      final answers = json
          .map((item) => WrongAnswer.fromJson(item as Map<String, dynamic>))
          .toList();
      return WrongAnswerBookState(answers: answers);
    } catch (_) {
      return const WrongAnswerBookState();
    }
  }

  /// 保存到 SharedPreferences
  Future<void> _save() async {
    final json = state.answers.map((a) => a.toJson()).toList();
    await _prefs.setString(_storageKey, jsonEncode(json));
  }

  /// 添加错题记录（如果已存在相同题目则更新）
  Future<void> add(WrongAnswer answer) async {
    final existing = state.answers.indexWhere(
      (a) => a.questionId == answer.questionId,
    );
    List<WrongAnswer> updated;
    if (existing >= 0) {
      // 题目已存在，更新用户答案和时间
      updated = [
        ...state.answers.sublist(0, existing),
        answer,
        ...state.answers.sublist(existing + 1),
      ];
    } else {
      updated = [...state.answers, answer];
    }
    state = WrongAnswerBookState(answers: updated);
    await _save();
  }

  /// 移除错题记录
  Future<void> remove(String questionId) async {
    final updated =
        state.answers.where((a) => a.questionId != questionId).toList();
    state = WrongAnswerBookState(answers: updated);
    await _save();
  }

  /// 标记为已复习
  Future<void> markReviewed(String questionId, {bool resolved = false}) async {
    final updated = state.answers.map((a) {
      if (a.questionId == questionId) {
        return a.markReviewed(resolved: resolved);
      }
      return a;
    }).toList();
    state = WrongAnswerBookState(answers: updated);
    await _save();
  }

  /// 清除所有已掌握的题目
  Future<void> clearResolved() async {
    final updated = state.answers.where((a) => !a.isResolved).toList();
    state = WrongAnswerBookState(answers: updated);
    await _save();
  }
}

/// 错题本提供者
final wrongAnswerBookProvider =
    NotifierProvider<WrongAnswerBookNotifier, WrongAnswerBookState>(
  WrongAnswerBookNotifier.new,
);
