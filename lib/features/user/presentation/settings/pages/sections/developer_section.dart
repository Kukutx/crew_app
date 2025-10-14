import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_navigator.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeveloperSection extends ConsumerWidget {
  const DeveloperSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final navigator = ref.read(settingsNavigatorProvider);

    return SettingsSectionCard(
      title: loc.settings_section_developer,
      children: [
        ListTile(
          leading: const Icon(Icons.science_outlined),
          title: const Text('测试 Crashlytics'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            viewModel.trackNavigation('developer_crash_test');
            navigator.openCrashTest(context);
          },
        ),
      ],
    );
  }
}
