import 'package:flutter/material.dart';

class PlazaPost {
  final String author;
  final String authorInitials;
  final String timeLabel;
  final String content;
  final String location;
  final List<String> tags;
  final int likes;
  final int comments;
  final Color accentColor;
  final String? previewLabel;
  final List<String> mediaAssets;
  final List<PlazaComment> commentItems;

  const PlazaPost({
    required this.author,
    required this.authorInitials,
    required this.timeLabel,
    required this.content,
    required this.location,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.accentColor,
    this.previewLabel,
    this.mediaAssets = const [],
    this.commentItems = const [],
  });
}

class PlazaComment {
  final String author;
  final String message;
  final String timeLabel;

  const PlazaComment({
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

class PlazaPostCard extends StatelessWidget {
  final PlazaPost post;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onCommentTap;

  const PlazaPostCard({
    super.key,
    required this.post,
    this.margin,
    this.onTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                CircleAvatar(
                  backgroundColor: post.accentColor.withValues(alpha: 0.15),
                  child: Text(
                    post.authorInitials,
                    style: TextStyle(
                      color: post.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.timeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_horiz,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            if (post.previewLabel != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 148,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        post.accentColor.withValues(alpha: .85),
                        post.accentColor.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    post.previewLabel!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            if (post.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _PlazaPostAction(
                  icon: Icons.favorite_border,
                  label: post.likes.toString(),
                ),
                const SizedBox(width: 16),
                _PlazaPostAction(
                  icon: Icons.chat_bubble_outline,
                  label: post.comments.toString(),
                  onTap: onCommentTap,
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _PlazaPostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PlazaPostAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
