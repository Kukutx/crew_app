/// 草稿类型
enum DraftType {
  roadTrip, // 行程草稿
  event,    // 事件草稿
  moment,   // 瞬间草稿
}

/// 草稿模型
class Draft {
  final String id;
  final DraftType type;
  final String title;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Draft({
    required this.id,
    required this.type,
    required this.title,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
      id: json['id'] as String? ?? '',
      type: _parseDraftType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': _draftTypeToString(type),
        'title': title,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static DraftType _parseDraftType(String? value) {
    switch (value) {
      case 'roadTrip':
        return DraftType.roadTrip;
      case 'event':
        return DraftType.event;
      case 'moment':
        return DraftType.moment;
      default:
        return DraftType.roadTrip;
    }
  }

  static String _draftTypeToString(DraftType type) {
    switch (type) {
      case DraftType.roadTrip:
        return 'roadTrip';
      case DraftType.event:
        return 'event';
      case DraftType.moment:
        return 'moment';
    }
  }
}

/// 草稿创建/更新请求
class DraftRequest {
  final DraftType type;
  final String title;
  final Map<String, dynamic> data;

  const DraftRequest({
    required this.type,
    required this.title,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'type': _draftTypeToString(type),
        'title': title,
        'data': data,
      };

  static String _draftTypeToString(DraftType type) {
    switch (type) {
      case DraftType.roadTrip:
        return 'roadTrip';
      case DraftType.event:
        return 'event';
      case DraftType.moment:
        return 'moment';
    }
  }
}



