import 'package:flutter/material.dart';
import 'package:crew_app/features/events/data/moment.dart' as moment_data;

/// 兼容旧的 MomentPost 格式
/// 用于向后兼容，新代码应该直接使用 MomentSummary 或 MomentDetail
class MomentPost {
  final String author;
  final String authorInitials;
  final String timeLabel;
  final String content;
  final String location;
  final List<String> tags;
  final int likes;
  final int comments;
  final Color accentColor;
  final List<String> mediaAssets;
  final List<MomentComment> commentItems;
  final moment_data.MomentType momentType;

  const MomentPost({
    required this.author,
    required this.authorInitials,
    required this.timeLabel,
    required this.content,
    required this.location,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.accentColor,
    this.mediaAssets = const [],
    this.commentItems = const [],
    this.momentType = moment_data.MomentType.event,
  });

  /// 从 MomentSummary 创建
  factory MomentPost.fromSummary(moment_data.MomentSummary summary) {
    return MomentPost(
      author: summary.userDisplayName ?? '用户',
      authorInitials: summary.userDisplayName?.substring(0, 2) ?? 'U',
      timeLabel: _formatTimeLabel(summary.createdAt),
      content: summary.title,
      location: summary.city ?? summary.country,
      tags: const [],
      likes: 0,
      comments: 0,
      accentColor: Colors.blue,
      mediaAssets: [summary.coverImageUrl],
      momentType: moment_data.MomentType.instant,
    );
  }

  /// 从 MomentDetail 创建
  factory MomentPost.fromDetail(moment_data.MomentDetail detail) {
    return MomentPost(
      author: detail.userDisplayName ?? '用户',
      authorInitials: detail.authorInitials,
      timeLabel: detail.timeLabel,
      content: detail.content ?? detail.title,
      location: detail.city ?? detail.country,
      tags: const [],
      likes: 0,
      comments: detail.comments.length,
      accentColor: Colors.blue,
      mediaAssets: detail.mediaAssets,
      commentItems: detail.comments
          .map((c) => MomentComment(
                author: c.authorDisplayName ?? '用户',
                message: c.content,
                timeLabel: c.timeLabel,
              ))
          .toList(),
      momentType: moment_data.MomentType.instant,
    );
  }

  static String _formatTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

/// 兼容旧的 MomentComment 格式
class MomentComment {
  final String author;
  final String message;
  final String timeLabel;

  const MomentComment({
    required this.author,
    required this.message,
    required this.timeLabel,
  });

  String get initials {
    if (author.isEmpty) {
      return '';
    }
    if (author.length == 1) {
      return author;
    }
    return author.substring(0, 2);
  }
}

