import 'package:flutter/material.dart';

import '../data/road_trip_editor_models.dart';
import 'road_trip_section_card.dart';

class RoadTripRouteSection extends StatelessWidget {
  const RoadTripRouteSection({
    super.key,
    required this.routeType,
    required this.onRouteTypeChanged,
    required this.onAddWaypoint,
    required this.onRemoveWaypoint,
    required this.waypoints,
  });

  final RoadTripRouteType routeType;
  final ValueChanged<RoadTripRouteType> onRouteTypeChanged;
  final VoidCallback onAddWaypoint;
  final ValueChanged<int> onRemoveWaypoint;
  final List<String> waypoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RoadTripSectionCard(
      icon: Icons.route_outlined,
      title: '路线类型',
      subtitle: '',
      children: [
        SegmentedButton<RoadTripRouteType>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: RoadTripRouteType.roundTrip,
              label: Text('往返路线'),
              icon: Icon(Icons.autorenew),
            ),
            ButtonSegment(
              value: RoadTripRouteType.oneWay,
              label: Text('单程路线'),
              icon: Icon(Icons.route_outlined),
            ),
          ],
          selected: {routeType},
          onSelectionChanged: (value) => onRouteTypeChanged(value.first),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onAddWaypoint,
              icon: const Icon(Icons.add_road),
              label: const Text('添加途经点'),
            ),
            const SizedBox(width: 12),
            if (waypoints.isNotEmpty)
              Text(
                '共 ${waypoints.length} 个',
                style: theme.textTheme.bodyMedium,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: waypoints
              .asMap()
              .entries
              .map(
                (e) => Chip(
                  label: Text('${e.key + 1}. ${e.value}'),
                  onDeleted: () => onRemoveWaypoint(e.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
