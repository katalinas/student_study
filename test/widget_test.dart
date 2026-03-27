// 基础冒烟测试
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/app/app.dart';
import 'package:student_study/core/user/user_provider.dart';

void main() {
  testWidgets('应用启动冒烟测试', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const StudentStudyApp(),
      ),
    );

    // 验证应用能正常渲染
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
