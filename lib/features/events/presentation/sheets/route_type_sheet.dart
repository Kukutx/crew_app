import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

Future<bool?> showRouteTypeSheet({
  required BuildContext context,
  bool? initialValue,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: false,
    builder: (sheetContext) {
      final loc = AppLocalizations.of(sheetContext)!;
      bool selection = initialValue ?? false;
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    loc.event_route_type_title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                RadioListTile<bool>(
                  value: false,
                  groupValue: selection,
                  onChanged: (value) => setState(() => selection = value ?? false),
                  title: Text('${loc.event_route_type_one_way} 🚗'),
                ),
                RadioListTile<bool>(
                  value: true,
                  groupValue: selection,
                  onChanged: (value) => setState(() => selection = value ?? false),
                  title: Text('${loc.event_route_type_round} 🔁'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(loc.action_confirm),
                  onTap: () => Navigator.of(sheetContext).pop(selection),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(loc.action_cancel),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  );
}
