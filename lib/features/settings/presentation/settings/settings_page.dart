import 'package:crew_app/core/state/settings_providers.dart';
import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(context)!;
    final selectedLanguage =
        settings.locale.languageCode == 'zh' ? 'zh' : 'en';

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(loc.dark_mode),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDarkMode(value);
            },
          ),
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: [
                DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
              ],
              onChanged: (value) {
                if (value == null) return;
                ref
                    .read(settingsProvider.notifier)
                    .setLocale(Locale(value));
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
