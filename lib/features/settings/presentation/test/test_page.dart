import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.about)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.about_content),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FirebaseCrashlytics.instance.crash(),
              child: const Text('Force Crash'),
            ),
          ],
        ),
      ),
    );
  }
}
