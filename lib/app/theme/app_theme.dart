import 'package:flutter/material.dart';

import 'colors.dart';
import 'text_styles.dart';

/// 教育模块颜色的自定义配色方案扩展。
@immutable
class ModuleColors extends ThemeExtension<ModuleColors> {
  const ModuleColors({
    required this.intellect,
    required this.intellectLight,
    required this.tech,
    required this.techLight,
    required this.logic,
    required this.logicLight,
    required this.general,
    required this.generalLight,
    required this.moral,
    required this.moralLight,
  });

  final Color intellect;
  final Color intellectLight;
  final Color tech;
  final Color techLight;
  final Color logic;
  final Color logicLight;
  final Color general;
  final Color generalLight;
  final Color moral;
  final Color moralLight;

  @override
  ModuleColors copyWith({
    Color? intellect,
    Color? intellectLight,
    Color? tech,
    Color? techLight,
    Color? logic,
    Color? logicLight,
    Color? general,
    Color? generalLight,
    Color? moral,
    Color? moralLight,
  }) {
    return ModuleColors(
      intellect: intellect ?? this.intellect,
      intellectLight: intellectLight ?? this.intellectLight,
      tech: tech ?? this.tech,
      techLight: techLight ?? this.techLight,
      logic: logic ?? this.logic,
      logicLight: logicLight ?? this.logicLight,
      general: general ?? this.general,
      generalLight: generalLight ?? this.generalLight,
      moral: moral ?? this.moral,
      moralLight: moralLight ?? this.moralLight,
    );
  }

  @override
  ModuleColors lerp(ThemeExtension<ModuleColors>? other, double t) {
    if (other is! ModuleColors) return this;
    return ModuleColors(
      intellect: Color.lerp(intellect, other.intellect, t)!,
      intellectLight: Color.lerp(intellectLight, other.intellectLight, t)!,
      tech: Color.lerp(tech, other.tech, t)!,
      techLight: Color.lerp(techLight, other.techLight, t)!,
      logic: Color.lerp(logic, other.logic, t)!,
      logicLight: Color.lerp(logicLight, other.logicLight, t)!,
      general: Color.lerp(general, other.general, t)!,
      generalLight: Color.lerp(generalLight, other.generalLight, t)!,
      moral: Color.lerp(moral, other.moral, t)!,
      moralLight: Color.lerp(moralLight, other.moralLight, t)!,
    );
  }
}

/// 游戏化相关颜色的自定义扩展。
@immutable
class GamificationColors extends ThemeExtension<GamificationColors> {
  const GamificationColors({
    required this.xpGold,
    required this.streakFlame,
    required this.achievementStar,
  });

  final Color xpGold;
  final Color streakFlame;
  final Color achievementStar;

  @override
  GamificationColors copyWith({
    Color? xpGold,
    Color? streakFlame,
    Color? achievementStar,
  }) {
    return GamificationColors(
      xpGold: xpGold ?? this.xpGold,
      streakFlame: streakFlame ?? this.streakFlame,
      achievementStar: achievementStar ?? this.achievementStar,
    );
  }

  @override
  GamificationColors lerp(ThemeExtension<GamificationColors>? other, double t) {
    if (other is! GamificationColors) return this;
    return GamificationColors(
      xpGold: Color.lerp(xpGold, other.xpGold, t)!,
      streakFlame: Color.lerp(streakFlame, other.streakFlame, t)!,
      achievementStar: Color.lerp(achievementStar, other.achievementStar, t)!,
    );
  }
}

const _defaultRadius = 16.0;
const _smallRadius = 12.0;

const _defaultModuleColors = ModuleColors(
  intellect: AppColors.intellect,
  intellectLight: AppColors.intellectLight,
  tech: AppColors.tech,
  techLight: AppColors.techLight,
  logic: AppColors.logic,
  logicLight: AppColors.logicLight,
  general: AppColors.general,
  generalLight: AppColors.generalLight,
  moral: AppColors.moral,
  moralLight: AppColors.moralLight,
);

const _defaultGamificationColors = GamificationColors(
  xpGold: AppColors.xpGold,
  streakFlame: AppColors.streakFlame,
  achievementStar: AppColors.achievementStar,
);

/// 少年研学应用的完整 Material 3 主题配置。
abstract final class AppTheme {
  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isLight ? AppColors.primaryLight : const Color(0xFF1A3D38),
      onPrimaryContainer: isLight ? const Color(0xFF002018) : const Color(0xFFB2DFDB),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: isLight ? AppColors.secondaryLight : const Color(0xFF5C3D00),
      onSecondaryContainer: isLight ? const Color(0xFF2A1700) : const Color(0xFFFFDDB3),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: isLight ? AppColors.tertiaryLight : const Color(0xFF004D6E),
      onTertiaryContainer: isLight ? const Color(0xFF001E2E) : const Color(0xFFB3E5FC),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: isLight ? const Color(0xFFFFDAD6) : const Color(0xFF93000A),
      onErrorContainer: isLight ? const Color(0xFF410002) : const Color(0xFFFFDAD6),
      surface: isLight ? AppColors.surface : AppColors.darkSurface,
      onSurface: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
      surfaceContainerHighest: isLight ? const Color(0xFFDBE5E2) : const Color(0xFF2A3836),
      outline: isLight ? const Color(0xFF6F7E7A) : const Color(0xFF899D98),
      outlineVariant: isLight ? AppColors.divider : AppColors.darkDivider,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isLight ? const Color(0xFF2D3331) : const Color(0xFFE0F2EF),
      onInverseSurface: isLight ? const Color(0xFFF0F5F3) : const Color(0xFF2D3331),
      inversePrimary: isLight ? const Color(0xFFA0D5CE) : AppColors.primary,
    );

    final textTheme = AppTextStyles.textTheme(
      color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: isLight ? AppColors.background : AppColors.darkBackground,
      extensions: const [
        _defaultModuleColors,
        _defaultGamificationColors,
      ],

      // 应用栏
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: isLight ? AppColors.surface : AppColors.darkSurface,
        foregroundColor: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
        ),
      ),

      // 卡片
      cardTheme: CardThemeData(
        elevation: isLight ? 2 : 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultRadius),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // 浮起按钮
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // 填充按钮
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // 描边按钮
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_defaultRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // 文字按钮
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_smallRadius),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // 输入框装饰
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? AppColors.surface
            : AppColors.darkSurface.withValues(alpha:0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isLight ? AppColors.textSecondary : AppColors.darkTextSecondary,
        ),
      ),

      // 底部导航栏
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isLight ? AppColors.surface : AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isLight ? AppColors.textSecondary : AppColors.darkTextSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
      ),

      // 导航栏（Material 3）
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 4,
        backgroundColor: isLight ? AppColors.surface : AppColors.darkSurface,
        indicatorColor: AppColors.primary.withValues(alpha:0.15),
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.labelSmall.copyWith(
            color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
          ),
        ),
      ),

      // 标签芯片主题
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: AppTextStyles.labelMedium,
      ),

      // 对话框主题
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultRadius),
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
        ),
      ),

      // 底部弹出面板主题
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: isLight ? AppColors.surface : AppColors.darkSurface,
        showDragHandle: true,
      ),

      // 浮动操作按钮
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultRadius),
        ),
      ),

      // 提示条
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallRadius),
        ),
      ),

      // 进度指示器
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Color(0xFFE0E0E0),
        color: AppColors.primary,
      ),

      // 分割线
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.divider : AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // 页面过渡动画
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
