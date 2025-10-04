import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/data/disclaimer.dart';
import 'package:flutter/material.dart';

Future<bool> showDisclaimerDialog({
  required BuildContext context,
  required Disclaimer d,
  required VoidCallback onAccept,
}) async {
  bool acknowledged = false;

  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final loc = AppLocalizations.of(sheetContext)!;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            top: false,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${d.title}（v${d.version}）',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            d.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      CheckboxListTile(
                        value: acknowledged,
                        onChanged: (value) {
                          setState(() {
                            acknowledged = value ?? false;
                          });
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(loc.disclaimer_acknowledge),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(sheetContext).pop(false),
                              child: Text(loc.disclaimer_exit),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: acknowledged
                                  ? () {
                                      onAccept();
                                      Navigator.of(sheetContext).pop(true);
                                    }
                                  : null,
                              child: Text(loc.disclaimer_accept),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  return accepted ?? false;
}
