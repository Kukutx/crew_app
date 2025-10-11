import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/google_maps_config.dart';

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

class PlacesService {
  PlacesService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://places.googleapis.com/v1/')),
        _apiKey = apiKey ?? GoogleMapsConfig.apiKey;

  final Dio _dio;
  final String _apiKey;

  bool get _hasValidKey => _apiKey.trim().isNotEmpty;

  Future<List<PlaceDetails>> findNearbyPlaces(
    LatLng position, {
    int radiusMeters = 60,
    int maxResults = 8,
  }) async {
    if (!_hasValidKey) {
      throw PlacesApiException('Google Places API key is not configured');
    }

    try {
      final response = await _dio.post(
        'places:searchNearby',
        data: {
          'includedTypes': ['point_of_interest'],
          'maxResultCount': maxResults,
          'locationRestriction': {
            'circle': {
              'center': {
                'latitude': position.latitude,
                'longitude': position.longitude,
              },
              'radius': radiusMeters,
            },
          },
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'places.name,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.priceLevel',
          },
        ),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const <PlaceDetails>[];
      }
      final places = data['places'];
      if (places is! List) {
        return const <PlaceDetails>[];
      }

      final results = <PlaceDetails>[];
      for (final place in places) {
        if (place is! Map<String, dynamic>) {
          continue;
        }
        final parsed = _mapToPlaceDetails(place);
        if (parsed != null) {
          results.add(parsed);
        }
      }
      return results;
    } on DioException catch (error) {
      throw PlacesApiException(
        _resolveErrorMessage(error) ?? 'Failed to search places',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    if (!_hasValidKey) {
      throw PlacesApiException('Google Places API key is not configured');
    }

    final resourceName = placeId.startsWith('places/') ? placeId : 'places/$placeId';

    try {
      final response = await _dio.get(
        resourceName,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'name,displayName,formattedAddress,location,rating,userRatingCount,priceLevel',
          },
        ),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return null;
      }
      final nameField = data['displayName'];
      String? displayName;
      if (nameField is Map<String, dynamic>) {
        final text = nameField['text'];
        if (text is String) {
          displayName = text;
        }
      } else if (nameField is String) {
        displayName = nameField;
      }
      final formattedAddress = data['formattedAddress'] as String?;
      final locationMap = data['location'];
      LatLng? location;
      if (locationMap is Map<String, dynamic>) {
        final lat = locationMap['latitude'];
        final lng = locationMap['longitude'];
        if (lat is num && lng is num) {
          location = LatLng(lat.toDouble(), lng.toDouble());
        }
      }
      final rating = (data['rating'] is num) ? (data['rating'] as num).toDouble() : null;
      final ratingCount = data['userRatingCount'];
      final userRatingsTotal = ratingCount is int
          ? ratingCount
          : ratingCount is num
              ? ratingCount.toInt()
              : null;
      final priceLevel = data['priceLevel'] as String?;

      final resolvedName = displayName ?? data['name'];
      if (resolvedName is! String || resolvedName.isEmpty) {
        return null;
      }

      return PlaceDetails(
        id: data['name'] as String? ?? resolvedName,
        displayName: displayName ?? resolvedName,
        formattedAddress: formattedAddress,
        location: location,
        rating: rating,
        userRatingsTotal: userRatingsTotal,
        priceLevel: priceLevel,
      );
    } on DioException catch (error) {
      throw PlacesApiException(
        _resolveErrorMessage(error) ?? 'Failed to load place details',
        statusCode: error.response?.statusCode,
      );
    }
  }

  String? _resolveErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        final message = error['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return exception.message;
  }

  PlaceDetails? _mapToPlaceDetails(Map<String, dynamic> data) {
    final name = data['name'];
    if (name is! String || name.isEmpty) {
      return null;
    }
    String? displayName;
    final displayNameField = data['displayName'];
    if (displayNameField is Map<String, dynamic>) {
      final text = displayNameField['text'];
      if (text is String && text.isNotEmpty) {
        displayName = text;
      }
    } else if (displayNameField is String && displayNameField.isNotEmpty) {
      displayName = displayNameField;
    }

    final formattedAddress = data['formattedAddress'] as String?;
    final locationMap = data['location'];
    LatLng? location;
    if (locationMap is Map<String, dynamic>) {
      final lat = locationMap['latitude'];
      final lng = locationMap['longitude'];
      if (lat is num && lng is num) {
        location = LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    final rating = data['rating'];
    final ratingValue = rating is num ? rating.toDouble() : null;
    final ratingCount = data['userRatingCount'];
    final userRatingsTotal = ratingCount is int
        ? ratingCount
        : ratingCount is num
            ? ratingCount.toInt()
            : null;
    final priceLevel = data['priceLevel'] as String?;

    return PlaceDetails(
      id: name,
      displayName: displayName ?? name,
      formattedAddress: formattedAddress,
      location: location,
      rating: ratingValue,
      userRatingsTotal: userRatingsTotal,
      priceLevel: priceLevel,
    );
  }
}
