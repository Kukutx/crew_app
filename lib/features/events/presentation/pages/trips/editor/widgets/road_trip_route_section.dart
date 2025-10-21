import 'package:flutter/material.dart';

import '../road_trip_editor_models.dart';
import 'road_trip_form_decorations.dart';
import 'road_trip_section_card.dart';

class RoadTripRouteSection extends StatelessWidget {
  const RoadTripRouteSection({
    super.key,
    required this.startController,
    required this.endController,
    required this.meetingController,
    required this.routeType,
    required this.onRouteTypeChanged,
    required this.onAddWaypoint,
    required this.onRemoveWaypoint,
    required this.waypoints,
  });

  final TextEditingController startController;
  final TextEditingController endController;
  final TextEditingController meetingController;
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
      title: '路线设定',
      subtitle: '规划起终点与集合点',
      children: [
        TextFormField(
          controller: startController,
          decoration:
              roadTripInputDecoration(context, '起点', '如：Milan Duomo 或地标'),
          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入起点' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: endController,
          decoration:
              roadTripInputDecoration(context, '终点', '如：La Spezia 或景点'),
          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入终点' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: meetingController,
          decoration:
              roadTripInputDecoration(context, '集合地点', '如：停车场、地铁口'),
          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入集合地点' : null,
        ),
        const SizedBox(height: 16),
        Text(
          '路线类型',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
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
