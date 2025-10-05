import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventDetailBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;
  final bool isFavoriteLoading;

  const EventDetailBottomBar({
    super.key,
    required this.loc,
    required this.isFavorite,
    required this.onFavorite,
    required this.onRegister,
    this.isFavoriteLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            IconButton(
              icon: isFavoriteLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : null,
                    ),
              onPressed: isFavoriteLoading ? null : onFavorite,
            ),
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
