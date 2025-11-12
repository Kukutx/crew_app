import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/moment.dart';
import 'package:crew_app/features/events/services/moment_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Moment API 服务 Provider
final momentApiServiceProvider = Provider<MomentApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MomentApiService(apiService: apiService);
});

/// 搜索瞬间 Provider（根据国家/城市）
final searchMomentsProvider = FutureProvider.family<List<MomentSummary>, ({
  String? country,
  String? city,
})>((ref, params) async {
  final service = ref.watch(momentApiServiceProvider);
  return service.searchMoments(
    country: params.country,
    city: params.city,
  );
});

/// 瞬间详情 Provider
final momentDetailProvider =
    FutureProvider.family<MomentDetail, String>((ref, momentId) async {
  final service = ref.watch(momentApiServiceProvider);
  return service.getMomentDetail(momentId);
});

/// 用户瞬间列表 Provider
final userMomentsProvider =
    FutureProvider.family<List<MomentSummary>, String>((ref, userId) async {
  final service = ref.watch(momentApiServiceProvider);
  return service.getUserMoments(userId);
});

/// 瞬间评论列表 Provider
final momentCommentsProvider = FutureProvider.family<List<MomentComment>, ({
  String momentId,
  int page,
  int pageSize,
})>((ref, params) async {
  final service = ref.watch(momentApiServiceProvider);
  return service.getMomentComments(
    params.momentId,
    page: params.page,
    pageSize: params.pageSize,
  );
});

/// 创建瞬间的 Notifier
class CreateMomentNotifier extends StateNotifier<AsyncValue<MomentDetail?>> {
  CreateMomentNotifier(this._service) : super(const AsyncValue.data(null));

  final MomentApiService _service;

  Future<void> createMoment(CreateMomentRequest request) async {
    state = const AsyncValue.loading();
    try {
      final moment = await _service.createMoment(request);
      state = AsyncValue.data(moment);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createMomentProvider =
    StateNotifierProvider<CreateMomentNotifier, AsyncValue<MomentDetail?>>(
  (ref) {
    final service = ref.watch(momentApiServiceProvider);
    return CreateMomentNotifier(service);
  },
);

/// 添加评论的 Notifier
class AddCommentNotifier extends StateNotifier<AsyncValue<MomentComment?>> {
  AddCommentNotifier(this._service) : super(const AsyncValue.data(null));

  final MomentApiService _service;

  Future<void> addComment(String momentId, String content) async {
    state = const AsyncValue.loading();
    try {
      final comment = await _service.addComment(
        momentId,
        AddMomentCommentRequest(content: content),
      );
      state = AsyncValue.data(comment);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final addCommentProvider =
    StateNotifierProvider<AddCommentNotifier, AsyncValue<MomentComment?>>(
  (ref) {
    final service = ref.watch(momentApiServiceProvider);
    return AddCommentNotifier(service);
  },
);

