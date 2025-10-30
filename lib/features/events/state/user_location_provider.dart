import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

    try {
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      return LatLng(pos.latitude, pos.longitude);
    } on TimeoutException catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LatLng(last.latitude, last.longitude);
      }
      return null;
    } on LocationServiceDisabledException {
      return null;
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LatLng(last.latitude, last.longitude);
      }
      return null;
    }
  }
}
