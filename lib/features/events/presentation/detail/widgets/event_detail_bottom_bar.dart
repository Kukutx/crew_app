import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventDetailBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;

  const EventDetailBottomBar({
    super.key,
    required this.loc,
    required this.isFavorite,
    required this.onFavorite,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.08),
                shape: const CircleBorder(),
              ),
              color: colorScheme.primary,
              onPressed: onFavorite,
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
