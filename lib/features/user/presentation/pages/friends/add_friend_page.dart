import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.add_friend_title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            loc.feature_not_ready,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
