import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/core/user/user_provider.dart';

/// 预设头像图标列表，与 profile_screen 保持一致。
const List<IconData> _avatarIcons = [
  Icons.pets,
  Icons.cruelty_free,
  Icons.emoji_nature,
  Icons.flutter_dash,
  Icons.pest_control,
  Icons.bug_report,
  Icons.set_meal,
  Icons.sailing,
  Icons.forest,
  Icons.park,
  Icons.eco,
  Icons.spa,
];

/// 编辑用户资料页面。
///
/// 支持选择头像、修改昵称、选择年级、保存和删除账户操作。
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  /// 昵称输入控制器。
  late final TextEditingController _nameController;

  /// 当前选中的头像索引。
  int _selectedAvatar = 0;

  /// 当前选中的年级。
  int _selectedGrade = 1;

  /// 是否正在保存中。
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    // 延迟到首帧后加载用户数据
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrentUser());
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 加载当前用户资料填充表单。
  void _loadCurrentUser() {
    final user = ref.read(activeUserProvider).value;
    if (user == null) return;

    setState(() {
      _nameController.text = user.name;
      _selectedAvatar = user.avatarIndex;
      _selectedGrade = user.grade;
    });
  }

  /// 保存修改后的用户资料。
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入昵称')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final user = ref.read(activeUserProvider).value;
    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    // 创建更新后的不可变用户对象
    final updatedUser = user.copyWith(
      name: name,
      avatarIndex: _selectedAvatar,
      grade: _selectedGrade,
    );

    await ref.read(activeUserProvider.notifier).createAndActivate(updatedUser);

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// 显示删除账户确认对话框。
  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除账户后所有学习数据将无法恢复，确定要删除吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = ref.read(activeUserProvider).value;
      if (user != null) {
        await ref.read(activeUserProvider.notifier).deleteUser(user.id);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像选择区域
            _buildAvatarSelector(theme),
            const SizedBox(height: 28),

            // 昵称输入
            _buildNameInput(theme),
            const SizedBox(height: 24),

            // 年级选择
            _buildGradeSelector(theme),
            const SizedBox(height: 36),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('保存', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),

            // 删除账户按钮
            Center(
              child: TextButton(
                onPressed: _showDeleteConfirmation,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('删除账户'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头像横向滚动选择器。
  Widget _buildAvatarSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择头像',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarIcons.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedAvatar;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary.withValues(alpha:0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2.5)
                        : null,
                  ),
                  child: Icon(
                    _avatarIcons[index],
                    size: 30,
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建昵称文本输入框。
  Widget _buildNameInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '昵称',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          maxLength: 20,
          decoration: InputDecoration(
            hintText: '请输入昵称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建年级下拉选择器。
  Widget _buildGradeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '年级',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _selectedGrade,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: List.generate(9, (index) {
            final grade = index + 1;
            return DropdownMenuItem<int>(
              value: grade,
              child: Text('$grade年级'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedGrade = value);
            }
          },
        ),
      ],
    );
  }
}
