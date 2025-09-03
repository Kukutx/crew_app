import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';
import '../../features/events/data/event.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
  _dio = Dio(BaseOptions(baseUrl: Env.current));
    
  // 简单的日志拦截器
  _dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
    ));
  }


  Future<List<Event>> getEvents() async {
    final response = await _dio.get("/events");
    return (response.data as List)
        .map((e) => Event.fromJson(e))
        .toList();
  }

  Future<Event> createEvent(String title, String location,String description, double lat, double lng) async {
    final response = await _dio.post("/events", data: {
      "title": title,
      "location": location,
      "description": description,
      "latitude": lat,
      "longitude": lng,
    });
    return Event.fromJson(response.data);
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _dio.get(
        "/events/search",
        queryParameters: {"query": query},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load events");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.message}");
    }
  }
}
