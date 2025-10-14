import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacySection extends ConsumerWidget {
  const PrivacySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final permission = ref.watch(
      settingsViewModelProvider.select((value) => value.locationPermission),
    );
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return SettingsSectionCard(
      title: loc.settings_section_privacy,
      children: [
        ListTile(
          leading: Icon(
            Icons.location_on_outlined,
            semanticLabel: loc.settings_location_permission,
          ),
          title: Text(loc.settings_location_permission),
          subtitle: Text(permission.label(loc)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLocationPermissionSheet(context, ref, permission),
        ),
        ListTile(
          leading: Icon(
            Icons.block_outlined,
            semanticLabel: loc.settings_manage_blocklist,
          ),
          title: Text(loc.settings_manage_blocklist),
          onTap: () {
            viewModel.trackNavigation('privacy_blocklist');
            viewModel
                .notifyUnavailable(SettingsUnavailableReason.privacyBlocklist);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            semanticLabel: loc.settings_privacy_documents,
          ),
          title: Text(loc.settings_privacy_documents),
          onTap: () {
            viewModel.trackNavigation('privacy_documents');
            viewModel
                .notifyUnavailable(SettingsUnavailableReason.privacyDocuments);
          },
        ),
      ],
    );
  }

  void _showLocationPermissionSheet(
    BuildContext context,
    WidgetRef ref,
    LocationPermissionOption current,
  ) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in LocationPermissionOption.values)
                ListTile(
                  title: Text(option.label(loc)),
                  trailing: Icon(
                    option == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  selected: option == current,
                  onTap: () {
                    viewModel.updateLocationPermission(option);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
