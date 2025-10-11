import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/places/places_service.dart';

final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});
