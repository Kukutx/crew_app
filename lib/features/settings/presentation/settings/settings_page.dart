import 'package:crew_app/core/state/settings_providers.dart';
import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late bool _darkMode;
  late String _language;

  @override
  void initState() {
    super.initState();
    _darkMode = false;
    _language = 'en';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = ref.read(settingsProvider).value;
    if (s != null) {
      _darkMode = s.themeMode == ThemeMode.dark;
      _language = (s.locale.languageCode == 'zh') ? 'zh' : 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);

    if (settingsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(loc.dark_mode),
            value: _darkMode,
            onChanged: (value) async {
              setState(() => _darkMode = value);
              await ref.read(settingsProvider.notifier).setDarkMode(value);
            },
          ),
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: _language,
              items: [
                DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
              ],
              onChanged: (value) async {
                if (value == null) return;
                setState(() => _language = value);
                await ref
                    .read(settingsProvider.notifier)
                    .setLocale(Locale(value));
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutPage()),
            ),
          ),
        ],
      ),
    );
  }
}
