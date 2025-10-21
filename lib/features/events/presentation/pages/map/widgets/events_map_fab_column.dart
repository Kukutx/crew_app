import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:flutter/material.dart';

class EventsMapFabColumn extends StatelessWidget {
  const EventsMapFabColumn({
    super.key,
    required this.bottomPadding,
    required this.onCreateMoment,
    required this.onMyLocation,
  });

  final double bottomPadding;
  final VoidCallback onCreateMoment;
  final VoidCallback onMyLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: FloatingActionButton(
            heroTag: 'events_map_add_fab',
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: onCreateMoment,
            child: const Icon(Icons.add),
          ),
        ),
        AppFloatingActionButton(
          heroTag: 'events_map_my_location_fab',
          margin: EdgeInsets.only(top: 12, bottom: bottomPadding, right: 6),
          onPressed: onMyLocation,
          child: const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
