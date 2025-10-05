import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String coverImageUrl;

  final DateTime? startTime;
  final DateTime? endTime;
  final int? maxParticipants;
  final int? currentParticipants;
  final double? price;
  final bool isFree;
  final String? status;

  final String? organizerId;
  final String? organizerName;
  final String? organizerAvatar;
  final String? organizerBio;

  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.coverImageUrl,
    this.startTime,
    this.endTime,
    this.maxParticipants,
    this.currentParticipants,
    this.price,
    this.isFree = false,
    this.status,
    this.organizerId,
    this.organizerName,
    this.organizerAvatar,
    this.organizerBio,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawImageUrls = json['imageUrls'];
    final rawTags = json['tags'];
    return Event(
      id: rawId?.toString() ?? '',
      title: (json['title'] as String?)?.trim() ?? '',
      location: (json['location'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      imageUrls: rawImageUrls is List
          ? rawImageUrls.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      coverImageUrl: (json['coverImageUrl'] as String?)?.trim() ?? '',
      startTime: _parseDateTime(json['startTime']),
      endTime: _parseDateTime(json['endTime']),
      maxParticipants: _parseInt(json['maxParticipants']),
      currentParticipants: _parseInt(json['currentParticipants']),
      price: json['price'] == null ? null : _parseDouble(json['price']),
      isFree: (json['isFree'] as bool?) ?? false,
      status: (json['status'] as String?)?.trim(),
      organizerId: (json['organizerId'] as String?)?.trim(),
      organizerName: (json['organizerName'] as String?)?.trim(),
      organizerAvatar: (json['organizerAvatar'] as String?)?.trim(),
      organizerBio: (json['organizerBio'] as String?)?.trim() ??
          (json['organizerDescription'] as String?)?.trim(),
      tags: rawTags is List
          ? rawTags.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  /// Returns the first non-empty image URL among [imageUrls] and
  /// [coverImageUrl]. If no URL is available, `null` is returned.
  String? get firstAvailableImageUrl {
    for (final url in [...imageUrls, coverImageUrl]) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  bool get isFull =>
      maxParticipants != null &&
      currentParticipants != null &&
      currentParticipants! >= maxParticipants!;

  String? get peopleText {
    final current = currentParticipants;
    final max = maxParticipants;
    if (current != null && max != null) {
      return '$current/$max';
    }
    if (current != null) {
      return '$current';
    }
    if (max != null) {
      return '0/$max';
    }
    return null;
  }

  String? formattedStartTime(String locale, {String pattern = 'M.d HH:mm'}) {
    final start = startTime;
    if (start == null) {
      return null;
    }
    return DateFormat(pattern, locale).format(start.toLocal());
  }

  String? formattedEndTime(String locale, {String pattern = 'M.d HH:mm'}) {
    final end = endTime;
    if (end == null) {
      return null;
    }
    return DateFormat(pattern, locale).format(end.toLocal());
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
