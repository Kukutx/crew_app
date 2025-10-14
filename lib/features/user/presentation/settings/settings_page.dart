import 'package:crew_app/features/user/presentation/settings/pages/sections/account_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/developer_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/general_settings_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/notification_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/privacy_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/subscription_section.dart';
import 'package:crew_app/features/user/presentation/settings/pages/sections/support_section.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_providers.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final void Function() _removeMessageListener;

  @override
  void initState() {
    super.initState();
    _removeMessageListener = ref.listen<SettingsViewState>(
      settingsViewModelProvider,
      (previous, next) {
        final message = next.message;
        if (message == null || !mounted) {
          return;
        }
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.label(loc))),
        );
        ref.read(settingsViewModelProvider.notifier).clearMessage();
      },
    );
  }

  @override
  void dispose() {
    _removeMessageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final showDeveloper = ref.watch(settingsDeveloperToolsEnabledProvider);
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const GeneralSettingsSection(),
          const SupportSection(),
          const SubscriptionSection(),
          const PrivacySection(),
          const NotificationSection(),
          if (showDeveloper) const DeveloperSection(),
          const AccountSection(),
        ],
      ),
    );
  }
}
