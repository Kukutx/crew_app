/// 瞬间类型
enum MomentType {
  instant, // 即时瞬间
  event, // 活动瞬间
}

/// 瞬间摘要（列表视图）
class MomentSummary {
  final String id;
  final String userId;
  final String? userDisplayName;
  final String title;
  final String coverImageUrl;
  final String country;
  final String? city;
  final DateTime createdAt;

  const MomentSummary({
    required this.id,
    required this.userId,
    this.userDisplayName,
    required this.title,
    required this.coverImageUrl,
    required this.country,
    this.city,
    required this.createdAt,
  });

  factory MomentSummary.fromJson(Map<String, dynamic> json) {
    return MomentSummary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String?,
      title: json['title'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      country: json['country'] as String,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'country': country,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// 瞬间评论
class MomentComment {
  final String id;
  final String authorId;
  final String? authorDisplayName;
  final String content;
  final DateTime createdAt;

  const MomentComment({
    required this.id,
    required this.authorId,
    this.authorDisplayName,
    required this.content,
    required this.createdAt,
  });

  factory MomentComment.fromJson(Map<String, dynamic> json) {
    return MomentComment(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorDisplayName: json['authorDisplayName'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorDisplayName': authorDisplayName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取作者首字母（用于头像）
  String get authorInitials {
    final name = authorDisplayName ?? '';
    if (name.isEmpty) return '';
    if (name.length == 1) return name;
    return name.substring(0, 2);
  }

  /// 获取时间标签（相对时间）
  String get timeLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 瞬间详情（详情视图）
class MomentDetail {
  final String id;
  final String userId;
  final String? userDisplayName;
  final String title;
  final String? content;
  final String coverImageUrl;
  final String country;
  final String? city;
  final DateTime createdAt;
  final List<String> images;
  final List<MomentComment> comments;

  const MomentDetail({
    required this.id,
    required this.userId,
    this.userDisplayName,
    required this.title,
    this.content,
    required this.coverImageUrl,
    required this.country,
    this.city,
    required this.createdAt,
    this.images = const [],
    this.comments = const [],
  });

  factory MomentDetail.fromJson(Map<String, dynamic> json) {
    return MomentDetail(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String?,
      title: json['title'] as String,
      content: json['content'] as String?,
      coverImageUrl: json['coverImageUrl'] as String,
      country: json['country'] as String,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => MomentComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'title': title,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'country': country,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  /// 获取所有媒体资源（封面 + 图片列表）
  List<String> get mediaAssets {
    final all = [coverImageUrl, ...images];
    return all.where((url) => url.isNotEmpty).toList();
  }

  /// 获取作者首字母（用于头像）
  String get authorInitials {
    final name = userDisplayName ?? '';
    if (name.isEmpty) return '';
    if (name.length == 1) return name;
    return name.substring(0, 2);
  }

  /// 获取时间标签（相对时间）
  String get timeLabel {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 创建瞬间请求
class CreateMomentRequest {
  final String? eventId;
  final String title;
  final String? content;
  final String coverImageUrl;
  final String country;
  final String? city;
  final List<String> images;

  const CreateMomentRequest({
    this.eventId,
    required this.title,
    this.content,
    required this.coverImageUrl,
    required this.country,
    this.city,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      if (eventId != null) 'eventId': eventId,
      'title': title,
      if (content != null) 'content': content,
      'coverImageUrl': coverImageUrl,
      'country': country,
      if (city != null) 'city': city,
      'images': images,
    };
  }
}

/// 添加评论请求
class AddMomentCommentRequest {
  final String content;

  const AddMomentCommentRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}

