import 'package:dio/dio.dart';
import '../Models/event.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://crew-api-u8vu.onrender.com/api", ));

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
