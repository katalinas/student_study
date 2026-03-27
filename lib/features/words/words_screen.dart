// 好词好句模块主页面。
//
// 展示五个分类卡片（古诗词填词、美文赏读、作文好句、名人名言、成语运用），
// 顶部显示"每日一句"精选美句卡片。
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/features/words/word_game_screen.dart';

/// 好词好句分类信息。
class _WordCategory {
  const _WordCategory({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.assetPath,
    required this.itemCount,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String assetPath;
  final int itemCount;
}

/// 五个好词好句分类。
const List<_WordCategory> _categories = [
  _WordCategory(
    id: 'poetry_classical',
    name: '古诗词填词',
    subtitle: '品味经典诗词之美',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF8D6E63),
    assetPath: 'assets/content/words/poetry_classical.json',
    itemCount: 30,
  ),
  _WordCategory(
    id: 'prose_modern',
    name: '美文赏读',
    subtitle: '感受现代散文的韵味',
    icon: Icons.local_library_rounded,
    color: Color(0xFF5C6BC0),
    assetPath: 'assets/content/words/prose_modern.json',
    itemCount: 30,
  ),
  _WordCategory(
    id: 'composition_phrases',
    name: '作文好句',
    subtitle: '积累写作黄金素材',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF26A69A),
    assetPath: 'assets/content/words/composition_phrases.json',
    itemCount: 30,
  ),
  _WordCategory(
    id: 'famous_quotes',
    name: '名人名言',
    subtitle: '聆听智者的声音',
    icon: Icons.format_quote_rounded,
    color: Color(0xFFEF5350),
    assetPath: 'assets/content/words/famous_quotes.json',
    itemCount: 25,
  ),
  _WordCategory(
    id: 'idiom_usage',
    name: '成语运用',
    subtitle: '学以致用巧用成语',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFF7043),
    assetPath: 'assets/content/words/idiom_usage.json',
    itemCount: 25,
  ),
];

/// 好词好句模块主页面。
class WordsScreen extends ConsumerStatefulWidget {
  const WordsScreen({super.key});

  @override
  ConsumerState<WordsScreen> createState() => _WordsScreenState();
}

class _WordsScreenState extends ConsumerState<WordsScreen> {
  /// 每日一句数据。
  Map<String, dynamic>? _dailySentence;

  @override
  void initState() {
    super.initState();
    _loadDailySentence();
  }

  /// 从所有分类中随机加载一条美句作为"每日一句"。
  Future<void> _loadDailySentence() async {
    try {
      // 随机选择一个分类
      final random = Random(DateTime.now().day);
      final category = _categories[random.nextInt(_categories.length)];

      final jsonString = await rootBundle.loadString(category.assetPath);
      final List<dynamic> items = json.decode(jsonString) as List<dynamic>;

      if (items.isNotEmpty) {
        final item = items[random.nextInt(items.length)] as Map<String, dynamic>;
        setState(() {
          _dailySentence = item;
        });
      }
    } catch (_) {
      // 加载失败时不显示每日一句
    }
  }

  /// 导航到指定分类的填词游戏页面。
  void _navigateToCategory(_WordCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WordGameScreen(
          categoryName: category.name,
          assetPath: category.assetPath,
          themeColor: category.color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题区域
              _buildHeader(theme),
              const SizedBox(height: 20),
              // 每日一句卡片
              if (_dailySentence != null) ...[
                _DailySentenceCard(data: _dailySentence!),
                const SizedBox(height: 24),
              ],
              // 分类标题
              Text(
                '选择分类',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // 分类卡片列表
              ...List.generate(_categories.length, (index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryCard(
                    category: category,
                    onTap: () => _navigateToCategory(category),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建页面标题区域。
  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFF5252)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_fix_high_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // 标题文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '好词好句',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '品味语言之美，积累写作素材',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 每日一句精选卡片。
class _DailySentenceCard extends StatelessWidget {
  const _DailySentenceCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalText = data['original_text'] as String? ?? '';
    final source = data['source'] as String? ?? '';
    final author = data['author'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE082),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFF8F00),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '每日一句',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFFF8F00),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 句子内容
          Text(
            originalText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // 来源
          if (source.isNotEmpty || author.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                author.isNotEmpty ? '——$author' : '——$source',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 分类卡片组件。
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final _WordCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shadowColor: category.color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: category.color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // 文字区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 题目数量标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.itemCount}题',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: category.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
