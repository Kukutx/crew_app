import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:crew_app/shared/utils/image_url.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';

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
    final t = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.15),
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 420;

                Widget buildProfileDetails() {
                  final locationLabel = userProfile.location?.trim();
                  // 自动获取IP属地（基于设备locale）
                  final ipLocation = _getIpLocationFromLocaleStatic();

                  return DefaultTextStyle(
                    style: t.bodyMedium!.copyWith(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                userProfile.name,
                                style: t.titleMedium!.copyWith(
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
                                  GenderBadge(gender: userProfile.gender),
                                  if (userProfile.customGender?.isNotEmpty ??
                                      false) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      userProfile.customGender!,
                                      style: t.bodySmall!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                        if (userProfile.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _ProfileTagList(tags: userProfile.tags),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          userProfile.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium!.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                        if (locationLabel?.isNotEmpty ?? false || ipLocation != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (locationLabel?.isNotEmpty ?? false) ...[
                                Icon(
                                  Icons.place_outlined,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  locationLabel!,
                                  style: t.bodySmall!.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    height: 1.3,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                              if (ipLocation != null) ...[
                                if (locationLabel?.isNotEmpty ?? false) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.public_outlined,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'IP属地：$ipLocation',
                                    style: t.bodySmall!.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 13,
                                      height: 1.3,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.public_outlined,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'IP属地：$ipLocation',
                                    style: t.bodySmall!.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 13,
                                      height: 1.3,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ProfileStat(
                              label: '粉丝',
                              value: userProfile.followers.toCompactString(),
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: '关注',
                              value: userProfile.following.toCompactString(),
                            ),
                            const _ProfileStatDot(),
                            _ProfileStat(
                              label: '活动',
                              value: userProfile.events.toCompactString(),
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
                      if (showUserActions) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _MessageButton(onPressed: onMessagePressed),
                            _FollowButton(
                              followed: userProfile.followed,
                              onPressed: onFollowToggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      TextButton(
                        onPressed: onGuestbookPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '查看留言簿',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationThickness: 1.5,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.3,
                            letterSpacing: 0,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                final avatarUrl = sanitizeImageUrl(userProfile.avatar);
                final avatar = Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CrewAvatar(
                      size: 72,
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      child: avatarUrl == null
                          ? const Icon(Icons.person_outline, size: 32)
                          : null,
                    ),
                    if (userProfile.countryFlag != null)
                      Positioned(
                        bottom: -6,
                        right: -6,
                        child: Text(
                          userProfile.countryFlag!,
                          style: const TextStyle(
                            fontSize: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
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
  
  String? _getIpLocationFromLocaleStatic() {
    final locale = ui.PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode;
    
    // 根据国家代码返回对应的地区
    if (countryCode == null) return null;
    
    // 简单的地区映射（可以根据需要扩展）
    final locationMap = {
      'CN': '中国',
      'US': '美国',
      'GB': '英国',
      'JP': '日本',
      'KR': '韩国',
      'TW': '台湾',
      'HK': '香港',
      'MO': '澳门',
      'SG': '新加坡',
      'MY': '马来西亚',
      'AU': '澳大利亚',
      'CA': '加拿大',
      'FR': '法国',
      'DE': '德国',
      'IT': '意大利',
      'ES': '西班牙',
      'NL': '荷兰',
      'BE': '比利时',
      'CH': '瑞士',
      'AT': '奥地利',
      'SE': '瑞典',
      'NO': '挪威',
      'DK': '丹麦',
      'FI': '芬兰',
      'PL': '波兰',
      'RU': '俄罗斯',
      'IN': '印度',
      'BR': '巴西',
      'MX': '墨西哥',
      'AR': '阿根廷',
      'ZA': '南非',
      'NZ': '新西兰',
      'IE': '爱尔兰',
      'PT': '葡萄牙',
      'GR': '希腊',
      'TR': '土耳其',
      'TH': '泰国',
      'VN': '越南',
      'PH': '菲律宾',
      'ID': '印度尼西亚',
    };
    
    final country = locationMap[countryCode];
    if (country == null) return countryCode;
    
    // 对于中国，可以进一步细化到省份（这里简化处理）
    if (countryCode == 'CN') {
      // 可以根据语言环境或其他因素进一步细化
      return '中国';
    }
    
    return country;
  }
}

class _ProfileTagList extends StatelessWidget {
  const _ProfileTagList({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => _ProfileTag(label: tag)).toList(),
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
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall!.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: color.withValues(alpha: 0.9),
            fontSize: 13,
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

class _ProfileTag extends StatelessWidget {
  const _ProfileTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.3,
              letterSpacing: 0,
            ),
      ),
    );
  }

  // 根据设备locale自动获取IP属地（静态方法，可在嵌套函数中使用）

}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.followed, required this.onPressed});

  final bool followed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
        followed ? '已关注' : '关注',
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
      label: const Text(
        '私信',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
