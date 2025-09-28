import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/data/disclaimer.dart';
import 'package:flutter/material.dart';

Future<bool> showDisclaimerDialog({
  required BuildContext context,
  required Disclaimer d,
  required VoidCallback onAccept,
}) async {
  bool acknowledged = false;

  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 强制阅读同意
    builder: (dialogContext) {
      final loc = AppLocalizations.of(dialogContext)!;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('${d.title}（v${d.version}）'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320, minWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: SingleChildScrollView(
                      child: Text(d.content),
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(loc.disclaimer_exit),
              ),
              ElevatedButton(
                onPressed: acknowledged
                    ? () {
                        onAccept();
                        Navigator.of(dialogContext).pop(true);
                      }
                    : null,
                child: Text(loc.disclaimer_accept),
              ),
            ],
          );
        },
      );
    },
  );

  return accepted ?? false;
}
