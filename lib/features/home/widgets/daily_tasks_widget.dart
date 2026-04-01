import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/gamification/daily_task.dart';

/// 今日任务卡片组件，展示每日 3~5 个学习任务。
class DailyTasksWidget extends ConsumerWidget {
  const DailyTasksWidget({super.key, this.onTaskTap});

  /// 点击任务时的回调，传入模块标识
  final void Function(String moduleId)? onTaskTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(dailyTaskProvider);
    final tasks = taskState.tasks;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                '今日任务',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              // 完成进度
              Text(
                '${taskState.completedCount}/${tasks.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),

          // 全部完成奖励提示
          if (taskState.allComplete && tasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.xpGold.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.xpGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '完成全部任务！获得额外奖励',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 任务列表
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  '暂无任务',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            )
          else
            ...tasks.map((task) => _TaskItem(
                  task: task,
                  onTap: onTaskTap != null
                      ? () => onTaskTap!(task.moduleId)
                      : null,
                )),
        ],
      ),
    );
  }
}

/// 单个任务项组件
class _TaskItem extends StatelessWidget {
  const _TaskItem({required this.task, this.onTap});

  final DailyTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // 模块颜色图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _moduleColor(task.moduleId).withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _taskTypeIcon(task.taskType),
                color: _moduleColor(task.moduleId),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // 标题和描述
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: task.isComplete
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: task.isComplete
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 进度指示器 / 完成勾选
            if (task.isComplete)
              const Icon(Icons.check_circle, color: AppColors.success, size: 24)
            else
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      '${task.currentCount}/${task.targetCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: task.targetCount > 0
                            ? task.currentCount / task.targetCount
                            : 0,
                        minHeight: 4,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _moduleColor(task.moduleId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 根据模块标识获取对应颜色
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

  /// 根据任务类型获取对应图标
  IconData _taskTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.quiz:
        return Icons.quiz;
      case TaskType.read:
        return Icons.menu_book;
      case TaskType.experiment:
        return Icons.science;
      case TaskType.game:
        return Icons.sports_esports;
    }
  }
}
