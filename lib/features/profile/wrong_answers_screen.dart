import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/gamification/wrong_answer_book.dart';

/// 错题本页面，展示错题记录并支持按模块筛选。
class WrongAnswersScreen extends ConsumerStatefulWidget {
  const WrongAnswersScreen({super.key});

  @override
  ConsumerState<WrongAnswersScreen> createState() => _WrongAnswersScreenState();
}

class _WrongAnswersScreenState extends ConsumerState<WrongAnswersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// 筛选标签：(显示名称, 学科标识, null 表示全部)
  /// 使用 subject 字段筛选，数学/语文/英语均属于 intellect 模块
  static const _tabs = [
    ('全部', null),
    ('数学', 'math'),
    ('语文', 'chinese'),
    ('英语', 'english'),
    ('科学', 'science'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(wrongAnswerBookProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('错题本'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final subject = tab.$2;
          // 按 subject 字段筛选，null 表示显示全部
          final answers = subject == null
              ? bookState.answers
              : bookState.answers
                  .where((a) => a.subject == subject)
                  .toList();
          return _AnswerList(answers: answers);
        }).toList(),
      ),
      floatingActionButton: bookState.reviewDue.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _startReview(context, bookState.reviewDue),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.replay, color: Colors.white),
              label: const Text('开始复习',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  /// 启动复习（占位，实际应导航到答题页面）
  void _startReview(BuildContext context, List<WrongAnswer> reviewList) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('即将复习 ${reviewList.length} 道错题')),
    );
  }
}

/// 错题列表组件
class _AnswerList extends ConsumerWidget {
  const _AnswerList({required this.answers});

  final List<WrongAnswer> answers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (answers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, size: 64, color: AppColors.xpGold),
            const SizedBox(height: 16),
            Text(
              '太棒了，没有错题！',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: answers.length,
      itemBuilder: (context, index) {
        final answer = answers[index];
        return _WrongAnswerCard(answer: answer);
      },
    );
  }
}

/// 单个错题卡片，可展开查看详情。
class _WrongAnswerCard extends ConsumerStatefulWidget {
  const _WrongAnswerCard({required this.answer});

  final WrongAnswer answer;

  @override
  ConsumerState<_WrongAnswerCard> createState() => _WrongAnswerCardState();
}

class _WrongAnswerCardState extends ConsumerState<_WrongAnswerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final answer = widget.answer;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 题干（折叠时截断）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      answer.stem,
                      maxLines: _expanded ? null : 2,
                      overflow: _expanded ? null : TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 模块标签 + 日期 + 复习状态
              Row(
                children: [
                  // 模块标签
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _moduleColor(answer.moduleId).withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer.subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _moduleColor(answer.moduleId),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 日期
                  Text(
                    _formatDate(answer.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),

                  // 复习状态
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: answer.isResolved
                          ? AppColors.success.withValues(alpha:0.15)
                          : AppColors.warning.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      answer.isResolved ? '已掌握' : '待复习',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: answer.isResolved
                                ? AppColors.success
                                : AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),

              // 间隔重复提示
              if (!answer.isResolved) ...[
                const SizedBox(height: 4),
                Text(
                  '下次复习: ${answer.nextReviewLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],

              // 展开详情
              if (_expanded) ...[
                const Divider(height: 24),

                // 用户答案（红色）
                _AnswerRow(
                  label: '你的答案',
                  value: answer.userAnswer,
                  color: AppColors.error,
                ),
                const SizedBox(height: 8),

                // 正确答案（绿色）
                _AnswerRow(
                  label: '正确答案',
                  value: answer.correctAnswer,
                  color: AppColors.success,
                ),
                const SizedBox(height: 8),

                // 解析
                Text(
                  '解析',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  answer.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 根据模块标识获取颜色
  Color _moduleColor(String moduleId) {
    switch (moduleId) {
      case 'intellect':
        return AppColors.intellect;
      case 'tech':
        return AppColors.tech;
      case 'logic':
        return AppColors.logic;
      case 'general':
        return AppColors.general;
      case 'moral':
        return AppColors.moral;
      default:
        return AppColors.primary;
    }
  }

  /// 格式化日期
  String _formatDate(DateTime dt) {
    return '${dt.month}月${dt.day}日';
  }
}

/// 答案行组件（带颜色标记）
class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha:0.3)),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
