import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/country_helper.dart';
import 'package:crew_app/shared/widgets/profile_avatar_with_flag.dart';
import 'package:crew_app/shared/widgets/profile_info_badge.dart';
import 'package:crew_app/shared/widgets/profile_tag_chip.dart';
import 'package:flutter/material.dart';

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
    this.customGender,
    required this.city,
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
  final String? customGender;
  final String? city;
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final flagEmoji = CountryHelper.countryCodeToEmoji(countryCode);
    final infoBadges = <Widget>[];
    final cityLabel = city?.trim();

    if (cityLabel?.isNotEmpty ?? false) {
      infoBadges.add(ProfileInfoBadge(
        icon: Icons.place_outlined,
        label: cityLabel!,
      ));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                memCacheHeight: 512, // 合理压缩，减内存抖动
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
              top: 12,
              right: 12,
              child: FilledButton.tonalIcon(
                onPressed: onEditCover,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.photo_outlined, size: 18),
                label: Text(
                  loc.preferences_cover_action,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
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
                        child: ProfileAvatarWithFlag(
                          avatarUrl: avatarUrl,
                          flagEmoji: flagEmoji,
                          radius: 40,
                          onTap: onEditAvatar,
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Material(
                          shape: const CircleBorder(),
                          color: theme.colorScheme.primary,
                          elevation: 2,
                          child: InkWell(
                            onTap: onEditAvatar,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(7),
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.3,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (gender.shouldDisplay) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GenderBadge(gender: gender, size: 26),
                                  if (customGender?.isNotEmpty ?? false) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      customGender!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag in tags)
                                ProfileTagChip(
                                  tag: tag,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
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
