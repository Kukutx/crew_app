import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final description = (bio != null && bio!.isNotEmpty)
        ? bio!
        : loc.share_card_subtitle;
    final avatar = avatarUrl;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTapProfile,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? CachedNetworkImageProvider(avatar)
                    : null,
                backgroundColor: colorScheme.surfaceVariant,
                child: (avatar == null || avatar.isEmpty)
                    ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                            color: colorScheme.primary.withValues(alpha: 0.4),
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
