import 'package:flutter/material.dart';

/// 开发阶段使用的占位页面组件。
/// 每个路由显示一个居中的页面名称标签。
/// 后续将替换为真实的功能实现。
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon,
    this.color,
  });

  final String title;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = color ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.construction_rounded,
              size: 64,
              color: displayColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: displayColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '即将上线',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '首页',
      icon: Icons.home_rounded,
    );
  }
}

class IntellectScreen extends StatelessWidget {
  const IntellectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '智育',
      icon: Icons.school_rounded,
      color: Color(0xFF1976D2),
    );
  }
}

class TechScreen extends StatelessWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '科技',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF7B1FA2),
    );
  }
}

class LogicScreen extends StatelessWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '逻辑',
      icon: Icons.psychology_rounded,
      color: Color(0xFF00897B),
    );
  }
}

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '通识',
      icon: Icons.public_rounded,
      color: Color(0xFFF9A825),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '个人中心',
      icon: Icons.person_rounded,
    );
  }
}

class ModuleScreen extends StatelessWidget {
  const ModuleScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: '模块: $moduleId',
      icon: Icons.view_module_rounded,
    );
  }
}

class SubModuleScreen extends StatelessWidget {
  const SubModuleScreen({
    super.key,
    required this.moduleId,
    required this.subModuleId,
  });

  final String moduleId;
  final String subModuleId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: '子模块: $subModuleId',
      icon: Icons.article_rounded,
    );
  }
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: '测验: $moduleId',
      icon: Icons.quiz_rounded,
      color: const Color(0xFFFF8F00),
    );
  }
}

class ParentScreen extends StatelessWidget {
  const ParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '家长中心',
      icon: Icons.family_restroom_rounded,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '设置',
      icon: Icons.settings_rounded,
    );
  }
}
