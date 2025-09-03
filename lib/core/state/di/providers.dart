import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
