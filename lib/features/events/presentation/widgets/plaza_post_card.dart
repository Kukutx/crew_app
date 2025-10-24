import 'package:crew_app/shared/extensions/common_extensions.dart';
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
  final List<String> mediaAssets;
  final List<PlazaComment> commentItems;
  final PlazaMomentType momentType;

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
    this.mediaAssets = const [],
    this.commentItems = const [],
    this.momentType = PlazaMomentType.event,
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
  final VoidCallback? onMediaTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onAuthorTap;

  const PlazaPostCard({
    super.key,
    required this.post,
    this.margin,
    this.onMediaTap,
    this.onCommentTap,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = switch (post.momentType) {
      PlazaMomentType.instant => const Color(0xFFFFEEF4),
      PlazaMomentType.event => const Color(0xFFE7F0FF),
    };

    return Card(
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onAuthorTap,
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                      backgroundColor: post.accentColor.withValues(alpha: 0.15),
                      child: Text(
                        post.authorInitials,
                        style: TextStyle(
                          color: post.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (post.mediaAssets.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PlazaPostMedia(
                  mediaAssets: post.mediaAssets,
                  accentColor: post.accentColor,
                  onTap: onMediaTap,
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
                    label: post.likes.toCompactString(),
                  ),
                  const SizedBox(width: 16),
                  _PlazaPostAction(
                    icon: Icons.chat_bubble_outline,
                    label: post.comments.toCompactString(),
                    onTap: onCommentTap,
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

enum PlazaMomentType { instant, event }

class _PlazaPostMedia extends StatelessWidget {
  final List<String> mediaAssets;
  final Color accentColor;
  final VoidCallback? onTap;

  const _PlazaPostMedia({
    required this.mediaAssets,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          height: 148,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: _PlazaPostMediaPreview(
              mediaAssets: mediaAssets,
              accentColor: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlazaPostMediaPreview extends StatelessWidget {
  final List<String> mediaAssets;
  final Color accentColor;

  const _PlazaPostMediaPreview({
    required this.mediaAssets,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstAsset = mediaAssets.first;
    final remainingCount = mediaAssets.length - 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.08)),
          child: Image.asset(
            firstAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: accentColor,
                size: 32,
              ),
            ),
          ),
        ),
        if (remainingCount > 0)
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                '+$remainingCount',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlazaPostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PlazaPostAction({required this.icon, required this.label, this.onTap});

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
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
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