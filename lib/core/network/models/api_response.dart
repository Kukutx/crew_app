/// API响应包装类
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: (json['success'] as bool?) ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) => {
        'success': success,
        if (data != null)
          'data': toJsonT != null ? toJsonT(data as T) : data,
        if (error != null) 'error': error!.toJson(),
        if (message != null) 'message': message,
      };
}

/// API错误信息
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (details != null) 'details': details,
      };
}

/// 分页请求
class PaginationRequest {
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder;

  const PaginationRequest({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'pageSize': pageSize,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
      };
}

/// 分页响应
class PaginationResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginationResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginationResponse<T>(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      totalCount: (json['totalCount'] as int?) ?? 0,
      page: (json['page'] as int?) ?? 1,
      pageSize: (json['pageSize'] as int?) ?? 20,
      totalPages: (json['totalPages'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) => {
        'items': items.map((e) => toJsonT(e)).toList(),
        'totalCount': totalCount,
        'page': page,
        'pageSize': pageSize,
        'totalPages': totalPages,
      };
}



