import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> showWalletHelpBottomSheet(BuildContext context) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context)!;

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.wallet_insights_title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                loc.wallet_help_description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.wallet_help_close),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
