import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/theme/app_colors.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.userProfile,
    required this.onFollowToggle,
    required this.onMessagePressed,
    required this.onGuestbookPressed,
    this.showUserActions = true,
  });

  final User userProfile;
  final VoidCallback onFollowToggle;
  final VoidCallback onMessagePressed;
  final VoidCallback onGuestbookPressed;
  final bool showUserActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: CachedNetworkImageProvider(userProfile.avatar),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userProfile.name, style: AppTextStyles.headline),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: userProfile.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userProfile.bio,
                        style: AppTextStyles.bodyMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _StatTile(label: 'Following', value: userProfile.following),
                const SizedBox(width: 24),
                _StatTile(label: 'Followers', value: userProfile.followers),
                const SizedBox(width: 24),
                _StatTile(label: 'Trips', value: userProfile.events),
              ],
            ),
            const SizedBox(height: 24),
            if (showUserActions)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: onMessagePressed,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onFollowToggle,
                    icon: Icon(
                      userProfile.followed
                          ? Icons.check_circle
                          : Icons.person_add_alt,
                    ),
                    label: Text(
                      userProfile.followed ? 'Following' : 'Follow',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onGuestbookPressed,
              icon: const Icon(Icons.book_outlined),
              label: const Text('Guestbook'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: AppTextStyles.headline),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodyMuted),
        ],
      ),
    );
  }
}
