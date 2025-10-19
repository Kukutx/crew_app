import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:crew_app/core/config/environment.dart';

class ExpensesApi {
  ExpensesApi({
    Dio? dio,
    FirebaseAuth? firebaseAuth,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: '${Env.current}v1/')),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _attachToken(options);
          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldRetry =
              error.response?.statusCode == 401 && !(error.requestOptions.extra['__retried'] == true);
          if (!shouldRetry) {
            handler.next(error);
            return;
          }

          try {
            await _attachToken(error.requestOptions, forceRefresh: true);
            error.requestOptions.extra['__retried'] = true;
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );
  }

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  Future<void> _attachToken(RequestOptions options, {bool forceRefresh = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }
    final token = await user.getIdToken(forceRefresh);
    if (token == null) {
      return;
    }
    options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Map<String, dynamic>> getExpenses(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>('events/$eventId/expenses');
    return Map<String, dynamic>.from(response.data ?? <String, dynamic>{});
  }

  Future<Map<String, dynamic>> createExpense({
    required String eventId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'events/$eventId/expenses',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data ?? <String, dynamic>{});
  }

  Future<void> deleteExpense({
    required String eventId,
    required String expenseId,
  }) async {
    await _dio.delete<void>('events/$eventId/expenses/$expenseId');
  }

  Future<Map<String, dynamic>> getSettlement(String eventId) async {
    final response = await _dio.get<Map<String, dynamic>>('events/$eventId/settlement');
    return Map<String, dynamic>.from(response.data ?? <String, dynamic>{});
  }
}
