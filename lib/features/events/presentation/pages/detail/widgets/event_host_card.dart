import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/theme/app_colors.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventHostCard extends StatelessWidget {
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

  final AppLocalizations loc;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final VoidCallback onTapProfile;
  final VoidCallback onToggleFollow;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    final description = (bio != null && bio!.isNotEmpty)
        ? bio!
        : loc.share_card_subtitle;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTapProfile,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(avatarUrl!)
                    : null,
                child: (avatarUrl == null || avatarUrl!.isEmpty)
                    ? Text(
                        name.isNotEmpty ? name.characters.first.toUpperCase() : '?',
                        style: AppTextStyles.title.copyWith(color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMuted,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetaChip(icon: Icons.timeline, label: loc.tag_city_explore),
                        _MetaChip(icon: Icons.emoji_people, label: loc.tag_easy_social),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _FollowButton(
                isFollowing: isFollowing,
                onToggleFollow: onToggleFollow,
                loc: loc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.chip.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.isFollowing,
    required this.onToggleFollow,
    required this.loc,
  });

  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onToggleFollow,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      icon: Icon(isFollowing ? Icons.check : Icons.person_add_alt_1_rounded),
      label: Text(isFollowing ? loc.action_following : loc.action_follow),
    );
  }
}
