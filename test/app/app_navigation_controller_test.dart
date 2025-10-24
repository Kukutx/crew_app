import 'package:crew_app/app/state/app_navigation_controller.dart';
import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppNavigationController', () {
    test('onDestinationSelected resets navigation index after sheets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(appNavigationControllerProvider);

      var eventsSheetCalls = 0;
      await controller.onDestinationSelected(
        0,
        showEventsSheet: () async => eventsSheetCalls++,
        showChatSheet: () async {},
      );

      expect(eventsSheetCalls, 1);
      expect(controller.navigationIndex, 1);
    });

    test('onDestinationSelected closes overlays when returning to map', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(appNavigationControllerProvider);

      container.read(appOverlayIndexProvider.notifier).state = 2;
      expect(controller.index, 2);

      await controller.onDestinationSelected(
        1,
        showEventsSheet: () async {},
        showChatSheet: () async {},
      );

      expect(container.read(appOverlayIndexProvider), 1);
    });

    test('handleScrollActivity debounces scroll end updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(appNavigationControllerProvider);

      fakeAsync((async) {
        expect(controller.isScrolling, isFalse);

        controller.handleScrollActivity(true);
        expect(controller.isScrolling, isTrue);

        controller.handleScrollActivity(false);
        async.elapse(const Duration(milliseconds: 299));
        expect(controller.isScrolling, isTrue);

        async.elapse(const Duration(milliseconds: 1));
        expect(controller.isScrolling, isFalse);
      });
    });
  });
}
