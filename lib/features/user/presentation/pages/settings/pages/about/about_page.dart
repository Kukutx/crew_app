import 'package:crew_app/core/state/app_update/state/app_update_providers.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/privacy/privacy_documents_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final updateStateAsync = ref.watch(appUpdateStateProvider);

    String resolveUpdateStatus(AppUpdateState? state) {
      if (state == null) {
        return loc.about_update_status_unknown;
      }

      final info = state.info;
      final resolvedVersion = () {
        if (info.latestVersion.isNotEmpty) {
          return info.latestVersion;
        }
        if (info.minSupportedVersion.isNotEmpty) {
          return info.minSupportedVersion;
        }
        return state.currentVersion;
      }();

      if (state.requiresForceUpdate) {
        return loc.about_update_status_required(resolvedVersion);
      }
      if (state.hasOptionalUpdate) {
        return loc.about_update_status_optional(resolvedVersion);
      }
      return loc.about_update_status_up_to_date;
    }

    Widget buildUpdateSubtitle() {
      return updateStateAsync.when(
        data: (state) {
          final message = state?.info.message;
          final children = <Widget>[
            Text(
              resolveUpdateStatus(state),
              style: theme.textTheme.bodyMedium,
            ),
          ];

          if (message != null && message.isNotEmpty) {
            children.addAll([
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodySmall,
              ),
            ]);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) => Text(
          loc.load_failed,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings_app_version)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/crew.png',
                height: 96,
                width: 96,
              ),
              const SizedBox(height: 16),
              Text(
                'Crew',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              packageInfoAsync.when(
                data: (info) => Column(
                  children: [
                    Text(
                      '${loc.about_current_version}: ${info.version}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${loc.about_build_number}: ${info.buildNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Text(
                  loc.load_failed,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.system_update_outlined),
                  title: Text(loc.about_check_updates),
                  subtitle: buildUpdateSubtitle(),
                  trailing: const Icon(Icons.refresh),
                  onTap: () => ref.refresh(appUpdateStateProvider),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(loc.settings_privacy_documents),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyDocumentsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}