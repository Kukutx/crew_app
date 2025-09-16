import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/network/api_service.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiService', () {
    test('getEvents returns events on success', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 1,
              'title': 'Test',
              'location': 'loc',
              'description': 'desc',
              'latitude': 0,
              'longitude': 0,
            }
          ],
        ));
      }));
      final api = ApiService(dio: dio);
      final events = await api.getEvents();
      expect(events, isA<List<Event>>());
      expect(events.first.title, 'Test');
    });

    test('getEvents throws ApiException on Dio error', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.reject(DioException(requestOptions: options, message: 'network'));
      }));
      final api = ApiService(dio: dio);
      expect(api.getEvents, throwsA(isA<ApiException>()));
    });

    test('createEvent returns event on success', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'id': 1,
            'title': 'New',
            'location': 'loc',
            'description': 'desc',
            'latitude': 0,
            'longitude': 0,
          },
        ));
      }));
      final api = ApiService(dio: dio);
      final event = await api.createEvent('New', 'loc', 'desc', 0, 0);
      expect(event.title, 'New');
    });

    test('createEvent throws ApiException on non-200', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 400,
          data: {},
        ));
      }));
      final api = ApiService(dio: dio);
      expect(() => api.createEvent('t', 'l', 'd', 0, 0),
          throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)));
    });

    test('searchEvents returns results on success', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [
            {
              'id': 1,
              'title': 'Find',
              'location': 'loc',
              'description': 'desc',
              'latitude': 0,
              'longitude': 0,
            }
          ],
        ));
      }));
      final api = ApiService(dio: dio);
      final res = await api.searchEvents('Find');
      expect(res.first.title, 'Find');
    });

    test('searchEvents throws ApiException on non-200', () async {
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 500,
          data: [],
        ));
      }));
      final api = ApiService(dio: dio);
      expect(() => api.searchEvents('x'),
          throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 500)));
    });
  });
}