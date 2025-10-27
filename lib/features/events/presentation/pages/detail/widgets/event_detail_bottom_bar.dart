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
            TextButton(
              onPressed: onFavorite,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                backgroundColor: favoriteBackgroundColor,
                foregroundColor: favoriteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isFavorite ? Icons.star : Icons.star_border,
                      color: favoriteColor),
                  const SizedBox(width: 6),
                  Text(
                    countLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: favoriteColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chat, color: iconColor),
            const SizedBox(width: 12),
            Icon(Icons.group, color: iconColor),
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