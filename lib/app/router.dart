import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/features/general/card_browser_screen.dart';
import 'package:student_study/features/general/general_screen.dart'
    as general_feature;
import 'package:student_study/features/intellect/intellect_screen.dart';
import 'package:student_study/features/intellect/subject_screen.dart';
import 'package:student_study/features/logic/logic_screen.dart';
import 'package:student_study/features/logic/deduction/deduction_screen.dart';
import 'package:student_study/features/logic/pattern/pattern_screen.dart';
import 'package:student_study/features/logic/spatial/spatial_screen.dart';
import 'package:student_study/features/logic/strategy/strategy_screen.dart';
import 'package:student_study/features/logic/strategy/sudoku_screen.dart';
import 'package:student_study/features/parent/parent_screen.dart'
    as parent_feature;
import 'package:student_study/features/profile/edit_profile_screen.dart';
import 'package:student_study/features/profile/learning_resources_screen.dart';
import 'package:student_study/features/profile/profile_screen.dart'
    as profile_feature;
import 'package:student_study/features/profile/settings_screen.dart'
    as settings_feature;
import 'package:student_study/features/quiz/quiz_screen.dart';
import 'package:student_study/features/tech/tech_screen.dart';
import 'package:student_study/features/tech/aerospace/aerospace_screen.dart';
import 'package:student_study/features/tech/ai_intro/ai_intro_screen.dart';
import 'package:student_study/features/tech/programming/programming_screen.dart';
import 'package:student_study/features/tech/tech_timeline/tech_timeline_screen.dart';
import 'package:student_study/features/tech/virtual_lab/experiment_detail_screen.dart';
import 'package:student_study/features/tech/virtual_lab/virtual_lab_screen.dart';
import 'package:student_study/features/words/words_screen.dart';
import 'package:student_study/features/words/word_game_screen.dart';
import 'theme/colors.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// 应用路由路径常量，避免使用魔法字符串。
abstract final class AppRoutes {
  static const String home = '/';
  static const String intellect = '/intellect';
  static const String tech = '/tech';
  static const String logic = '/logic';
  static const String general = '/general';
  static const String generalCards = '/general/cards/:categoryId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String module = '/module/:moduleId';
  static const String subModule = '/module/:moduleId/:subModuleId';
  static const String quiz = '/quiz/:moduleId';
  static const String parent = '/parent';
  static const String settings = '/settings';
  static const String resources = '/resources';
  static const String words = '/words';
  static const String wordGame = '/words/game/:categoryId';
}

/// 根据模块和子模块 ID 返回对应的真实页面组件。
Widget _resolveSubModuleScreen(String moduleId, String subModuleId) {
  switch (moduleId) {
    case 'intellect':
      return SubjectScreen(subjectId: subModuleId);
    case 'tech':
      return switch (subModuleId) {
        'programming' => const ProgrammingScreen(),
        'ai_intro' => const AiIntroScreen(),
        'virtual_lab' => const VirtualLabScreen(),
        'aerospace' => const AerospaceScreen(),
        'tech_timeline' => const TechTimelineScreen(),
        _ => const TechScreen(),
      };
    case 'logic':
      return switch (subModuleId) {
        'pattern' => const PatternScreen(),
        'strategy' => const StrategyScreen(),
        'spatial' => const SpatialScreen(),
        'deduction' => const DeductionScreen(),
        _ => const LogicScreen(),
      };
    default:
      return const IntellectModuleScreen();
  }
}

/// 根据模块 ID 返回对应的模块主页面。
Widget _resolveModuleScreen(String moduleId) {
  return switch (moduleId) {
    'intellect' => const IntellectModuleScreen(),
    'tech' => const TechScreen(),
    'logic' => const LogicScreen(),
    'general' => const general_feature.GeneralScreen(),
    _ => const IntellectModuleScreen(),
  };
}

/// 少年研学应用的主路由配置。
/// 使用 StatefulShellRoute 保持底部导航的状态持久化。
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // 标签 0：智育
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const IntellectModuleScreen(),
            ),
          ],
        ),
        // 标签 1：科技
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tech',
              builder: (context, state) => const TechScreen(),
            ),
          ],
        ),
        // 标签 2：逻辑
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/logic',
              builder: (context, state) => const LogicScreen(),
            ),
          ],
        ),
        // 标签 3：通识
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/general',
              builder: (context, state) =>
                  const general_feature.GeneralScreen(),
            ),
          ],
        ),
        // 标签 4：个人中心
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const profile_feature.ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) =>
                      const settings_feature.SettingsScreen(),
                ),
                GoRoute(
                  path: 'parent',
                  builder: (context, state) =>
                      const parent_feature.ParentScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // 全屏路由（不在底部导航中）
    GoRoute(
      path: '/module/:moduleId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final moduleId = state.pathParameters['moduleId']!;
        return _resolveModuleScreen(moduleId);
      },
      routes: [
        GoRoute(
          path: ':subModuleId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final moduleId = state.pathParameters['moduleId']!;
            final subModuleId = state.pathParameters['subModuleId']!;
            return _resolveSubModuleScreen(moduleId, subModuleId);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/quiz/:moduleId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final questions = state.extra as List<Question>?;
        if (questions != null && questions.isNotEmpty) {
          return QuizInteractionScreen(questions: questions);
        }
        // 无题目时返回模块主页
        final moduleId = state.pathParameters['moduleId']!;
        return _resolveModuleScreen(moduleId);
      },
    ),
    // 数独游戏页面（全屏路由）
    GoRoute(
      path: '/module/logic/sudoku',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SudokuScreen(),
    ),
    // 虚拟实验室实验详情页面（全屏路由）
    GoRoute(
      path: '/module/tech/virtual_lab/experiment/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExperimentDetailScreen(experimentId: id);
      },
    ),
    // 百科卡片浏览页面（全屏路由）
    GoRoute(
      path: '/general/cards/:categoryId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final categoryName = (state.extra as String?) ?? '百科卡片';
        return CardBrowserScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),
    // 好词好句模块路由
    GoRoute(
      path: '/words',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WordsScreen(),
    ),
    GoRoute(
      path: '/words/game/:categoryId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final extra = state.extra as Map<String, dynamic>?;
        final categoryName = extra?['name'] as String? ?? '好词好句';
        final assetPath = extra?['assetPath'] as String? ??
            'assets/content/words/$categoryId.json';
        final themeColor = extra?['color'] as Color? ?? AppColors.moral;
        return WordGameScreen(
          categoryName: categoryName,
          assetPath: assetPath,
          themeColor: themeColor,
        );
      },
    ),
    GoRoute(
      path: '/parent',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const parent_feature.ParentScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const settings_feature.SettingsScreen(),
    ),
    // 学习资源页面（全屏路由）
    GoRoute(
      path: '/resources',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LearningResourcesScreen(),
    ),
  ],
);

/// 提供跨标签页持久化底部导航的外壳脚手架。
class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded, color: AppColors.intellect),
            label: '智育',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_outlined),
            selectedIcon: Icon(Icons.rocket_launch_rounded, color: AppColors.tech),
            label: '科技',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology_rounded, color: AppColors.logic),
            label: '逻辑',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public_rounded, color: AppColors.general),
            label: '通识',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: '个人中心',
          ),
        ],
      ),
    );
  }
}
