import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:crew_app/features/events/data/adapters/moment_adapter.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';

/// Moment 帖子卡片
class MomentPostCard extends StatelessWidget {
  final MomentPost post;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onMediaTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onAuthorTap;

  const MomentPostCard({
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
    final baseBackground = colorScheme.surfaceContainerHighest;
    final accentTint = post.accentColor.withValues(alpha: 0.14);
    final backgroundColor = Color.alphaBlend(accentTint, baseBackground);

    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme, colorScheme),
            const SizedBox(height: 12),
            _buildContent(theme),
            if (post.mediaAssets.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MomentPostMedia(
                mediaAssets: post.mediaAssets,
                accentColor: post.accentColor,
                onTap: onMediaTap,
              ),
            ],
            if (post.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildLocation(context, theme, colorScheme),
            ],
            const SizedBox(height: 12),
            _buildActions(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onAuthorTap,
          borderRadius: BorderRadius.circular(16),
          child: CrewAvatar(
            radius: 22,
            backgroundColor: post.accentColor.withValues(alpha: 0.15),
            foregroundColor: post.accentColor,
            child: Text(
              post.authorInitials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                post.timeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      post.content,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.5,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildLocation(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Text(
            post.location,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        _MomentPostAction(
          icon: Icons.favorite_border,
          label: post.likes.toCompactString(),
        ),
        const SizedBox(width: 16),
        _MomentPostAction(
          icon: Icons.chat_bubble_outline,
          label: post.comments.toCompactString(),
          onTap: onCommentTap,
        ),
      ],
    );
  }
}

/// Moment 媒体组件
class _MomentPostMedia extends StatelessWidget {
  final List<String> mediaAssets;
  final Color accentColor;
  final VoidCallback? onTap;

  const _MomentPostMedia({
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
            child: _MomentPostMediaPreview(
              mediaAssets: mediaAssets,
              accentColor: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Moment 媒体预览
class _MomentPostMediaPreview extends StatelessWidget {
  final List<String> mediaAssets;
  final Color accentColor;

  const _MomentPostMediaPreview({
    required this.mediaAssets,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstAsset = mediaAssets.first;
    final remainingCount = mediaAssets.length - 1;
    final isNetworkImage =
        firstAsset.startsWith('http://') || firstAsset.startsWith('https://');

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.08)),
          child: isNetworkImage
              ? Image.network(
                  firstAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              : Image.asset(
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

/// Moment 操作按钮
class _MomentPostAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MomentPostAction({
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
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
