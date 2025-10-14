import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/user/data/authenticated_user_dto.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_navigator.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountSection extends ConsumerWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final firebaseUser = authState.value ?? ref.watch(currentUserProvider);
    final profileState = ref.watch(authenticatedUserProvider);
    final backendUser = profileState.asData?.value;
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final navigator = ref.read(settingsNavigatorProvider);
    final tiles = <Widget>[
      ListTile(
        leading: Icon(
          Icons.person_outline,
          semanticLabel: loc.settings_account_info,
        ),
        title: Text(loc.settings_account_info),
        subtitle: firebaseUser != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (firebaseUser != null)
                    Text(
                      '${loc.settings_account_email_label}: ${_resolveEmail(firebaseUser, backendUser, loc)}',
                    ),
                  Text('${loc.settings_account_uid_label}: ${_resolveUid(firebaseUser, backendUser)}'),
                ],
              )
            : Text(loc.login_prompt),
        isThreeLine: true,
        trailing: firebaseUser == null
            ? TextButton(
                onPressed: () {
                  viewModel.trackNavigation('login');
                  navigator.openNamed(context, SettingsRoute.login);
                },
                child: Text(loc.action_login),
              )
            : null,
        onTap: firebaseUser == null
            ? () {
                viewModel.trackNavigation('login');
                navigator.openNamed(context, SettingsRoute.login);
              }
            : null,
      ),
    ];

    if (firebaseUser != null) {
      tiles.addAll([
        ListTile(
          leading: Icon(
            Icons.history,
            semanticLabel: loc.browsing_history,
          ),
          title: Text(loc.browsing_history),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            viewModel.trackNavigation('history');
            navigator.openNamed(context, SettingsRoute.history);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.verified_user,
            semanticLabel: loc.verification_preferences,
          ),
          title: Text(loc.verification_preferences),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            viewModel.trackNavigation('preferences');
            navigator.openNamed(context, SettingsRoute.preferences);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.logout,
            semanticLabel: loc.action_logout,
          ),
          title: Text(loc.action_logout),
          onTap: () async {
            await viewModel.signOut();
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delete_outline,
            semanticLabel: loc.settings_account_delete,
          ),
          title: Text(loc.settings_account_delete),
          onTap: () {
            viewModel.trackNavigation('account_delete');
            viewModel
                .notifyUnavailable(SettingsUnavailableReason.accountDeletion);
          },
        ),
      ]);
    }

    return SettingsSectionCard(
      title: loc.settings_section_account,
      children: tiles,
    );
  }

  String _resolveEmail(
    fa.User user,
    AuthenticatedUserDto? backendUser,
    AppLocalizations loc,
  ) {
    final backendEmail = backendUser?.email.trim();
    if (backendEmail != null && backendEmail.isNotEmpty) {
      return backendEmail;
    }

    final firebaseEmail = user.email?.trim();
    if (firebaseEmail != null && firebaseEmail.isNotEmpty) {
      return firebaseEmail;
    }

    return loc.email_unbound;
  }

  String _resolveUid(fa.User user, AuthenticatedUserDto? backendUser) {
    final backendId = backendUser?.id.trim();
    if (backendId != null && backendId.isNotEmpty) {
      return backendId;
    }

    return user.uid;
  }
}
