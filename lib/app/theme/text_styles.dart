import 'package:flutter/material.dart';

import 'colors.dart';

/// 适合儿童的文字样式定义，使用较大的默认字号，
/// 确保6-15岁年龄段的可读性。
abstract final class AppTextStyles {
  static const String _fontFamily = 'Noto Sans SC';

  // 展示样式
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // 标题样式
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // 副标题样式
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // 正文样式（比 Material 默认值大，提高儿童可读性）
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // 标签样式
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // 教育场景专用样式
  static const TextStyle quizQuestion = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle quizOption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle scoreDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.xpGold,
  );

  static const TextStyle streakCounter = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.streakFlame,
  );

  /// 构建完整的 [TextTheme] 用于 [ThemeData]。
  static TextTheme textTheme({Color? color}) {
    final baseColor = color ?? AppColors.textPrimary;
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: baseColor),
      displayMedium: displayMedium.copyWith(color: baseColor),
      displaySmall: displaySmall.copyWith(color: baseColor),
      headlineLarge: headingLarge.copyWith(color: baseColor),
      headlineMedium: headingMedium.copyWith(color: baseColor),
      headlineSmall: headingSmall.copyWith(color: baseColor),
      titleLarge: titleLarge.copyWith(color: baseColor),
      titleMedium: titleMedium.copyWith(color: baseColor),
      titleSmall: titleSmall.copyWith(color: baseColor),
      bodyLarge: bodyLarge.copyWith(color: baseColor),
      bodyMedium: bodyMedium.copyWith(color: baseColor),
      bodySmall: bodySmall.copyWith(color: baseColor),
      labelLarge: labelLarge.copyWith(color: baseColor),
      labelMedium: labelMedium.copyWith(color: baseColor),
      labelSmall: labelSmall.copyWith(color: baseColor),
    );
  }
}
