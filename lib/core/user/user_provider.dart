import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_study/core/user/user_model.dart';
import 'package:student_study/core/user/user_repository.dart';

/// 提供应用启动时初始化一次的 [SharedPreferences] 实例。
///
/// 必须在构建组件树之前用具体值覆盖：
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///     child: const App(),
///   ),
/// );
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a concrete '
    'SharedPreferences instance at app startup.',
  ),
);

/// 提供基于 [SharedPreferences] 的 [UserRepository]。
final userRepositoryProvider = Provider<UserRepository>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return UserRepository(prefs);
  },
);

/// 提供本地用户资料的完整列表。
///
/// 在变更（创建/删除）后使此提供者失效以刷新数据。
final usersListProvider = Provider<List<UserProfile>>(
  (ref) {
    final repo = ref.watch(userRepositoryProvider);
    return repo.getUsers();
  },
);

/// 管理当前活跃的用户资料。
///
/// 调用 [ActiveUserNotifier.setActiveUser] 或 [ActiveUserNotifier.clearActiveUser]
/// 来更改所选用户。
final activeUserProvider =
    AsyncNotifierProvider<ActiveUserNotifier, UserProfile?>(
  ActiveUserNotifier.new,
);

class ActiveUserNotifier extends AsyncNotifier<UserProfile?> {
  @override
  FutureOr<UserProfile?> build() {
    final repo = ref.watch(userRepositoryProvider);
    return repo.getActiveUser();
  }

  /// 将活跃用户切换为 [id] 并刷新状态。
  Future<void> setActiveUser(String id) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.setActiveUser(id);
    state = AsyncData(repo.getActiveUser());
    ref.invalidate(usersListProvider);
  }

  /// 清除活跃用户选择，通过仓库操作以保持键名一致。
  Future<void> clearActiveUser() async {
    final repo = ref.read(userRepositoryProvider);
    await repo.clearActiveUser();
    state = const AsyncData(null);
  }

  /// 创建（或更新）用户资料并将其设为活跃用户。
  Future<void> createAndActivate(UserProfile user) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.saveUser(user);
    await repo.setActiveUser(user.id);
    state = AsyncData(user);
    ref.invalidate(usersListProvider);
  }

  /// 删除指定 [id] 的用户。如果该用户是活跃用户，则清除活跃状态。
  Future<void> deleteUser(String id) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.deleteUser(id);
    ref.invalidate(usersListProvider);

    final current = state.value;
    if (current != null && current.id == id) {
      state = const AsyncData(null);
    }
  }
}
