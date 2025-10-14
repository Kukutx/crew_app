import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_navigator.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportSection extends ConsumerWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final navigator = ref.read(settingsNavigatorProvider);

    return SettingsSectionCard(
      title: loc.settings_section_support,
      children: [
        ListTile(
          leading: Icon(
            Icons.help_outline,
            semanticLabel: loc.settings_help_feedback,
          ),
          title: Text(loc.settings_help_feedback),
          subtitle: Text(loc.settings_help_feedback_subtitle),
          onTap: () async {
            viewModel.trackNavigation('feedback');
            await viewModel.requestFeedback(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
            semanticLabel: loc.settings_app_version,
          ),
          title: Text(loc.settings_app_version),
          subtitle: Text(loc.settings_app_version_subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            viewModel.trackNavigation('about');
            navigator.openAbout(context);
          },
        ),
      ],
    );
  }
}
