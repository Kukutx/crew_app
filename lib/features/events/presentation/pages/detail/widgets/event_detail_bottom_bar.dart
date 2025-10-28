import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;
  final VoidCallback onOpenPrivateChat;
  final VoidCallback onOpenGroupChat;
  final int favoriteCount;

  const EventDetailBottomBar({
    super.key,
    required this.loc,
    required this.isFavorite,
    required this.onFavorite,
    required this.onRegister,
    required this.onOpenPrivateChat,
    required this.onOpenGroupChat,
    this.favoriteCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeTag = Localizations.localeOf(context).toString();
    final sanitizedCount = favoriteCount < 0 ? 0 : favoriteCount;
    final countLabel = NumberFormat.compact(
      locale: localeTag,
    ).format(sanitizedCount);
    final favoriteColor = colorScheme.secondary;
    final favoriteBackgroundColor = colorScheme.secondaryContainer
        .withOpacity(isFavorite ? 0.45 : 0.25);
    final iconColor = colorScheme.onSurfaceVariant;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          border: Border(
            top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            _ActionIconButton(
              onTap: onFavorite,
              backgroundColor: favoriteBackgroundColor,
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: favoriteColor,
              ),
              badge: sanitizedCount > 0
                  ? _ActionBadge(label: countLabel, color: favoriteColor)
                  : null,
            ),
            const SizedBox(width: 12),
            _ActionIconButton(
              onTap: onOpenPrivateChat,
              icon: Icon(Icons.chat_bubble_outline, color: iconColor),
              backgroundColor: colorScheme.surface,
              borderColor: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 12),
            _ActionIconButton(
              onTap: onOpenGroupChat,
              icon: Icon(Icons.groups_2_outlined, color: iconColor),
              backgroundColor: colorScheme.surface,
              borderColor: colorScheme.outlineVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(loc.action_register),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? badge;

  const _ActionIconButton({
    required this.onTap,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedBackgroundColor = backgroundColor ??
        colorScheme.surfaceVariant.withOpacity(0.4);
    final resolvedBorderColor = borderColor ??
        colorScheme.outlineVariant.withOpacity(0.6);

    return Material(
      color: resolvedBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: resolvedBorderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 48,
          width: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              icon,
              if (badge != null)
                Positioned(
                  top: 6,
                  right: 8,
                  child: badge!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ActionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}