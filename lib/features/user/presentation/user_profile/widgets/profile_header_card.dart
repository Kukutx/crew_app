import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.userProfile,
    required this.onFollowToggle,
    required this.onMessagePressed,
    required this.onGuestbookPressed,
    required this.localization,
  });

  final User userProfile;
  final VoidCallback onFollowToggle;
  final VoidCallback onMessagePressed;
  final VoidCallback onGuestbookPressed;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          elevation: 6,
          color: Colors.white.withValues(alpha: 0.12),
          surfaceTintColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;

                Widget buildProfileDetails() {
                  return DefaultTextStyle(
                    style: t.bodyMedium!.copyWith(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile.name,
                          style: t.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (userProfile.tags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _ProfileTagList(tags: userProfile.tags),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          userProfile.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ProfileStat(
                              label: localization.profile_stat_followers,
                              value: userProfile.followers,
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: localization.profile_stat_following,
                              value: userProfile.following,
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: localization.profile_stat_events,
                              value: userProfile.events,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                final actionButtons = Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _MessageButton(
                            onPressed: onMessagePressed,
                            localization: localization,
                          ),
                          _FollowButton(
                            followed: userProfile.followed,
                            onPressed: onFollowToggle,
                            localization: localization,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Tooltip(
                        message: localization.profile_action_view_guestbook,
                        child: TextButton(
                          onPressed: onGuestbookPressed,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            localization.profile_action_view_guestbook,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final avatar = ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: CachedNetworkImage(
                    imageUrl: userProfile.avatar,
                    cacheKey:
                        'profile_avatar_${userProfile.uid}_${userProfile.avatar.hashCode}',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          avatar,
                          const SizedBox(width: 12),
                          Expanded(child: buildProfileDetails()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      actionButtons,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    avatar,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: buildProfileDetails()),
                              const SizedBox(width: 12),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 180),
                                child: actionButtons,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTagList extends StatelessWidget {
  const _ProfileTagList({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          children: [
            for (var i = 0; i < tags.length; i++) ...[
              if (i != 0) const SizedBox(width: 8),
              _ProfileTag(label: tags[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Colors.white;

    return Row(
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleSmall!.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(color: color),
        ),
      ],
    );
  }
}

class _ProfileStatDot extends StatelessWidget {
  const _ProfileStatDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({
    required this.followed,
    required this.onPressed,
    required this.localization,
  });

  final bool followed;
  final VoidCallback onPressed;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final label = followed
        ? localization.action_following
        : localization.action_follow;

    return Tooltip(
      message: label,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: followed ? Colors.white10 : Colors.white,
          foregroundColor: followed ? Colors.white : Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({
    required this.onPressed,
    required this.localization,
  });

  final VoidCallback onPressed;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: localization.profile_action_message_tooltip,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.mail_outline, size: 18),
        label: Text(localization.profile_action_message),
      ),
    );
  }
}
