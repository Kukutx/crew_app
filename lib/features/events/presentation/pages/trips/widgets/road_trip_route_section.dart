import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/road_trip_editor_models.dart';
import 'road_trip_section_card.dart';

class RoadTripRouteSection extends StatelessWidget {
  const RoadTripRouteSection({
    super.key,
    required this.routeType,
    required this.onRouteTypeChanged,

    // 单程/去程
    required this.forwardWaypoints,
    required this.onAddForward,
    required this.onRemoveForward,
    required this.onReorderForward,

    // 返程（仅往返时用）
    required this.returnWaypoints,
    required this.onAddReturn,
    required this.onRemoveReturn,
    required this.onReorderReturn,
    this.waypointAddressMap,
  });

  final RoadTripRouteType routeType;
  final ValueChanged<RoadTripRouteType> onRouteTypeChanged;

  final List<LatLng> forwardWaypoints; // 途经点位置
  final VoidCallback onAddForward;
  final ValueChanged<int> onRemoveForward;
  final void Function(int oldIndex, int newIndex) onReorderForward;

  final List<LatLng> returnWaypoints; // 途经点位置
  final VoidCallback onAddReturn;
  final ValueChanged<int> onRemoveReturn;
  final void Function(int oldIndex, int newIndex) onReorderReturn;
  
  final Map<String, String>? waypointAddressMap; // 途经点地址映射

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.route_outlined,
      title: loc.road_trip_route_section_title,
      subtitle: '',
      headerTrailing: routeType == RoadTripRouteType.roundTrip
          ? MenuAnchor(
              builder: (context, ctrl, _) => FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
                onPressed: () => ctrl.isOpen ? ctrl.close() : ctrl.open(),
                icon: const Icon(Icons.add_road, size: 16),
                label: Text(
                  loc.road_trip_route_add_waypoint,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              menuChildren: [
                MenuItemButton(
                  onPressed: onAddForward,
                  child: Text(
                    loc.road_trip_route_add_to_forward,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                MenuItemButton(
                  onPressed: onAddReturn,
                  child: Text(
                    loc.road_trip_route_add_to_return,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            )
          : FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
              onPressed: onAddForward,
              icon: const Icon(Icons.add_road, size: 18),
              label: Text(loc.road_trip_route_add_waypoint),
            ),
      children: [
        // 顶部：中间 SegmentedButton + 右上"添加途经点"
        SizedBox(
          height: 48,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SegmentedButton<RoadTripRouteType>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: RoadTripRouteType.roundTrip,
                      label: Text(
                        loc.road_trip_route_type_round,
                        style: const TextStyle(fontSize: 13),
                      ),
                      icon: const Icon(Icons.autorenew, size: 18),
                    ),
                    ButtonSegment(
                      value: RoadTripRouteType.oneWay,
                      label: Text(
                        loc.road_trip_route_type_one_way,
                        style: const TextStyle(fontSize: 13),
                      ),
                      icon: const Icon(Icons.route_outlined, size: 18),
                    ),
                  ],
                  selected: {routeType},
                  onSelectionChanged: (value) => onRouteTypeChanged(value.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 列表区域
        if (routeType == RoadTripRouteType.oneWay)
          _ReorderableListSection(
            title: loc.road_trip_route_waypoints_one_way(forwardWaypoints.length),
            items: forwardWaypoints,
            onRemove: onRemoveForward,
            onReorder: onReorderForward,
            addressMap: waypointAddressMap,
          )
        else ...[
          _ReorderableListSection(
            title:
                '${loc.road_trip_route_forward_label}${loc.road_trip_route_waypoints_count(forwardWaypoints.length)}',
            items: forwardWaypoints,
            onRemove: onRemoveForward,
            onReorder: onReorderForward,
            addressMap: waypointAddressMap,
          ),
          const SizedBox(height: 12),
          _ReorderableListSection(
            title:
                '${loc.road_trip_route_return_label}${loc.road_trip_route_waypoints_count(returnWaypoints.length)}',
            items: returnWaypoints,
            onRemove: onRemoveReturn,
            onReorder: onReorderReturn,
            addressMap: waypointAddressMap,
          ),
        ],
      ],
    );
  }
}

class _ReorderableListSection extends StatelessWidget {
  const _ReorderableListSection({
    required this.title,
    required this.items,
    required this.onRemove,
    required this.onReorder,
    this.addressMap,
  });

  final String title;
  final List<LatLng> items;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Map<String, String>? addressMap; // 途经点地址映射

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            onReorder(oldIndex, newIndex);
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            final loc = AppLocalizations.of(context)!;
            final item = items[index];
            final key = '${item.latitude}_${item.longitude}';
            final address = addressMap?[key];
            final text = address ?? loc.road_trip_route_waypoint_label(index + 1); // 显示地址或编号
            return Dismissible(
              key: ValueKey('wp-$index-${item.latitude}-${item.longitude}'),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onRemove(index),
              child: ListTile(
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator),
                ),
                title: Text(
                  '${index + 1}. $text',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemove(index),
                ),
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        ),
      ],
    );
  }
}
