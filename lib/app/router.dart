import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/core/content/models/question.dart';
import 'package:student_study/features/general/card_browser_screen.dart';
import 'package:student_study/features/general/general_screen.dart'
    as general_feature;
import 'package:student_study/features/intellect/intellect_screen.dart';
import 'package:student_study/features/intellect/subject_screen.dart';
import 'package:student_study/features/parent/parent_screen.dart'
    as parent_feature;
import 'package:student_study/features/profile/edit_profile_screen.dart';
import 'package:student_study/features/profile/profile_screen.dart'
    as profile_feature;
import 'package:student_study/features/profile/settings_screen.dart'
    as settings_feature;
import 'package:student_study/features/quiz/quiz_screen.dart';
import 'package:student_study/features/words/words_screen.dart';
import 'package:student_study/features/words/word_game_screen.dart';
import 'placeholder_screens.dart';
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
  static const String words = '/words';
  static const String wordGame = '/words/game/:categoryId';
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
        return ModuleScreen(moduleId: moduleId);
      },
      routes: [
        GoRoute(
          path: ':subModuleId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final moduleId = state.pathParameters['moduleId']!;
            final subModuleId = state.pathParameters['subModuleId']!;
            // 智育模块的子模块使用学科详情页面
            if (moduleId == 'intellect') {
              return SubjectScreen(subjectId: subModuleId);
            }
            return SubModuleScreen(
              moduleId: moduleId,
              subModuleId: subModuleId,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/quiz/:moduleId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        // 从 extra 参数获取题目列表
        final questions = state.extra as List<Question>?;
        if (questions != null && questions.isNotEmpty) {
          return QuizInteractionScreen(questions: questions);
        }
        // 回退到占位页面
        final moduleId = state.pathParameters['moduleId']!;
        return QuizScreen(moduleId: moduleId);
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
        final categoryName = (state.extra as String?) ?? '好词好句';
        return WordGameScreen(
          categoryId: categoryId,
          categoryName: categoryName,
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
