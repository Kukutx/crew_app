import 'dart:async';

import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/models/user/user_profile_dto.dart';
import 'package:crew_app/features/users/models/ensure_user_request.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnsureUserService {
  EnsureUserService({
    required FirebaseAuth firebaseAuth,
    Dio? dio,
    int maxRetries = 3,
    String? baseUrl,
  })  : _auth = firebaseAuth,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? Env.current,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                contentType: 'application/json',
                headers: const {'Accept': 'application/json'},
              ),
            ),
        _maxRetries = maxRetries {
    final resolvedBaseUrl = baseUrl ?? Env.current;
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = resolvedBaseUrl;
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _pendingAuthorization;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    final hasLogInterceptor =
        _dio.interceptors.any((interceptor) => interceptor is LogInterceptor);
    if (!hasLogInterceptor) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint('[EnsureUserDio] $object'),
        ),
      );
    }
  }

  final FirebaseAuth _auth;
  final Dio _dio;
  final int _maxRetries;
  String? _pendingAuthorization;
  String? _lastEnsuredUid;
  DateTime? _lastTokenIssuedAt;
  UserProfileDto? _lastProfile;

  Future<UserProfileDto> ensureUser({bool force = false}) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw ApiException('User not authenticated');
    }

    if (!force) {
      try {
        final tokenSnapshot = await firebaseUser.getIdTokenResult();
        final issuedAt = tokenSnapshot.issuedAtTime;
        if (_shouldSkipEnsure(firebaseUser.uid, issuedAt)) {
          debugPrint(
            '[EnsureUserService] Ensure user skipped for ${firebaseUser.uid}, using cached profile.',
          );
          if (_lastProfile != null) {
            return _lastProfile!;
          }
        }
      } on FirebaseAuthException catch (error) {
        debugPrint(
          '[EnsureUserService] Failed to inspect cached token: ${error.message}',
        );
      }
    }

    late IdTokenResult tokenResult;
    try {
      tokenResult = await firebaseUser.getIdTokenResult(true);
    } on FirebaseAuthException catch (error) {
      throw ApiException(
        'Failed to refresh Firebase token: ${error.message ?? error.code}',
      );
    }

    final idToken = tokenResult.token;
    if (idToken == null || idToken.isEmpty) {
      throw ApiException('Unable to obtain Firebase ID token');
    }

    final issuedAt = tokenResult.issuedAtTime ?? DateTime.now();
    final request = EnsureUserRequest.fromFirebaseUser(firebaseUser);
    final payload = request.toJson();

    _pendingAuthorization = idToken;

    ApiException? capturedError;
    try {
      for (var attempt = 0; attempt < _maxRetries; attempt++) {
        try {
          final response = await _dio.post<Map<String, dynamic>>(
            'users/ensure',
            data: payload,
          );

          final data = response.data;
          if (data is! Map<String, dynamic>) {
            throw ApiException('Unexpected ensure user payload type');
          }

          final profile = UserProfileDto.fromJson(data);
          _lastEnsuredUid = firebaseUser.uid;
          _lastTokenIssuedAt = issuedAt;
          _lastProfile = profile;
          debugPrint(
            '[EnsureUserService] Ensure user success: ${profile.id ?? firebaseUser.uid}',
          );
          return profile;
        } on DioException catch (error) {
          final status = error.response?.statusCode;
          final message = _resolveErrorMessage(error);

          if (status == 401 || status == 403) {
            debugPrint(
              '[EnsureUserService] Authorization failed ($status): $message',
            );
            capturedError = ApiException(message, statusCode: status);
            break;
          }

          if (attempt == _maxRetries - 1) {
            capturedError = ApiException(message, statusCode: status);
            break;
          }

          final delay = Duration(milliseconds: 400 * (1 << attempt));
          debugPrint(
            '[EnsureUserService] Attempt ${attempt + 1} failed: $message. Retrying in ${delay.inMilliseconds}ms',
          );
          await Future.delayed(delay);
        }
      }
    } finally {
      _pendingAuthorization = null;
    }

    throw capturedError ?? ApiException('Failed to ensure user');
  }

  void reset() {
    _pendingAuthorization = null;
    _lastEnsuredUid = null;
    _lastTokenIssuedAt = null;
    _lastProfile = null;
  }

  bool _shouldSkipEnsure(String uid, DateTime? issuedAt) {
    if (_lastProfile == null) {
      return false;
    }
    if (_lastEnsuredUid != uid) {
      return false;
    }
    if (_lastTokenIssuedAt == null || issuedAt == null) {
      return false;
    }
    return !issuedAt.isAfter(_lastTokenIssuedAt!);
  }

  String _resolveErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return exception.message ?? 'Network request failed';
  }
}

final ensureUserServiceProvider = Provider<EnsureUserService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.current,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (object) => debugPrint('[EnsureUserDio] $object'),
    ),
  );

  ref.onDispose(dio.close);

  return EnsureUserService(
    firebaseAuth: auth,
    dio: dio,
  );
});
