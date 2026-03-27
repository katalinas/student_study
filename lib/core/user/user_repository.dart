import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_model.dart';

/// 基于 [SharedPreferences] 的 [UserProfile] 对象持久化层。
///
/// 用户资料以 JSON 编码列表存储在 [_usersKey] 下。
/// 当前活跃用户 id 存储在 [_activeUserKey] 下。
class UserRepository {
  const UserRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _usersKey = 'user_profiles';
  static const String _activeUserKey = 'active_user_id';

  // ---------------------------------------------------------------------------
  // 读取
  // ---------------------------------------------------------------------------

  /// 返回所有已保存的用户资料，按创建日期排序（最早的在前）。
  List<UserProfile> getUsers() {
    final raw = _prefs.getStringList(_usersKey);
    if (raw == null || raw.isEmpty) return const [];

    final users = raw
        .map((jsonStr) {
          try {
            final map = json.decode(jsonStr) as Map<String, dynamic>;
            return UserProfile.fromJson(map);
          } catch (_) {
            return null;
          }
        })
        .whereType<UserProfile>()
        .toList();

    users.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return users;
  }

  /// 返回匹配 [id] 的用户资料，未找到则返回 `null`。
  UserProfile? getUser(String id) {
    final users = getUsers();
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  /// 返回当前活跃用户资料，未设置则返回 `null`。
  UserProfile? getActiveUser() {
    final activeId = _prefs.getString(_activeUserKey);
    if (activeId == null) return null;
    return getUser(activeId);
  }

  // ---------------------------------------------------------------------------
  // 写入
  // ---------------------------------------------------------------------------

  /// 持久化 [user]。如果相同 id 的资料已存在则替换；
  /// 否则追加新资料。
  Future<void> saveUser(UserProfile user) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u.id == user.id);

    final List<UserProfile> updated;
    if (index >= 0) {
      updated = [
        for (int i = 0; i < users.length; i++)
          if (i == index) user else users[i],
      ];
    } else {
      updated = [...users, user];
    }

    await _writeAll(updated);
  }

  /// 删除指定 [id] 的用户资料。如果被删除的用户是活跃用户，
  /// 活跃用户引用也会被清除。
  Future<void> deleteUser(String id) async {
    final users = getUsers().where((u) => u.id != id).toList();
    await _writeAll(users);

    final activeId = _prefs.getString(_activeUserKey);
    if (activeId == id) {
      await _prefs.remove(_activeUserKey);
    }
  }

  /// 设置 [id] 为当前活跃用户。该 id 必须属于已有资料；
  /// 否则此调用无效。
  Future<void> setActiveUser(String id) async {
    final user = getUser(id);
    if (user == null) return;
    await _prefs.setString(_activeUserKey, id);
  }

  // ---------------------------------------------------------------------------
  // 内部方法
  // ---------------------------------------------------------------------------

  Future<void> _writeAll(List<UserProfile> users) async {
    final encoded = users
        .map((u) => json.encode(u.toJson()))
        .toList(growable: false);
    await _prefs.setStringList(_usersKey, encoded);
  }
}
