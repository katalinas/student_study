/// 航天航空知识卡片页面。
///
/// 从内容加载器读取航天航空科普卡片，以可展开的知识卡片形式
/// 展示火箭、太阳系等航天知识。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/content/content_loader.dart';

// ---------------------------------------------------------------------------
// 内容加载器提供者
// ---------------------------------------------------------------------------

/// 航天航空卡片的内容加载提供者。
final _aerospaceCardsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final loader = ContentLoader();
  return loader.loadCards('tech', category: 'aerospace');
});

// ---------------------------------------------------------------------------
// 主题色
// ---------------------------------------------------------------------------

const _themeColor = Color(0xFFFF7043);

// ---------------------------------------------------------------------------
// 页面组件
// ---------------------------------------------------------------------------

/// 航天航空知识卡片页面，以可展开列表展示航天知识。
class AerospaceScreen extends ConsumerWidget {
  const AerospaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(_aerospaceCardsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('航天航空'),
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: cardsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _themeColor),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.rocket_launch_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                '加载失败，请重试',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 64,
                color: AppColors.textSecondary,
              ),
            );
          }
          return Column(
            children: [
              _buildStatsBar(context, cards.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return _CardTile(
                      index: index + 1,
                      card: cards[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _themeColor.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: _themeColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: _themeColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '共 $count 个知识点',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _themeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 知识卡片组件
// ---------------------------------------------------------------------------

class _CardTile extends StatelessWidget {
  const _CardTile({required this.index, required this.card});

  final int index;
  final Map<String, dynamic> card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = card['title'] as String? ?? '';
    final summary = card['summary'] as String? ?? '';
    final sections =
        (card['detail_sections'] as List<dynamic>?) ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: _themeColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _themeColor.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _themeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$index',
              style: theme.textTheme.labelMedium?.copyWith(
                color: _themeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        iconColor: _themeColor,
        collapsedIconColor: AppColors.textSecondary,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...sections.map((section) {
            final s = section as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['title'] as String? ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _themeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _themeColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s['text'] as String? ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
