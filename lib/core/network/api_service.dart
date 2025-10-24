import '../../features/user/data/authenticated_user_dto.dart';
import '../error/api_exception.dart';
import 'api_client.dart';

class ApiService {
  ApiService({required ApiClient client}) : _client = client;

  final ApiClient _client;

  Future<AuthenticatedUserDto> getAuthenticatedUserDetail() async {
    final data = await _client.get(
      '/User/GetAuthenticatedUserDetail',
      requiresAuth: true,
    );

    if (data is Map<String, dynamic>) {
      return AuthenticatedUserDto.fromJson(data);
    }

    throw ApiException('Unexpected user payload type');
  }
}
