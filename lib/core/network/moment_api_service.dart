import 'dart:io';
import 'package:crew_app/core/network/api_service.dart';
import 'package:crew_app/core/network/response_parser.dart';
import 'package:crew_app/features/events/data/moment.dart';
import 'package:dio/dio.dart';

/// Moment API 服务
/// 提供瞬间相关的 API 调用
class MomentApiService {
  MomentApiService({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  /// 搜索瞬间（根据国家/城市）
  Future<List<MomentSummary>> searchMoments({
    String? country,
    String? city,
  }) async {
    final queryParams = <String, dynamic>{};
    if (country != null && country.isNotEmpty) {
      queryParams['country'] = country;
    }
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }

    return _apiService.requestHandler.get<List<MomentSummary>>(
      path: '/api/v1/moments',
      queryParameters: queryParams.isEmpty ? null : queryParams,
      parseResponse: (data) {
        final list = ResponseParser.extractList(data);
        return list
            .map((e) => MomentSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 获取瞬间详情
  Future<MomentDetail> getMomentDetail(String id) async {
    return _apiService.requestHandler.get<MomentDetail>(
      path: '/api/v1/moments/$id',
      parseResponse: (data) {
        final momentData = ResponseParser.extractData(data);
        return MomentDetail.fromJson(momentData as Map<String, dynamic>);
      },
    );
  }

  /// 创建瞬间
  Future<MomentDetail> createMoment(CreateMomentRequest request) async {
    return _apiService.requestHandler.post<MomentDetail>(
      path: '/api/v1/moments',
      data: request.toJson(),
      requiresAuth: true,
      parseResponse: (data) {
        final momentData = ResponseParser.extractData(data);
        return MomentDetail.fromJson(momentData as Map<String, dynamic>);
      },
    );
  }

  /// 获取用户的瞬间列表
  Future<List<MomentSummary>> getUserMoments(String userId) async {
    return _apiService.requestHandler.get<List<MomentSummary>>(
      path: '/api/v1/users/$userId/moments',
      parseResponse: (data) {
        final list = ResponseParser.extractList(data);
        return list
            .map((e) => MomentSummary.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 获取瞬间评论列表
  Future<List<MomentComment>> getMomentComments(
    String momentId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    return _apiService.requestHandler.get<List<MomentComment>>(
      path: '/api/v1/moments/$momentId/comments',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      parseResponse: (data) {
        // 后端返回分页响应，提取 items 字段
        final paginationData = ResponseParser.extractData(data);
        if (paginationData is Map<String, dynamic>) {
          final items = paginationData['items'] as List<dynamic>? ?? [];
          return items
              .map((e) => MomentComment.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        // 兼容直接返回列表的情况
        final list = ResponseParser.extractList(data);
        return list
            .map((e) => MomentComment.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 添加评论
  Future<MomentComment> addComment(
    String momentId,
    AddMomentCommentRequest request,
  ) async {
    return _apiService.requestHandler.post<MomentComment>(
      path: '/api/v1/moments/$momentId/comments',
      data: request.toJson(),
      requiresAuth: true,
      parseResponse: (data) {
        final commentData = ResponseParser.extractData(data);
        return MomentComment.fromJson(commentData as Map<String, dynamic>);
      },
    );
  }

  /// 更新评论
  Future<MomentComment> updateComment(
    String momentId,
    String commentId,
    AddMomentCommentRequest request,
  ) async {
    return _apiService.requestHandler.put<MomentComment>(
      path: '/api/v1/moments/$momentId/comments/$commentId',
      data: request.toJson(),
      requiresAuth: true,
      parseResponse: (data) {
        final commentData = ResponseParser.extractData(data);
        return MomentComment.fromJson(commentData as Map<String, dynamic>);
      },
    );
  }

  /// 删除评论
  Future<void> deleteComment(String momentId, String commentId) async {
    return _apiService.requestHandler.delete(
      path: '/api/v1/moments/$momentId/comments/$commentId',
      requiresAuth: true,
    );
  }

  /// 上传图片
  Future<String> uploadImage({
    required String filePath,
    int? width,
    int? height,
    int? quality,
    ProgressCallback? onProgress,
  }) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (quality != null) 'quality': quality,
    });

    return _apiService.requestHandler.post<String>(
      path: '/api/v1/upload/image',
      data: formData,
      requiresAuth: true,
      parseResponse: (data) {
        final uploadData = ResponseParser.extractData(data);
        if (uploadData is Map<String, dynamic>) {
          return uploadData['url'] as String? ?? '';
        }
        return '';
      },
    );
  }
}

