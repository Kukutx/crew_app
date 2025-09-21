import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_update_status.dart';

Future<void> showAppUpdateDialog({
  required BuildContext context,
  required AppUpdateStatus status,
}) {
  final loc = AppLocalizations.of(context)!;
  final isMandatory = status.requiresUpdate;

  return showDialog<void>(
    context: context,
    barrierDismissible: !isMandatory,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          isMandatory
              ? loc.update_dialog_required_title
              : loc.update_dialog_title,
        ),
        content: Text(
          status.message ??
              (isMandatory
                  ? loc.update_dialog_required_message(status.latestVersion)
                  : loc.update_dialog_message(status.latestVersion)),
        ),
        actions: [
          if (!isMandatory)
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.update_later),
            ),
          FilledButton(
            onPressed: status.canLaunchUpdate
                ? () async {
                    final launched = await _launchUpdateUrl(status.updateUrl!);
                    if (!launched && context.mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.update_launch_failed)),
                      );
                    } else if (!isMandatory && dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  }
                : null,
            child: Text(loc.update_now),
          ),
        ],
      );
    },
  );
}

Future<bool> _launchUpdateUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
