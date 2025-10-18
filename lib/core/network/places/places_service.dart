import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/features/models/places/place_detail_dto.dart';
import 'package:crew_app/features/models/places/place_summary_dto.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesApiException implements Exception {
  PlacesApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'PlacesApiException($message, statusCode: $statusCode)';
}

class PlaceDetails {
  const PlaceDetails({
    required this.id,
    required this.displayName,
    this.formattedAddress,
    this.location,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
  });

  final String id;
  final String displayName;
  final String? formattedAddress;
  final LatLng? location;
  final double? rating;
  final int? userRatingsTotal;
  final String? priceLevel;
}

class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.displayName,
    this.formattedAddress,
    this.location,
    this.photoUrl,
  });

  final String id;
  final String displayName;
  final String? formattedAddress;
  final LatLng? location;
  final String? photoUrl;
}

class PlacesService {
  PlacesService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current));

  final Dio _dio;

  Future<String?> findPlaceId(LatLng position) async {
    try {
      final response = await _dio.get(
        '/places/search',
        queryParameters: {
          'q': '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}',
          'lat': position.latitude,
          'lng': position.longitude,
          'limit': 1,
        },
      );

      if (response.statusCode == 200) {
        final list = _asJsonList(response.data)
            .map(PlaceSummaryDto.fromJson)
            .toList(growable: false);
        if (list.isEmpty) {
          return null;
        }
        return list.first.placeId;
      }

      return null;
    } on DioException catch (error) {
      throw PlacesApiException(
        _extractErrorMessage(error) ?? 'Failed to search places',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<NearbyPlace>> searchNearbyPlaces(
    LatLng position, {
    String query = 'landmark',
  }) async {
    try {
      final response = await _dio.get(
        '/places/search',
        queryParameters: {
          'q': query,
          'lat': position.latitude,
          'lng': position.longitude,
        },
      );

      if (response.statusCode != 200) {
        return const [];
      }

      final dtos = _asJsonList(response.data)
          .map(PlaceSummaryDto.fromJson)
          .toList(growable: false);

      return dtos
          .map((dto) => NearbyPlace(
                id: dto.placeId,
                displayName: dto.name,
                formattedAddress: null,
                location: _toLatLng(dto.location),
                photoUrl: null,
              ))
          .toList(growable: false);
    } on DioException catch (error) {
      throw PlacesApiException(
        _extractErrorMessage(error) ?? 'Failed to search places',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get('/places/$placeId');
      if (response.statusCode == 200) {
        final data = _asJsonObject(response.data);
        final dto = PlaceDetailDto.fromJson(data);
        return PlaceDetails(
          id: dto.placeId,
          displayName: dto.name,
          formattedAddress: dto.formattedAddress,
          location: _toLatLng(dto.location),
          rating: null,
          userRatingsTotal: null,
          priceLevel: null,
        );
      }
      if (response.statusCode == 404) {
        return null;
      }
      throw PlacesApiException(
        'Failed to load place details',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      throw PlacesApiException(
        _extractErrorMessage(error) ?? 'Failed to load place details',
        statusCode: error.response?.statusCode,
      );
    }
  }

  LatLng? _toLatLng(List<double> coordinates) {
    if (coordinates.length < 2) {
      return null;
    }
    final lng = coordinates[0];
    final lat = coordinates[1];
    return LatLng(lat, lng);
  }

  List<Map<String, dynamic>> _asJsonList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final values = data.values.whereType<List>();
      for (final list in values) {
        if (list.isNotEmpty && list.first is Map) {
          return list
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _asJsonObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw PlacesApiException('Unexpected response format');
  }

  String? _extractErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final title = data['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return exception.message;
  }
}

