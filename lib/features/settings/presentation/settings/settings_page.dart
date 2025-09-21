import 'package:crew_app/features/settings/presentation/about/about_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/core/state/settings/settings_providers.dart';
import 'package:crew_app/shared/update/app_update_dialog.dart';
import 'package:crew_app/shared/update/app_update_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final loc = AppLocalizations.of(context)!;
    final updateStatus = ref.watch(appUpdateStatusProvider);
    final selectedLanguage =
        settings.locale.languageCode == 'zh' ? 'zh' : 'en';

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
                ref
                    .read(settingsProvider.notifier)
                    .setLocale(Locale(value));
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.system_update_alt),
            title: Text(loc.check_for_updates),
            subtitle: updateStatus.when(
              data: (status) {
                if (status.hasError) {
                  return Text(loc.update_check_failed);
                }
                if (status.updateAvailable) {
                  return Text(
                    loc.update_available_label(status.latestVersion),
                  );
                }
                return Text(loc.version_label(status.currentVersion));
              },
              loading: () => Text(loc.update_checking),
              error: (_, __) => Text(loc.update_check_failed),
            ),
            trailing: updateStatus.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () async {
              final status = await ref
                  .read(appUpdateServiceProvider)
                  .checkForUpdate(forceRefresh: true);
              ref.invalidate(appUpdateStatusProvider);

              if (!context.mounted) {
                return;
              }

              if (status.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.update_check_failed)),
                );
                return;
              }

              if (status.updateAvailable) {
                await showAppUpdateDialog(
                  context: context,
                  status: status,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.update_latest)),
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



