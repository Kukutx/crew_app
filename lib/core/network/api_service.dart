import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';
import '../error/api_exception.dart';
import '../../features/events/data/event.dart';

class ApiService {
  late final Dio _dio;

    ApiService({Dio? dio}) {
    _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current));

    // 简单的日志拦截器
    _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
    ));
  }


  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get("events");
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => Event.fromJson(e))
            .toList();
      } else {
        throw ApiException('Failed to load events',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Request error',
          statusCode: e.response?.statusCode);
    }
  }

  Future<Event> createEvent(String title, String location, String description,
      double lat, double lng) async {
    try {
      final response = await _dio.post("events", data: {
        "title": title,
        "location": location,
        "description": description,
        "latitude": lat,
        "longitude": lng,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Event.fromJson(response.data);
      } else {
        throw ApiException('Failed to create event',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Request error',
          statusCode: e.response?.statusCode);
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _dio.get(
        "events/search",
        queryParameters: {"query": query},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
               throw ApiException('Failed to load events',
            statusCode: response.statusCode);
      }
    } on DioException catch (e) {
   throw ApiException(e.message ?? 'Request error',
          statusCode: e.response?.statusCode);
    }
  }
}
