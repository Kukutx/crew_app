import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletManagementCard extends StatelessWidget {
  const WalletManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          children: [
            _ManagementEntry(
              icon: Icons.description_outlined,
              title: loc.wallet_view_statements,
              subtitle: loc.wallet_view_statements_subtitle,
            ),
            const Divider(height: 8),
            _ManagementEntry(
              icon: Icons.credit_card_outlined,
              title: loc.wallet_manage_methods,
              subtitle: loc.wallet_manage_methods_subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementEntry extends StatelessWidget {
  const _ManagementEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.feature_not_ready)),
        );
      },
    );
  }
}
