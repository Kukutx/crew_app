import 'package:crew_app/core/state/update/app_update_providers.dart';
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

    Widget buildVersionSection() {
      return packageInfoAsync.when(
        data: (info) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${loc.about_current_version}: ${info.version}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.about_build_number}: ${info.buildNumber}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Text(
          loc.load_failed,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    Widget buildUpdateSection() {
      return updateStateAsync.when(
        data: (state) {
          final info = state?.info;
          final resolvedVersion = () {
            if (info == null) {
              return null;
            }
            if (info.latestVersion.isNotEmpty) {
              return info.latestVersion;
            }
            if (info.minSupportedVersion.isNotEmpty) {
              return info.minSupportedVersion;
            }
            return null;
          }();

          final versionLabel = resolvedVersion ?? loc.unknown;
          final statusText = () {
            if (state == null) {
              return loc.about_update_status_unknown;
            }
            if (state.requiresForceUpdate) {
              final target = resolvedVersion ?? state.currentVersion;
              return loc.about_update_status_required(target);
            }
            if (state.hasOptionalUpdate) {
              final target = resolvedVersion ?? state.currentVersion;
              return loc.about_update_status_optional(target);
            }
            return loc.about_update_status_up_to_date;
          }();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                versionLabel,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                statusText,
                style: theme.textTheme.bodyMedium,
              ),
              if (info?.message?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  info!.message!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          );
        },
        loading: () => const SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator()),
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
      appBar: AppBar(title: Text(loc.about)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              loc.about_section_version_details,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: buildVersionSection(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.about_latest_version,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    buildUpdateSection(),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => ref.refresh(appUpdateStateProvider),
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.about_check_updates),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}