import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final userLocationProvider = AsyncNotifierProvider<UserLocationCtrl,
    UserLocation?>(UserLocationCtrl.new);

class UserLocation {
  final LatLng position;
  final double heading;
  final double? accuracy;

  const UserLocation({
    required this.position,
    this.heading = 0,
    this.accuracy,
  });
}

class UserLocationCtrl extends AsyncNotifier<UserLocation?> {
  StreamSubscription<Position>? _subscription;

  @override
  Future<UserLocation?> build() async {
    ref.onDispose(() => _subscription?.cancel());
    final initial = await _determineCurrentLocation();
    await _startListening();
    return initial;
  }

  Future<UserLocation?> refreshNow() async {
    final current = await _determineCurrentLocation();
    state = AsyncData(current);
    await _startListening();
    return current;
  }

  Future<UserLocation?> _determineCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();
    return _toUserLocation(pos);
  }

  Future<void> _startListening() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return;
    }

    _subscription?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    );
    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      state = AsyncData(_toUserLocation(pos));
    });
  }

  UserLocation _toUserLocation(Position pos) {
    final heading = pos.heading;
    final normalizedHeading =
        heading.isFinite && heading >= 0 ? heading : 0.0;
    return UserLocation(
      position: LatLng(pos.latitude, pos.longitude),
      heading: normalizedHeading,
      accuracy: pos.accuracy.isFinite ? pos.accuracy : null,
    );
  }
}
