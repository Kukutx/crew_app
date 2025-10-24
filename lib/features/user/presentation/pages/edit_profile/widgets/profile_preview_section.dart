import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePreviewSection extends StatelessWidget {
  const ProfilePreviewSection({
    super.key,
    required this.coverUrl,
    required this.avatarUrl,
    required this.displayName,
    required this.bio,
    required this.tags,
    required this.countryCode,
    required this.gender,
    required this.birthday,
    required this.school,
    required this.location,
    required this.onEditCover,
    required this.onEditAvatar,
  });

  final String coverUrl;
  final String avatarUrl;
  final String displayName;
  final String bio;
  final List<String> tags;
  final String? countryCode;
  final Gender gender;
  final DateTime? birthday;
  final String? school;
  final String? location;
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final flagEmoji = countryCodeToEmoji(countryCode);
    final infoBadges = <Widget>[];
    final birthdayLabel =
        birthday == null ? null : DateFormat('yyyy年MM月dd日').format(birthday!);
    final schoolLabel = school?.trim();
    final locationLabel = location?.trim();

    if (birthdayLabel != null) {
      infoBadges.add(_InfoBadge(
        icon: Icons.cake_outlined,
        label: birthdayLabel,
      ));
    }

    if (schoolLabel?.isNotEmpty ?? false) {
      infoBadges.add(_InfoBadge(
        icon: Icons.school_outlined,
        label: schoolLabel!,
      ));
    }

    if (locationLabel?.isNotEmpty ?? false) {
      infoBadges.add(_InfoBadge(
        icon: Icons.place_outlined,
        label: locationLabel!,
      ));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FilledButton.tonalIcon(
                onPressed: onEditCover,
                icon: const Icon(Icons.photo_outlined),
                label: Text(loc.preferences_cover_action),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Semantics(
                        button: true,
                        label: loc.preferences_avatar_action,
                        child: GestureDetector(
                          onTap: onEditAvatar,
                          child: CrewAvatar(
                            radius: 40,
                            backgroundImage:
                                CachedNetworkImageProvider(avatarUrl),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                      if (flagEmoji != null)
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              flagEmoji,
                              style: const TextStyle(
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Material(
                          shape: const CircleBorder(),
                          color: theme.colorScheme.primary,
                          child: InkWell(
                            onTap: onEditAvatar,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (gender.shouldDisplay) ...[
                              const SizedBox(width: 8),
                              GenderBadge(gender: gender, size: 26),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in tags)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag,
                                    style: textTheme.labelMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (infoBadges.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: infoBadges,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        theme.textTheme.labelMedium?.copyWith(color: Colors.white) ??
            const TextStyle(color: Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
