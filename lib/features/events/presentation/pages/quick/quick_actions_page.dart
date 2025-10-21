import 'package:crew_app/features/events/presentation/pages/map/state/map_quick_actions_provider.dart';
import 'package:crew_app/features/events/presentation/pages/trips/create_road_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

import 'widgets/map_quick_actions_content.dart';

class MapQuickActionsPage extends ConsumerStatefulWidget {
  const MapQuickActionsPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<MapQuickActionsPage> createState() =>
      _MapQuickActionsPageState();
}

class _MapQuickActionsPageState extends ConsumerState<MapQuickActionsPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final navigator = Navigator.of(context);

    void triggerAction(MapQuickAction action) {
      ref.read(mapQuickActionProvider.notifier).state = action;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.map_quick_actions_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ),
      body: SafeArea(
        child: MapQuickActionsContent(
          onStartQuickTrip: () {
            triggerAction(MapQuickAction.startQuickTrip);
            widget.onClose();
          },
          onOpenFullTrip: () {
            widget.onClose();
            navigator.push(
              MaterialPageRoute(
                builder: (routeContext) => CreateRoadTripPage(
                  onClose: () => Navigator.of(routeContext).maybePop(),
                ),
              ),
            );
          },
          onCreateMoment: () {
            triggerAction(MapQuickAction.showMomentSheet);
            widget.onClose();
          },
          showTitle: false,
        ),
      ),
    );
  }
}
