import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:student_study/core/user/user_provider.dart';

/// 主题模式枚举。
enum ThemeModeOption {
  light('浅色'),
  dark('深色'),
  system('跟随系统');

  const ThemeModeOption(this.label);

  /// 显示文本。
  final String label;
}

/// 字体大小枚举。
enum FontSizeOption {
  normal('标准'),
  large('大'),
  extraLarge('超大');

  const FontSizeOption(this.label);

  /// 显示文本。
  final String label;
}

/// 设置页面。
///
/// 提供主题模式、字体大小、音效、背景音乐、清除缓存等设置项，
/// 以及跳转到家长面板的入口。
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// 当前主题模式。
  ThemeModeOption _themeMode = ThemeModeOption.system;

  /// 当前字体大小。
  FontSizeOption _fontSize = FontSizeOption.normal;

  /// 音效是否开启。
  bool _soundEnabled = true;

  /// 背景音乐是否开启。
  bool _musicEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  /// 从 SharedPreferences 加载已保存的设置。
  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);

    final themeIndex = prefs.getInt('settings_theme_mode') ?? 2;
    final fontIndex = prefs.getInt('settings_font_size') ?? 0;

    setState(() {
      _themeMode = ThemeModeOption.values[themeIndex.clamp(0, 2)];
      _fontSize = FontSizeOption.values[fontIndex.clamp(0, 2)];
      _soundEnabled = prefs.getBool('settings_sound') ?? true;
      _musicEnabled = prefs.getBool('settings_music') ?? false;
    });
  }

  /// 保存主题模式设置。
  Future<void> _setThemeMode(ThemeModeOption mode) async {
    setState(() => _themeMode = mode);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('settings_theme_mode', mode.index);
  }

  /// 保存字体大小设置。
  Future<void> _setFontSize(FontSizeOption size) async {
    setState(() => _fontSize = size);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('settings_font_size', size.index);
  }

  /// 保存音效开关设置。
  Future<void> _setSoundEnabled(bool enabled) async {
    setState(() => _soundEnabled = enabled);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('settings_sound', enabled);
  }

  /// 保存背景音乐开关设置。
  Future<void> _setMusicEnabled(bool enabled) async {
    setState(() => _musicEnabled = enabled);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('settings_music', enabled);
  }

  /// 清除缓存操作。
  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除应用缓存吗？不会影响学习数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('缓存已清除')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // 主题模式
          _buildSectionTitle(theme, '主题模式'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeModeOption>(
              segments: ThemeModeOption.values.map((option) {
                return ButtonSegment<ThemeModeOption>(
                  value: option,
                  label: Text(option.label),
                );
              }).toList(),
              selected: {_themeMode},
              onSelectionChanged: (values) => _setThemeMode(values.first),
            ),
          ),

          const Divider(height: 1),

          // 字体大小
          _buildSectionTitle(theme, '字体大小'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<FontSizeOption>(
              segments: FontSizeOption.values.map((option) {
                return ButtonSegment<FontSizeOption>(
                  value: option,
                  label: Text(option.label),
                );
              }).toList(),
              selected: {_fontSize},
              onSelectionChanged: (values) => _setFontSize(values.first),
            ),
          ),

          const Divider(height: 1),

          // 音效开关
          SwitchListTile(
            title: const Text('音效开关'),
            subtitle: const Text('答题和交互的音效'),
            value: _soundEnabled,
            onChanged: _setSoundEnabled,
          ),

          // 背景音乐
          SwitchListTile(
            title: const Text('背景音乐'),
            subtitle: const Text('学习时的背景音乐'),
            value: _musicEnabled,
            onChanged: _setMusicEnabled,
          ),

          const Divider(height: 1),

          // 关于
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('少年研学 v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '少年研学',
                applicationVersion: '1.0.0',
                applicationLegalese: '专为中小学生打造的综合学习应用',
              );
            },
          ),

          // 清除缓存
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('清除缓存'),
            onTap: _clearCache,
          ),

          const Divider(height: 1),

          // 家长面板入口
          ListTile(
            leading: const Icon(Icons.family_restroom_outlined),
            title: const Text('家长面板'),
            subtitle: const Text('查看学习报告和管理设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/parent'),
          ),
        ],
      ),
    );
  }

  /// 构建分节标题。
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
