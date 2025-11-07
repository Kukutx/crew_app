import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/google_maps_config.dart';
import '../error_message_extractor.dart';

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
  PlacesService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://places.googleapis.com/v1/')),
        _apiKey = apiKey ?? GoogleMapsConfig.apiKey;

  final Dio _dio;
  final String _apiKey;

  bool get _hasValidKey => _apiKey.trim().isNotEmpty;

  Future<String?> findPlaceId(LatLng position) async {
    if (!_hasValidKey) {
      throw PlacesApiException('Google Places API key is not configured');
    }

    try {
      final response = await _dio.post(
        'places:searchNearby',
        data: {
          'includedTypes': ['point_of_interest'],
          'maxResultCount': 1,
          'locationRestriction': {
            'circle': {
              'center': {
                'latitude': position.latitude,
                'longitude': position.longitude,
              },
              'radius': 50,
            },
          },
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'places.name',
          },
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final places = data['places'];
        if (places is List && places.isNotEmpty) {
          final place = places.first;
          if (place is Map<String, dynamic>) {
            final name = place['name'];
            if (name is String && name.isNotEmpty) {
              return name;
            }
          }
        }
      }
      return null;
    } on DioException catch (error) {
      throw PlacesApiException(
        ErrorMessageExtractor.extractWithDefault(
          error,
          defaultMessage: 'Failed to search places',
        ),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<NearbyPlace>> searchNearbyPlaces(
    LatLng position, {
    double radius = 100,
    int maxResults = 10,
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
              'radius': radius,
            },
          },
        },
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'places.name,places.displayName,places.formattedAddress,places.location.latitude,places.location.longitude,places.photos.name',
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const [];
      }

      final places = data['places'];
      if (places is! List) {
        return const [];
      }

      return places
          .whereType<Map<String, dynamic>>()
          .map(_mapNearbyPlace)
          .whereType<NearbyPlace>()
          .toList(growable: false);
    } on DioException catch (error) {
      throw PlacesApiException(
        ErrorMessageExtractor.extractWithDefault(
          error,
          defaultMessage: 'Failed to search places',
        ),
        statusCode: error.response?.statusCode,
      );
    }
  }

  NearbyPlace? _mapNearbyPlace(Map<String, dynamic> data) {
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

    LatLng? location;
    final locationMap = data['location'];
    if (locationMap is Map<String, dynamic>) {
      final lat = locationMap['latitude'];
      final lng = locationMap['longitude'];
      if (lat is num && lng is num) {
        location = LatLng(lat.toDouble(), lng.toDouble());
      }
    }

    String? photoUrl;
    final photos = data['photos'];
    if (photos is List && photos.isNotEmpty) {
      final first = photos.first;
      if (first is Map<String, dynamic>) {
        final photoName = first['name'];
        if (photoName is String && photoName.isNotEmpty) {
          photoUrl = 'https://places.googleapis.com/v1/'
              '$photoName/media?maxHeightPx=180&key=$_apiKey';
        }
      }
    }

    final resolvedDisplayName = displayName ?? name;

    return NearbyPlace(
      id: name,
      displayName: resolvedDisplayName,
      formattedAddress: formattedAddress,
      location: location,
      photoUrl: photoUrl,
    );
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
                'name,displayName,formattedAddress,location.latitude,location.longitude',
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
        ErrorMessageExtractor.extractWithDefault(
          error,
          defaultMessage: 'Failed to load place details',
        ),
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<PlaceDetails>> searchPlacesByText(
    String query, {
    LatLng? locationBias,
    required int maxResults,
  }) async {
    if (!_hasValidKey) {
      throw PlacesApiException('Google Places API key is not configured');
    }

    if (query.trim().isEmpty) {
      return const [];
    }

    try {
      final requestData = <String, dynamic>{
        'textQuery': query.trim(),
        'maxResultCount': maxResults,
      };

      // 如果提供了位置偏好，添加位置限制
      if (locationBias != null) {
        requestData['locationBias'] = {
          'circle': {
            'center': {
              'latitude': locationBias.latitude,
              'longitude': locationBias.longitude,
            },
            'radius': 50000.0, // 50km 范围
          },
        };
      }

      final response = await _dio.post(
        'places:searchText',
        data: requestData,
        options: Options(
          headers: {
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask':
                'places.name,places.displayName,places.formattedAddress,places.location',
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const [];
      }

      final places = data['places'];
      if (places is! List) {
        return const [];
      }

      return places
          .whereType<Map<String, dynamic>>()
          .map(_mapPlaceDetails)
          .whereType<PlaceDetails>()
          .toList(growable: false);
    } on DioException catch (error) {
      throw PlacesApiException(
        ErrorMessageExtractor.extractWithDefault(
          error,
          defaultMessage: 'Failed to search places',
        ),
        statusCode: error.response?.statusCode,
      );
    }
  }

  PlaceDetails? _mapPlaceDetails(Map<String, dynamic> data) {
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

    LatLng? location;
    final locationMap = data['location'];
    if (locationMap is Map<String, dynamic>) {
      final lat = locationMap['latitude'];
      final lng = locationMap['longitude'];
      if (lat is num && lng is num) {
        location = LatLng(lat.toDouble(), lng.toDouble());
      }
    }

    final resolvedDisplayName = displayName ?? name;

    return PlaceDetails(
      id: name,
      displayName: resolvedDisplayName,
      formattedAddress: formattedAddress,
      location: location,
    );
  }
}
