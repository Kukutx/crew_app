import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/providers/api_provider_helper.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authenticatedUserProvider =
    StateNotifierProvider.autoDispose<AuthenticatedUserNotifier,
        AsyncValue<AuthenticatedUserDto?>>((ref) {
  return AuthenticatedUserNotifier(ref);
});

class AuthenticatedUserNotifier
    extends StateNotifier<AsyncValue<AuthenticatedUserDto?>> {
  AuthenticatedUserNotifier(this._ref)
      : super(const AsyncValue<AuthenticatedUserDto?>.data(null)) {
    _listenToAuthChanges();
    
    // 注册销毁回调
    _ref.onDispose(() {
      _isDisposed = true;
    });
    
    // 延迟初始化，避免在 provider 创建期间修改 state
    Future.microtask(() {
      if (!_isDisposed) {
        _initialize();
      }
    });
  }

  final Ref _ref;
  bool _isDisposed = false;
  
  /// 正在加载的profile Future，用于防止并发调用
  Future<AuthenticatedUserDto?>? _loadingProfile;

  /// 监听认证状态变化
  /// 
  /// 注意：由于使用了 StateNotifierProvider.autoDispose，
  /// Riverpod会自动在provider销毁时清理ref.listen创建的监听器，
  /// 无需手动管理，不会有内存泄漏风险。
  void _listenToAuthChanges() {
    _ref.listen<User?>(currentUserProvider, (previous, next) {
      // 延迟执行，避免在 widget 构建期间修改 state
      Future.microtask(() {
        if (_isDisposed) return;
        
        final previousUser = previous;
        final currentUser = next;

        if (currentUser == null) {
          state = const AsyncValue<AuthenticatedUserDto?>.data(null);
          _loadingProfile = null; // 清除加载状态
          return;
        }

        if (previousUser == null || previousUser.uid != currentUser.uid) {
          refreshProfile();
        }
      });
    });
  }

  Future<void> _initialize() async {
    if (_isDisposed) return;
    
    // 使用 ref.watch 确保依赖关系正确，当 currentUserProvider 更新时能正确响应
    final user = _ref.watch(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<AuthenticatedUserDto?>.data(null);
      return;
    }

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    final nextState = await AsyncValue.guard(_loadProfile);
    if (_isDisposed) return;
    state = nextState;
  }

  /// 刷新用户资料，如果正在加载则返回现有的Future，避免并发调用
  Future<AuthenticatedUserDto?> refreshProfile() async {
    // 如果正在加载，返回现有Future
    if (_loadingProfile != null) {
      return _loadingProfile;
    }
    
    // 使用 ref.watch 确保依赖关系正确，当 currentUserProvider 更新时能正确响应
    final user = _ref.watch(currentUserProvider);
    if (user == null) {
      state = const AsyncValue<AuthenticatedUserDto?>.data(null);
      _loadingProfile = null;
      return null;
    }

    state = const AsyncValue<AuthenticatedUserDto?>.loading();
    
    // 创建并保存Future，防止并发调用
    _loadingProfile = _loadProfile().then((result) {
      _loadingProfile = null; // 清除加载状态
      if (_isDisposed) return null;
      state = AsyncValue.data(result);
      return result;
    }).catchError((error, stackTrace) {
      _loadingProfile = null; // 清除加载状态
      if (_isDisposed) return null;
      state = AsyncValue.error(error, stackTrace);
      return null;
    });
    
    return _loadingProfile;
  }

  Future<AuthenticatedUserDto?> _loadProfile() async {
    try {
      return await ApiProviderHelper.callApi(
        _ref,
        (api) => api.getAuthenticatedUserDetail(),
      );
    } on ApiException catch (error) {
      final status = error.statusCode;
      if (status == null) {
        rethrow;
      }

      // 对于这些状态码，返回 null 而不是抛出异常
      // 401: 未授权
      // 403: 禁止访问
      // 404: 未找到
      // 204: 无内容
      if (status == 401 || status == 403 || status == 404 || status == 204) {
        return null;
      }

      rethrow;
    }
  }
}
