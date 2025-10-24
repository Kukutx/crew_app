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
    final localeTag = Localizations.localeOf(context).toString();
    final sanitizedCount = favoriteCount < 0 ? 0 : favoriteCount;
    final countLabel = NumberFormat.compact(
      locale: localeTag,
    ).format(sanitizedCount);
    final favoriteColor = isFavorite ? Colors.amber : Colors.amber.shade600;
    final favoriteBackgroundColor = isFavorite
        ? const Color(0xFFFFF7D1)
        : const Color(0xFFFFFAE6);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(color: Colors.white),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: favoriteColor,
                  ),
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
            Icon(Icons.chat),
            const SizedBox(width: 12),
            Icon(Icons.group),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
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