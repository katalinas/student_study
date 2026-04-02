// 学科详情页面。
//
// 展示学科横幅、年级选择器、难度选择器、
// "开始答题"按钮和最近成绩记录。
// 从 ContentLoader 加载题目并导航至测验页面。
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/content_loader.dart';
import 'package:student_study/core/user/user_provider.dart';

/// ContentLoader 的全局提供者。
final contentLoaderProvider = Provider<ContentLoader>(
  (ref) => ContentLoader(),
);

/// 学科信息配置。
class _SubjectConfig {
  const _SubjectConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.subjectKey,
  });

  final String name;
  final IconData icon;
  final Color color;
  final String subjectKey;
}

/// 根据学科 ID 获取学科配置。
_SubjectConfig _getSubjectConfig(String subjectId) {
  switch (subjectId) {
    case 'math':
      return const _SubjectConfig(
        name: '数学',
        icon: Icons.calculate_rounded,
        color: AppColors.intellect,
        subjectKey: 'math',
      );
    case 'chinese':
      return const _SubjectConfig(
        name: '语文',
        icon: Icons.menu_book_rounded,
        color: Color(0xFFC62828),
        subjectKey: 'chinese',
      );
    case 'english':
      return const _SubjectConfig(
        name: '英语',
        icon: Icons.translate_rounded,
        color: Color(0xFF2E7D32),
        subjectKey: 'english',
      );
    default:
      return _SubjectConfig(
        name: subjectId,
        icon: Icons.book_rounded,
        color: AppColors.primary,
        subjectKey: subjectId,
      );
  }
}

/// 学科详情页面，支持年级和难度筛选。
class SubjectScreen extends ConsumerStatefulWidget {
  const SubjectScreen({
    super.key,
    required this.subjectId,
  });

  /// 学科标识，如 'math'、'chinese'、'english'。
  final String subjectId;

  @override
  ConsumerState<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends ConsumerState<SubjectScreen> {
  /// 当前选中的年级。
  late int _selectedGrade;

  /// 当前选中的难度等级（1-5）。
  int _selectedDifficulty = 1;

  /// 是否正在加载题目。
  bool _isLoading = false;

  /// 年级是否已从用户数据初始化，防止每次 build 重复触发
  bool _gradeInitialized = false;

  @override
  void initState() {
    super.initState();
    // 默认年级从用户资料获取，延迟到 build 时读取。
    _selectedGrade = 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getSubjectConfig(widget.subjectId);

    // 只在首次 build 时从用户数据初始化年级，避免每次重建都触发 setState
    final activeUserAsync = ref.watch(activeUserProvider);
    if (!_gradeInitialized) {
      activeUserAsync.whenData((user) {
        if (user != null) {
          _gradeInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedGrade = user.grade);
            }
          });
        }
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 学科横幅
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: config.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                config.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      config.color,
                      config.color.withValues(alpha:0.7),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      config.icon,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 页面内容
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 年级选择器
                _buildSectionTitle(theme, '选择年级'),
                const SizedBox(height: 8),
                _buildGradeSelector(theme, config.color),
                const SizedBox(height: 24),
                // 难度选择器
                _buildSectionTitle(theme, '选择难度'),
                const SizedBox(height: 8),
                _buildDifficultySelector(theme, config.color),
                const SizedBox(height: 32),
                // "开始答题"按钮
                _buildStartButton(theme, config),
                const SizedBox(height: 32),
                // 最近成绩记录
                _buildSectionTitle(theme, '最近成绩'),
                const SizedBox(height: 12),
                _buildScoreHistory(theme),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建区块标题。
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 构建年级选择芯片组。
  Widget _buildGradeSelector(ThemeData theme, Color accentColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(9, (index) {
        final grade = index + 1;
        final isSelected = _selectedGrade == grade;
        final gradeColor = grade <= AppColors.gradeColors.length
            ? AppColors.gradeColors[grade - 1]
            : accentColor;

        return ChoiceChip(
          label: Text('$grade年级'),
          selected: isSelected,
          selectedColor: gradeColor.withValues(alpha:0.2),
          backgroundColor: AppColors.background,
          side: BorderSide(
            color: isSelected ? gradeColor : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? gradeColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          onSelected: (_) {
            setState(() => _selectedGrade = grade);
          },
        );
      }),
    );
  }

  /// 构建难度选择器。
  Widget _buildDifficultySelector(ThemeData theme, Color accentColor) {
    return Row(
      children: List.generate(5, (index) {
        final difficulty = index + 1;
        final isSelected = _selectedDifficulty == difficulty;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedDifficulty = difficulty);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha:0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 难度星级
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(difficulty, (_) {
                      return Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: isSelected
                            ? AppColors.achievementStar
                            : AppColors.divider,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 构建"开始答题"按钮。
  Widget _buildStartButton(ThemeData theme, _SubjectConfig config) {
    return FilledButton.icon(
      onPressed: _isLoading ? null : () => _startQuiz(config),
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.play_arrow_rounded, size: 28),
      label: Text(_isLoading ? '加载中...' : '开始答题'),
      style: FilledButton.styleFrom(
        backgroundColor: config.color,
        disabledBackgroundColor: config.color.withValues(alpha:0.5),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 加载题目并导航至测验页面。
  Future<void> _startQuiz(_SubjectConfig config) async {
    setState(() => _isLoading = true);

    try {
      final loader = ref.read(contentLoaderProvider);
      final questions = await loader.loadQuestions(
        'intellect',
        subject: config.subjectKey,
        grade: _selectedGrade,
        difficulty: _selectedDifficulty,
      );

      if (!mounted) return;

      if (questions.isEmpty) {
        _showNoQuestionsDialog();
        return;
      }

      // 导航至测验页面，通过 extra 参数传递题目列表
      context.push(
        '/quiz/intellect',
        extra: questions,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载题目失败: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 显示无题目提示对话框。
  void _showNoQuestionsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('暂无题目'),
          content: const Text('当前年级和难度下暂无可用题目，请尝试调整筛选条件。'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  /// 构建最近成绩记录列表（占位数据）。
  Widget _buildScoreHistory(ThemeData theme) {
    // 占位成绩数据
    final placeholderScores = [
      _ScoreRecord(date: '2026-03-25', score: 85, total: 10, correct: 8),
      _ScoreRecord(date: '2026-03-22', score: 72, total: 10, correct: 7),
      _ScoreRecord(date: '2026-03-18', score: 95, total: 10, correct: 9),
    ];

    if (placeholderScores.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              '暂无成绩记录',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          for (int i = 0; i < placeholderScores.length; i++) ...[
            _buildScoreRow(theme, placeholderScores[i]),
            if (i < placeholderScores.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }

  /// 构建单条成绩行。
  Widget _buildScoreRow(ThemeData theme, _ScoreRecord record) {
    final percentage = record.total > 0 ? record.correct / record.total : 0.0;
    final starCount = percentage >= 0.9
        ? 5
        : percentage >= 0.7
            ? 4
            : percentage >= 0.5
                ? 3
                : percentage >= 0.3
                    ? 2
                    : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 日期
          Text(
            record.date,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          // 星级
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                index < starCount
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 14,
                color: index < starCount
                    ? AppColors.achievementStar
                    : AppColors.divider,
              );
            }),
          ),
          const Spacer(),
          // 正确率
          Text(
            '${record.correct}/${record.total}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          // 分数
          Text(
            '${record.score}分',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.xpGold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 成绩记录数据类。
class _ScoreRecord {
  const _ScoreRecord({
    required this.date,
    required this.score,
    required this.total,
    required this.correct,
  });

  final String date;
  final int score;
  final int total;
  final int correct;
}
