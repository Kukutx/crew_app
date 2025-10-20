import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class PrivacyDocumentsPage extends StatelessWidget {
  const PrivacyDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.privacy_documents_page_title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text(
            loc.privacy_documents_intro,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            loc.privacy_documents_privacy_title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.privacy_documents_privacy_body,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            loc.privacy_documents_user_agreement_title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.privacy_documents_user_agreement_body,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            loc.privacy_documents_contact_title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            loc.privacy_documents_contact_body,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
