/// 从打包的 JSON 资源文件中加载并缓存教育内容。
///
/// 内容组织在 `assets/content/{module}/` 目录下，JSON 文件
/// 包含内容项数组。加载器将其解析为类型化模型，
/// 并支持按年级、难度和学科进行筛选。
library;

import 'dart:convert';

import 'package:flutter/services.dart';

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
  Future<List<Question>> loadQuestions(
    String module, {
    String? subject,
    int? grade,
    int? difficulty,
  }) async {
    final items = await _loadModule(module);

    var questions = items
        .whereType<QuestionContent>()
        .map((c) => c.question)
        .toList();

    if (subject != null) {
      questions = questions.where((q) => q.subject == subject).toList();
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
  void clearCache() => _cache.clear();

  /// 清除特定模块的缓存。
  void clearModuleCache(String module) {
    _cache.removeWhere((key, _) => key.contains(module));
  }

  // -------------------------------------------------------------------------
  // 内部加载
  // -------------------------------------------------------------------------

  /// 加载并缓存指定 [module] 的所有内容项。
  ///
  /// 首先尝试从 `assets/content/{module}/content.json` 加载。
  /// 如果失败则回退到加载各类型的独立文件。
  Future<List<ContentItem>> _loadModule(String module) async {
    final cacheKey = 'module:$module';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final items = <ContentItem>[];

    // 首先尝试加载单个合并的内容文件。
    final combinedItems =
        await _tryLoadAsset('assets/content/$module/content.json');
    if (combinedItems != null) {
      items.addAll(combinedItems);
    } else {
      // 回退到并行加载各类型的独立文件。
      final results = await Future.wait([
        _tryLoadAsset('assets/content/$module/questions.json'),
        _tryLoadAsset('assets/content/$module/stories.json'),
        _tryLoadAsset('assets/content/$module/experiments.json'),
      ]);

      for (final result in results) {
        if (result != null) {
          items.addAll(result);
        }
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

      // 逐条解析，跳过损坏的记录，保留有效数据
      final items = <ContentItem>[];
      for (final e in rawList) {
        try {
          items.add(ContentItem.fromJson(e as Map<String, dynamic>));
        } catch (_) {
          // 单条记录解析失败时跳过，不影响其他记录加载
        }
      }
      return items;
    } catch (_) {
      // 资源未找到或顶层解析失败 -- 静默返回 null。
      return null;
    }
  }
}
