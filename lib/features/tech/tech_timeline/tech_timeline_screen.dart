import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';

// ---------------------------------------------------------------------------
// 时间线数据模型
// ---------------------------------------------------------------------------

/// 时间线中的单个时代/节点的不可变数据模型。
class _TimelineEra {
  const _TimelineEra({
    required this.title,
    required this.icon,
    required this.summary,
    this.detailSections = const [],
    this.funFacts = const [],
  });

  final String title;
  final IconData icon;
  final String summary;
  final List<_DetailSection> detailSections;
  final List<String> funFacts;
}

/// 时间线节点展开后的详细内容分段。
class _DetailSection {
  const _DetailSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

// ---------------------------------------------------------------------------
// 占位数据（当远程资源加载失败时使用）
// ---------------------------------------------------------------------------

/// 当无法从资源文件加载数据时显示的默认时代卡片列表。
const List<_TimelineEra> _placeholderEras = [
  _TimelineEra(
    title: '古代科技',
    icon: Icons.account_balance_rounded,
    summary: '从造纸术、火药到指南针，古代先民的智慧照亮了人类文明之路。',
    detailSections: [
      _DetailSection(
        heading: '四大发明',
        body: '造纸术、印刷术、火药和指南针是中国古代对世界文明最重要的贡献，'
            '深刻影响了人类社会的发展进程。',
      ),
      _DetailSection(
        heading: '天文观测',
        body: '古代天文学家通过肉眼观测星空，建立了精确的历法体系，'
            '为农业生产和航海导航提供了重要依据。',
      ),
    ],
    funFacts: [
      '中国在公元前1300年就已经有了日食记录',
      '古埃及金字塔的建造精度令现代工程师惊叹',
    ],
  ),
  _TimelineEra(
    title: '工业革命',
    icon: Icons.precision_manufacturing_rounded,
    summary: '蒸汽机的发明开启了机械化时代，彻底改变了人类的生产方式。',
    detailSections: [
      _DetailSection(
        heading: '蒸汽动力',
        body: '瓦特改良蒸汽机后，工厂不再依赖水力和风力，'
            '大规模机械化生产成为可能。',
      ),
      _DetailSection(
        heading: '交通变革',
        body: '蒸汽火车和轮船的出现缩短了城市间的距离，'
            '加速了全球贸易和文化交流。',
      ),
    ],
    funFacts: [
      '世界上第一条铁路于1825年在英国开通',
      '工业革命期间伦敦人口增长了6倍',
    ],
  ),
  _TimelineEra(
    title: '信息时代',
    icon: Icons.computer_rounded,
    summary: '从第一台计算机到互联网普及，信息技术彻底改变了人们的生活方式。',
    detailSections: [
      _DetailSection(
        heading: '计算机发展',
        body: '从占据整个房间的ENIAC到口袋里的智能手机，'
            '计算能力在短短几十年间提升了数十亿倍。',
      ),
      _DetailSection(
        heading: '互联网革命',
        body: '万维网的诞生让全球信息互联互通，'
            '社交媒体、电子商务和在线教育改变了社会的方方面面。',
      ),
    ],
    funFacts: [
      '第一封电子邮件发送于1971年',
      '如今全球互联网用户超过50亿',
    ],
  ),
  _TimelineEra(
    title: '未来科技',
    icon: Icons.auto_awesome_rounded,
    summary: '人工智能、量子计算和太空探索正在塑造人类的未来。',
    detailSections: [
      _DetailSection(
        heading: '人工智能',
        body: 'AI技术正在医疗、教育、交通等领域发挥越来越重要的作用，'
            '有望解决许多人类面临的重大挑战。',
      ),
      _DetailSection(
        heading: '太空探索',
        body: '从月球基地到火星移民计划，'
            '人类正在迈向成为多星球物种的征程。',
      ),
    ],
    funFacts: [
      '量子计算机可以在几分钟内完成传统计算机数千年的运算',
      'SpaceX的目标是在2030年前将人类送上火星',
    ],
  ),
];

// ---------------------------------------------------------------------------
// 状态管理
// ---------------------------------------------------------------------------

/// 时间线数据加载状态的提供者。
///
/// 尝试从 assets/content/tech/timeline/ 加载 JSON 数据，
/// 加载失败时使用占位数据。
final techTimelineProvider =
    FutureProvider.autoDispose<List<_TimelineEra>>((ref) async {
  try {
    final jsonString = await rootBundle
        .loadString('assets/content/tech/timeline/timeline.json');
    final decoded = json.decode(jsonString);

    final List<dynamic> rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded.containsKey('data')) {
      rawList = decoded['data'] as List<dynamic>;
    } else {
      return _placeholderEras;
    }

    return rawList.map((e) {
      final map = e as Map<String, dynamic>;
      return _TimelineEra(
        title: map['title'] as String,
        icon: _resolveIcon(map['icon'] as String?),
        summary: map['summary'] as String,
        detailSections: (map['detail_sections'] as List<dynamic>?)
                ?.map((s) => _DetailSection(
                      heading: (s as Map<String, dynamic>)['heading'] as String,
                      body: s['body'] as String,
                    ))
                .toList() ??
            const [],
        funFacts: (map['fun_facts'] as List<dynamic>?)
                ?.map((f) => f as String)
                .toList() ??
            const [],
      );
    }).toList();
  } catch (_) {
    // 资源文件不存在或解析失败，返回占位数据
    return _placeholderEras;
  }
});

/// 根据字符串名称解析对应的 Material 图标。
IconData _resolveIcon(String? iconName) {
  switch (iconName) {
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'precision_manufacturing':
      return Icons.precision_manufacturing_rounded;
    case 'computer':
      return Icons.computer_rounded;
    case 'auto_awesome':
      return Icons.auto_awesome_rounded;
    default:
      return Icons.history_rounded;
  }
}

// ---------------------------------------------------------------------------
// 页面组件
// ---------------------------------------------------------------------------

/// 科技时间线交互页面。
///
/// 使用垂直滚动的时间线布局展示科技发展的各个时代。
/// 每个节点包含时代图标、标题和摘要，点击可展开查看详细内容和趣味知识。
class TechTimelineScreen extends ConsumerWidget {
  const TechTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEras = ref.watch(techTimelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('科技时间线'),
        backgroundColor: AppColors.tech,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: asyncEras.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('加载失败: $error'),
        ),
        data: (eras) => _TimelineBody(eras: eras),
      ),
    );
  }
}

/// 时间线主体内容，使用 ListView.builder 构建可滚动的时间线。
class _TimelineBody extends StatefulWidget {
  const _TimelineBody({required this.eras});

  final List<_TimelineEra> eras;

  @override
  State<_TimelineBody> createState() => _TimelineBodyState();
}

class _TimelineBodyState extends State<_TimelineBody> {
  /// 记录每个时间线节点的展开状态。
  final Set<int> _expandedIndices = {};

  /// 切换指定索引节点的展开/折叠状态。
  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: widget.eras.length,
      itemBuilder: (context, index) {
        final era = widget.eras[index];
        final isExpanded = _expandedIndices.contains(index);
        final isLast = index == widget.eras.length - 1;

        return _TimelineItem(
          era: era,
          isExpanded: isExpanded,
          isLast: isLast,
          onTap: () => _toggleExpanded(index),
        );
      },
    );
  }
}

/// 单个时间线节点组件。
///
/// 左侧绘制圆点和连接线，右侧展示时代卡片。
/// 支持点击展开显示详细分段和趣味知识。
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.era,
    required this.isExpanded,
    required this.isLast,
    required this.onTap,
  });

  final _TimelineEra era;
  final bool isExpanded;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间线轨道（圆点 + 连接线）
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // 时间线圆点
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.tech,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.techLight,
                      width: 3,
                    ),
                  ),
                ),
                // 连接线（最后一个节点不显示）
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.techLight,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 右侧内容卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildCard(context, theme),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建时代内容卡片，包含标题、摘要和可展开的详细内容。
  Widget _buildCard(BuildContext context, ThemeData theme) {
    return Card(
      elevation: isExpanded ? 4 : 1,
      shadowColor: AppColors.tech.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpanded
            ? const BorderSide(color: AppColors.tech, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标和标题行
              Row(
                children: [
                  Icon(era.icon, color: AppColors.tech, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      era.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 展开/折叠指示图标
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 摘要文字
              Text(
                era.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              // 展开的详细内容
              if (isExpanded) ...[
                const Divider(height: 24),
                // 详细分段
                ...era.detailSections.map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.heading,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.tech,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            section.body,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )),
                // 趣味知识
                if (era.funFacts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.techLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: AppColors.tech,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '趣味知识',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.tech,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...era.funFacts.map((fact) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('  '),
                                  Expanded(
                                    child: Text(
                                      fact,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
