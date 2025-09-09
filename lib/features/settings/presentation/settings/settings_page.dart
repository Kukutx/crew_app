import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Locale locale;
  final bool darkMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const SettingsPage({
    required this.locale,
    required this.darkMode,
    required this.onLocaleChanged,
    required this.onDarkModeChanged,
    super.key,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _darkMode;
  late String _language;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.darkMode;
    _language = widget.locale.languageCode == 'zh' ? 'zh' : 'en';
  }

   @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          // 深色模式
          SwitchListTile(
            title: Text(loc.dark_mode),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              widget.onDarkModeChanged(value);
            },
          ),
          // 语言选择
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: _language,
              items: [
                DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _language = value);
                widget.onLocaleChanged(Locale(value));
              },
            ),
          ),
          const Divider(),
          // 关于
          ListTile(
            title: Text(loc.about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

