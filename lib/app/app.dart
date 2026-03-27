import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// 少年研学的根应用组件。
/// 配置 Material 3 主题、中文区域设置和 go_router 导航。
class StudentStudyApp extends StatelessWidget {
  const StudentStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '少年研学',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      routerConfig: appRouter,
    );
  }
}
