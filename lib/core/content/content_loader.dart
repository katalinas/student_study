/// 从打包的 JSON 资源文件中加载并缓存教育内容。
///
/// 内容组织在 `assets/content/{module}/` 目录下，JSON 文件
/// 包含内容项数组。加载器将其解析为类型化模型，
/// 并支持按年级、难度和学科进行筛选。
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:student_study/core/content/asset_registry.dart'
    show assetRegistry;
import 'package:student_study/core/content/models/content_item.dart';
import 'package:student_study/core/content/models/experiment.dart';
import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/core/content/models/story.dart';

/// 从打包的 JSON 资源中加载、解析和缓存内容的服务。
///
/// 所有已加载的内容以资源路径为键缓存在内存中，
/// 使得对同一模块的重复请求不需要重新解析 JSON。
class ContentLoader {
  ContentLoader({
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// 以资源路径为键的内存缓存。
  final Map<String, List<ContentItem>> _cache = {};



  // -------------------------------------------------------------------------
  // 公共 API
  // -------------------------------------------------------------------------

  /// 加载指定 [module] 和可选 [subject] 的所有 [Question] 项。
  ///
  /// 如果提供了 [grade]，则只返回年级范围包含该年级的题目。
  /// 如果提供了 [difficulty]，则只返回匹配难度的题目。
  /// 如果提供了 [tag]，则只返回标签列表中包含该标签的题目。
  Future<List<Question>> loadQuestions(
    String module, {
    String? subject,
    String? tag,
    int? grade,
    int? difficulty,
  }) async {
    // 按需加载：优先使用 "module/subject" 精确键
    final items = await _loadModule(module, subject: subject);

    var questions = items
        .whereType<QuestionContent>()
        .map((c) => c.question)
        .toList();

    if (subject != null) {
      questions = questions.where((q) => q.subject == subject).toList();
    }

    if (tag != null) {
      questions =
          questions.where((q) => q.tags.contains(tag)).toList();
    }

    if (grade != null) {
      questions = questions.where((q) => q.isForGrade(grade)).toList();
    }

    if (difficulty != null) {
      questions =
          questions.where((q) => q.difficulty == difficulty).toList();
    }

    return questions;
  }

  /// 加载指定 [module] 的所有卡片（card）类内容的原始 JSON。
  ///
  /// 卡片是知识科普类内容（如 AI 科普、航天知识），
  /// 不属于 Question/Story/Experiment 类型。
  Future<List<Map<String, dynamic>>> loadCards(
    String module, {
    String? category,
  }) async {
    final assetPaths = _findAssets(module);
    final cards = <Map<String, dynamic>>[];

    final results = await Future.wait(
      assetPaths.map((path) => _tryLoadRawJson(path)),
    );

    for (final result in results) {
      if (result != null) {
        for (final item in result) {
          if (item['type'] == 'card') {
            if (category == null || item['category'] == category) {
              cards.add(item);
            }
          }
        }
      }
    }

    return cards;
  }

  /// 加载原始 JSON 列表，不经过 ContentItem 解析。
  Future<List<Map<String, dynamic>>?> _tryLoadRawJson(
    String assetPath,
  ) async {
    try {
      final jsonString = await _bundle.loadString(assetPath);
      final decoded = json.decode(jsonString);

      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic> &&
          decoded.containsKey('data')) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        return null;
      }

      return rawList.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// 加载指定 [module] 的所有 [Story] 项。
  ///
  /// 支持可选的 [grade] 和 [difficulty] 筛选条件。
  Future<List<Story>> loadStories(
    String module, {
    int? grade,
    int? difficulty,
  }) async {
    final items = await _loadModule(module);

    var stories =
        items.whereType<StoryContent>().map((c) => c.story).toList();

    if (grade != null) {
      stories = stories.where((s) => s.isForGrade(grade)).toList();
    }

    if (difficulty != null) {
      stories =
          stories.where((s) => s.difficulty == difficulty).toList();
    }

    return stories;
  }

  /// 加载指定 [module] 的所有 [Experiment] 项。
  ///
  /// 支持可选的 [grade] 和 [difficulty] 筛选条件。
  Future<List<Experiment>> loadExperiments(
    String module, {
    int? grade,
    int? difficulty,
  }) async {
    final items = await _loadModule(module);

    var experiments = items
        .whereType<ExperimentContent>()
        .map((c) => c.experiment)
        .toList();

    if (grade != null) {
      experiments =
          experiments.where((e) => e.isForGrade(grade)).toList();
    }

    if (difficulty != null) {
      experiments =
          experiments.where((e) => e.difficulty == difficulty).toList();
    }

    return experiments;
  }

  /// 加载 [module] 的所有内容项，不区分类型。
  ///
  /// 适用于显示混合内容的搜索/发现页面。
  Future<List<ContentItem>> loadAll(
    String module, {
    int? grade,
    int? difficulty,
  }) async {
    var items = await _loadModule(module);

    if (grade != null) {
      items = items.where((i) => i.isForGrade(grade)).toList();
    }

    if (difficulty != null) {
      items = items.where((i) => i.difficulty == difficulty).toList();
    }

    return items;
  }

  /// 清除内存缓存。适用于测试或内存管理。
  void clearCache() {
    _cache.clear();
  }

  /// 清除特定模块的缓存。
  void clearModuleCache(String module) {
    _cache.removeWhere((key, _) => key.contains(module));
  }

  // -------------------------------------------------------------------------
  // 内部加载
  // -------------------------------------------------------------------------

  /// 查找资源路径，优先使用精确键 "module/subject"。
  List<String> _findAssets(String module, {String? subject}) {
    if (subject != null) {
      final key = '$module/$subject';
      if (assetRegistry.containsKey(key)) {
        return assetRegistry[key]!;
      }
    }
    return assetRegistry[module] ?? const [];
  }

  /// 加载并缓存内容项。
  ///
  /// 使用 "module/subject" 精确键时只加载对应学科的文件，
  /// 大幅减少 Web 平台的网络请求数。
  Future<List<ContentItem>> _loadModule(
    String module, {
    String? subject,
  }) async {
    // 精确缓存键
    final cacheKey = subject != null ? 'module:$module/$subject' : 'module:$module';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final assetPaths = _findAssets(module, subject: subject);
    final items = <ContentItem>[];

    // 并行加载，每个文件 5 秒超时
    final futures = assetPaths.map(
      (path) => _tryLoadAsset(path)
          .timeout(const Duration(seconds: 5), onTimeout: () => null),
    );
    final results = await Future.wait(futures);

    for (final result in results) {
      if (result != null) {
        items.addAll(result);
      }
    }

    _cache[cacheKey] = List.unmodifiable(items);
    return _cache[cacheKey]!;
  }

  /// 尝试加载并解析 JSON 资源文件。
  ///
  /// 如果文件不存在或无法解析则返回 `null`。
  /// JSON 文件必须包含内容项的 JSON 数组，
  /// 或包含 `data` 键的 JSON 对象。
  Future<List<ContentItem>?> _tryLoadAsset(String assetPath) async {
    try {
      final jsonString = await _bundle.loadString(assetPath);
      final decoded = json.decode(jsonString);

      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic> &&
          decoded.containsKey('data')) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        return null;
      }

      // 逐条解析，跳过不支持的类型和损坏的记录
      final items = <ContentItem>[];
      for (final e in rawList) {
        try {
          final item =
              ContentItem.tryFromJson(e as Map<String, dynamic>);
          if (item != null) {
            items.add(item);
          }
        } catch (_) {
          // 单条记录解析失败时跳过，不影响其他记录加载
        }
      }
      return items;
    } catch (_) {
      return null;
    }
  }
}
