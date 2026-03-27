import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_study/app/app.dart';
import 'package:student_study/core/user/user_provider.dart';

/// 应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地存储
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const StudentStudyApp(),
    ),
  );
}
