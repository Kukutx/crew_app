class Event {
  final String id;              // 唯一ID（来自后端）
  final String title;           // 活动标题
  final String description;     // 活动描述
  final String location;        // 文本地址（显示用）
  final double latitude;        // 经纬度
  final double longitude;

  final DateTime startTime;     // 活动开始时间
  final DateTime? endTime;      // 可选，活动结束时间

  final int maxParticipants;    // 最大人数
  final int currentParticipants;// 已报名人数
  final double? price;          // 活动费用，可为空
  final bool isFree;            // 是否免费

  final String organizerId;     // 主办方/召集人 ID
  final String organizerName;   // 主办方名称（显示）
  final String? organizerAvatar;// 主办方头像

  final List<String> imageUrls; // 活动图片
  final List<String> tags;      // 标签（如：运动、户外、音乐）

  final DateTime createdAt;     // 创建时间
  final DateTime updatedAt;     // 更新时间

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    this.endTime,
    required this.maxParticipants,
    required this.currentParticipants,
    this.price,
    this.isFree = false,
    required this.organizerId,
    required this.organizerName,
    this.organizerAvatar,
    this.imageUrls = const [],
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        location: json['location'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        maxParticipants: json['maxParticipants'] as int,
        currentParticipants: json['currentParticipants'] as int,
        price: json['price'] != null ? (json['price'] as num).toDouble() : null,
        isFree: json['isFree'] as bool? ?? false,
        organizerId: json['organizerId'] as String,
        organizerName: json['organizerName'] as String,
        organizerAvatar: json['organizerAvatar'] as String?,
        imageUrls: List<String>.from(json['imageUrls'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'price': price,
        'isFree': isFree,
        'organizerId': organizerId,
        'organizerName': organizerName,
        'organizerAvatar': organizerAvatar,
        'imageUrls': imageUrls,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // 方便 UI 层用的小方法,可收录到extensions
  bool get isFull => currentParticipants >= maxParticipants;
  String get peopleText => "$currentParticipants/$maxParticipants 人";
  String get timeText =>
      "${startTime.month}月${startTime.day}日 ${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}";
}
