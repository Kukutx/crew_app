import 'package:crew_app/app/view/crew_app.dart';
import 'package:crew_app/bootstrap/bootstrapper.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  await Bootstrapper().run((result) {
    return ProviderScope(
      overrides: result.overrides,
      child: BetterFeedback(
        child: const CrewApp(),
        // child: const MapWithPlannerSheetPage(),
        // child: GoogleMapsClonePage(),
      ),
    );
  });
}
