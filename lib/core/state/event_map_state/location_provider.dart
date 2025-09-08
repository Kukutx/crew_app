// lib/core/location/location_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

final userLocationProvider =
    AsyncNotifierProvider<UserLocationCtrl, LatLng?>(UserLocationCtrl.new);

class UserLocationCtrl extends AsyncNotifier<LatLng?> {
  @override
  Future<LatLng?> build() async {
    // 首次构建时尝试获取一次位置
    return _determine();
  }

  Future<LatLng?> refreshNow() async {
    final p = await _determine();
    state = AsyncData(p);
    return p;
  }

  Future<LatLng?> _determine() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }
}
