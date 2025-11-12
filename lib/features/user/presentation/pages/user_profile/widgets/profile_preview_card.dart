import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:crew_app/shared/state/location_api_providers.dart';
import 'package:crew_app/shared/utils/image_url.dart';
import 'package:crew_app/shared/widgets/profile_avatar_with_flag.dart';
import 'package:crew_app/shared/widgets/profile_info_badge.dart';
import 'package:crew_app/shared/widgets/profile_tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePreviewCard extends ConsumerWidget {
  const ProfilePreviewCard({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final flagEmoji = userProfile.countryFlag;
    final cityLabel = userProfile.city?.trim();
    final avatarUrl = sanitizeImageUrl(userProfile.avatar);
    final coverUrl = sanitizeImageUrl(userProfile.cover);

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
            // 封面背景（在卡片内）
            Positioned.fill(
              child: coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      memCacheHeight: 512,
                      fit: BoxFit.cover,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
            ),
            // 渐变遮罩
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
            // 右上角操作按钮（仅查看他人时显示）
            if (showUserActions)
              Positioned(
                top: 12,
                right: 12,
                child: Wrap(
                  spacing: 8,
                  children: [
                    _MessageButton(onPressed: onMessagePressed),
                    _FollowButton(
                      followed: userProfile.followed,
                      onPressed: onFollowToggle,
                    ),
                  ],
                ),
              ),
            // 左下角头像和信息
            Positioned(
              left: 16,
              bottom: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 头像
                  ProfileAvatarWithFlag(
                    avatarUrl: avatarUrl,
                    flagEmoji: flagEmoji,
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  // 基本信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 名称和性别
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                userProfile.name,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.3,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (userProfile.gender.shouldDisplay) ...[
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GenderBadge(
                                    gender: userProfile.gender,
                                    size: 26,
                                  ),
                                  if (userProfile.customGender?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      userProfile.customGender!,
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
                        const SizedBox(height: 6),
                        // 简介
                        Text(
                          userProfile.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        // 标签
                        if (userProfile.tags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in userProfile.tags)
                                ProfileTagChip(tag: tag),
                            ],
                          ),
                        ],
                        // 位置信息和IP属地
                        if (cityLabel?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ProfileInfoBadge(
                                icon: Icons.place_outlined,
                                label: cityLabel!,
                              ),
                              const SizedBox(width: 12),
                              _IpLocationWidget(loc: loc),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          _IpLocationWidget(loc: loc),
                        ],
                        // 统计数据
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _ProfileStat(
                              label: loc.profile_followers,
                              value: userProfile.followers.toCompactString(),
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: loc.profile_following,
                              value: userProfile.following.toCompactString(),
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: loc.profile_events,
                              value: userProfile.events.toCompactString(),
                            ),
                          ],
                        ),
                        // 查看留言簿按钮
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: onGuestbookPressed,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            loc.profile_view_guestbook,
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.5,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              height: 1.3,
                              letterSpacing: 0,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Colors.white;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.9),
            fontSize: 12,
            height: 1.3,
            letterSpacing: 0,
          ),
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

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.followed, required this.onPressed});

  final bool followed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: followed
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white,
        foregroundColor: followed
            ? Colors.white
            : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: followed ? 0 : 2,
      ),
      onPressed: onPressed,
      child: Text(
        followed ? loc.action_following : loc.action_follow,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MessageButton extends StatelessWidget {
  const _MessageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.mail_outline, size: 18),
      label: Text(
        loc.profile_message_button,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _IpLocationWidget extends ConsumerWidget {
  const _IpLocationWidget({
    required this.loc,
  });

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final ipLocationAsync = ref.watch(ipLocationProvider);

    return ipLocationAsync.when(
      data: (location) {
        final displayLocation = location.isNotEmpty
            ? location
            : loc.moment_post_ip_location_unknown;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.public_outlined,
              size: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '${loc.moment_post_ip_location_prefix}$displayLocation',
              style: t.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
