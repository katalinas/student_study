import 'package:flutter/material.dart';

/// 少年研学应用的核心颜色常量。
abstract final class AppColors {
  // 主色调
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  // 辅助色调
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFC046);
  static const Color secondaryDark = Color(0xFFC56000);

  // 第三色调
  static const Color tertiary = Color(0xFF2E7D32);
  static const Color tertiaryLight = Color(0xFF60AD5E);
  static const Color tertiaryDark = Color(0xFF005005);

  // 模块颜色
  static const Color intellect = Color(0xFF1976D2);
  static const Color tech = Color(0xFF7B1FA2);
  static const Color logic = Color(0xFF00897B);
  static const Color general = Color(0xFFF9A825);
  static const Color moral = Color(0xFFC62828);

  // 模块颜色 - 浅色变体（用于背景）
  static const Color intellectLight = Color(0xFFBBDEFB);
  static const Color techLight = Color(0xFFE1BEE7);
  static const Color logicLight = Color(0xFFB2DFDB);
  static const Color generalLight = Color(0xFFFFF9C4);
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
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0288D1);

  // 中性颜色
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // 深色模式中性颜色
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkDivider = Color(0xFF424242);

  // 游戏化颜色
  static const Color xpGold = Color(0xFFFFD700);
  static const Color streakFlame = Color(0xFFFF6D00);
  static const Color achievementStar = Color(0xFFFFC107);
}
