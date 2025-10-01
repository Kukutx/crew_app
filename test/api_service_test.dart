import 'package:crew_app/core/network/api_service.dart';
import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

void main() {
  test('ApiService requests include /api segment in URL', () async {
    final capturedUrls = <String>[];
    final dio = Dio(BaseOptions(baseUrl: Env.current));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedUrls.add(options.uri.toString());
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [],
            ),
          );
        },
      ),
    );

    final apiService = ApiService(dio: dio);

    await apiService.getEvents();

    expect(capturedUrls, isNotEmpty);
    expect(capturedUrls.single, contains('/api/events'));
  });
}
