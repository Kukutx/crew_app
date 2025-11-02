import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

import '../../../widgets/event_image_cache_manager.dart';

class EventHostCard extends StatelessWidget {
  final AppLocalizations loc;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final VoidCallback onTapProfile;
  final VoidCallback onToggleFollow;
  final bool isFollowing;

  const EventHostCard({
    super.key,
    required this.loc,
    required this.name,
    this.bio,
    this.avatarUrl,
    required this.onTapProfile,
    required this.onToggleFollow,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    final description = (bio != null && bio!.isNotEmpty)
        ? bio!
        : loc.share_card_subtitle;
    final avatar = avatarUrl;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final cardColor = colorScheme.surfaceContainerHighest;
    final avatarBackground = colorScheme.primaryContainer;
    final avatarForeground = colorScheme.onPrimaryContainer;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTapProfile,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CrewAvatar(
                radius: 28,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? CachedNetworkImageProvider(
                        avatar,
                        cacheManager: EventImageCacheManager.instance,
                      )
                    : null,
                backgroundColor: avatarBackground,
                foregroundColor: avatarForeground,
                child: (avatar == null || avatar.isEmpty)
                    ? Icon(Icons.person, color: avatarForeground)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          titleStyle ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          subtitleStyle ??
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: isFollowing
                    ? OutlinedButton.icon(
                        onPressed: onToggleFollow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          overlayColor: colorScheme.primary.withValues(
                            alpha: 0.08,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(loc.action_following),
                      )
                    : ElevatedButton.icon(
                        onPressed: onToggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1, size: 18),
                        label: Text(loc.action_follow),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
