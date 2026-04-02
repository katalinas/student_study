import 'package:flutter/material.dart';

/// 少年研学应用的核心颜色常量 — 翠绿主题。
abstract final class AppColors {
  // 主色调 — 翠绿
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF005B4F);

  // 辅助色调 — 暖琥珀
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryLight = Color(0xFFFFE97D);
  static const Color secondaryDark = Color(0xFFC88719);

  // 第三色调 — 天青
  static const Color tertiary = Color(0xFF4FC3F7);
  static const Color tertiaryLight = Color(0xFF8BF6FF);
  static const Color tertiaryDark = Color(0xFF0093C4);

  // 模块颜色
  static const Color intellect = Color(0xFF26A69A);
  static const Color tech = Color(0xFF7E57C2);
  static const Color logic = Color(0xFF42A5F5);
  static const Color general = Color(0xFFFFA726);
  static const Color moral = Color(0xFFEF5350);

  // 模块颜色 - 浅色变体（用于背景）
  static const Color intellectLight = Color(0xFFB2DFDB);
  static const Color techLight = Color(0xFFD1C4E9);
  static const Color logicLight = Color(0xFFBBDEFB);
  static const Color generalLight = Color(0xFFFFE0B2);
  static const Color moralLight = Color(0xFFFFCDD2);

  // 年级颜色（1-9年级）
  static const Color grade1 = Color(0xFFE91E63);
  static const Color grade2 = Color(0xFFF44336);
  static const Color grade3 = Color(0xFFFF9800);
  static const Color grade4 = Color(0xFFFFEB3B);
  static const Color grade5 = Color(0xFF4CAF50);
  static const Color grade6 = Color(0xFF009688);
  static const Color grade7 = Color(0xFF2196F3);
  static const Color grade8 = Color(0xFF3F51B5);
  static const Color grade9 = Color(0xFF9C27B0);

  static const List<Color> gradeColors = [
    grade1,
    grade2,
    grade3,
    grade4,
    grade5,
    grade6,
    grade7,
    grade8,
    grade9,
  ];

  // 语义颜色
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // 中性颜色
  static const Color background = Color(0xFFF1F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B2D2A);
  static const Color textSecondary = Color(0xFF607D75);
  static const Color divider = Color(0xFFD5E5E0);

  // 深色模式中性颜色
  static const Color darkBackground = Color(0xFF0F1A18);
  static const Color darkSurface = Color(0xFF1A2825);
  static const Color darkTextPrimary = Color(0xFFE0F2EF);
  static const Color darkTextSecondary = Color(0xFF8FA9A2);
  static const Color darkDivider = Color(0xFF2E4A43);

  // 游戏化颜色
  static const Color xpGold = Color(0xFFFFD54F);
  static const Color streakFlame = Color(0xFFFF7043);
  static const Color achievementStar = Color(0xFFFFCA28);
}
