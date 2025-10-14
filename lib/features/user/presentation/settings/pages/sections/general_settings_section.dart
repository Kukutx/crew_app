import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

class GeneralSettingsSection extends ConsumerWidget {
  const GeneralSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final themeMode = ref.watch(
      settingsViewModelProvider.select((value) => value.themeMode),
    );
    final locale = ref.watch(
      settingsViewModelProvider.select((value) => value.locale),
    );
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final selectedLanguage = locale.languageCode == 'zh' ? 'zh' : 'en';

    return SettingsSectionCard(
      title: loc.settings_section_general,
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          secondary: Icon(
            Icons.dark_mode_outlined,
            semanticLabel: loc.dark_mode,
          ),
          title: Text(loc.dark_mode),
          subtitle: Text(loc.settings_dark_mode_subtitle),
          value: themeMode == ThemeMode.dark,
          onChanged: viewModel.toggleDarkMode,
        ),
        ListTile(
          leading: Icon(
            Icons.language_outlined,
            semanticLabel: loc.language,
          ),
          title: Text(loc.language),
          trailing: DropdownButton<String>(
            value: selectedLanguage,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value == null) return;
              viewModel.changeLocale(Locale(value));
            },
            items: [
              DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
              DropdownMenuItem(value: 'en', child: Text(loc.english)),
            ],
          ),
        ),
      ],
    );
  }
}
