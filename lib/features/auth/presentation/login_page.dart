import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/user/authenticated_user_provider.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/privacy/privacy_documents_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
// import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
// import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
// import 'package:firebase_ui_oauth_twitter/firebase_ui_oauth_twitter.dart';

/// 登录完成后跳转的路由名
const String kHomeRoute = '/';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _showMoreOptions = false;
  bool _agreedToTerms = false;

  List<fui.AuthProvider> _buildProviders(BuildContext context) {
    final providers = <fui.AuthProvider>[
      GoogleProvider(
        clientId:
            '417490407531-111poe29m187rdr8d43mp93v9fq92of1.apps.googleusercontent.com',
      ),
    ];

  //   if (_showMoreOptions) {
  //     providers.addAll([
  //       FacebookProvider(
  //         clientId: 'YOUR_FACEBOOK_APP_ID',
  //         redirectUri: 'https://YOUR_FIREBASE_PROJECT.firebaseapp.com/__/auth/handler',
  //       ),
  //       TwitterProvider(
  //         apiKey: 'YOUR_TWITTER_API_KEY',
  //         apiSecretKey: 'YOUR_TWITTER_API_SECRET',
  //         redirectUri: 'https://YOUR_FIREBASE_PROJECT.firebaseapp.com/__/auth/handler',
  //       ),
  //     ]);

  //     if (Theme.of(context).platform == TargetPlatform.iOS) {
  //       providers.add(AppleProvider());
  //     }
  //   }

    return providers;
  }

  void _toggleMoreOptions() {
    setState(() {
      _showMoreOptions = !_showMoreOptions;
    });
  }

  void _openPrivacyDocuments(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PrivacyDocumentsPage(),
      ),
    );
  }

  Widget _buildAgreementLink(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: GestureDetector(
        onTap: () => _openPrivacyDocuments(context),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection(
    BuildContext context,
    AppLocalizations loc,
  ) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final separator = locale.languageCode == 'zh' ? '、' : ', ';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) {
            setState(() {
              _agreedToTerms = value ?? false;
            });
          },
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                loc.login_agreement_prefix,
                style: theme.textTheme.bodySmall,
              ),
              _buildAgreementLink(context, loc.login_agreement_terms),
              Text(
                separator,
                style: theme.textTheme.bodySmall,
              ),
              _buildAgreementLink(context, loc.login_agreement_privacy),
              Text(
                separator,
                style: theme.textTheme.bodySmall,
              ),
              _buildAgreementLink(context, loc.login_agreement_children),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final providers = _buildProviders(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: fui.SignInScreen(
                providers: providers,
                showAuthActionSwitch: false,
                showPasswordVisibilityToggle: false,
                headerBuilder: (context, constraints, _) => Column(
                  children: [
                    const SizedBox(height: 48),
                    Icon(
                      Icons.nightlight_round,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.login_title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        loc.login_subtitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                subtitleBuilder: (context, action) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    loc.login_prompt,
                    textAlign: TextAlign.center,
                  ),
                ),
                footerBuilder: (context, action) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAgreementSection(context, loc),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _toggleMoreOptions,
                        icon: Icon(
                          _showMoreOptions
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        label: Text(
                          _showMoreOptions
                              ? loc.login_other_options_hide
                              : loc.login_other_options,
                        ),
                      ),
                      if (_showMoreOptions) ...[
                        const SizedBox(height: 8),
                        Text(
                          loc.login_other_options_title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.login_other_options_description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        loc.login_footer,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                actions: [
                  fui.AuthStateChangeAction<fui.SignedIn>((context, state) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref
                          .read(authServiceProvider)
                          .getIdToken(forceRefresh: true);

                      final profile = await ref
                          .read(authenticatedUserProvider.notifier)
                          .refreshProfile();

                      if (profile != null) {
                        debugPrint('Authenticated user: ${profile.email}');
                      } else {
                        debugPrint('Authenticated user profile not available.');
                      }
                    } on ApiException catch (error) {
                      messenger
                          .showSnackBar(SnackBar(content: Text(error.message)));
                    } catch (error, stackTrace) {
                      debugPrint('Failed to sync user: $error\n$stackTrace');
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Failed to sync user information.'),
                        ),
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed(kHomeRoute);
                  }),
                  fui.AuthStateChangeAction<fui.UserCreated>((context, state) {
                    Navigator.of(context).pushReplacementNamed(kHomeRoute);
                  }),
                  fui.AuthStateChangeAction<fui.CredentialLinked>((context, state) {
                    Navigator.of(context).pushReplacementNamed(kHomeRoute);
                  }),
                ],
                sideBuilder: (context, constraints) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    loc.login_side_info,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
