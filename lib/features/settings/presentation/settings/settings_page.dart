import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/settings/settings_providers.dart';import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(context)!;
    final selectedLanguage = settings.locale.languageCode == 'zh' ? 'zh' : 'en';

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          // 深色模式
          SwitchListTile(
            title: Text(loc.dark_mode),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setDarkMode(value);
            },
          ),
          // 语言选择
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: [
                DropdownMenuItem(value: 'zh', child: Text(loc.chinese)),
                DropdownMenuItem(value: 'en', child: Text(loc.english)),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(settingsProvider.notifier).setLocale(Locale(value));
              },
            ),
          ),
          const Divider(),
          // 问题反馈
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(loc.report_issue),
            subtitle: Text(loc.report_issue_description),
            onTap: () async {
              final feedbackService = ref.read(feedbackServiceProvider);
              final submitted = await feedbackService.collectFeedback(context);
              if (!context.mounted) {
                return;
              }
              if (submitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.feedback_thanks)),
                );
              }
            },
          ),
          const Divider(),
          // 关于
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



