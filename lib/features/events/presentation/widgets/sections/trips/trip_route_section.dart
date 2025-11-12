import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/common/screens/location_search_screen.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import '../event_section_card.dart';

class TripRouteSection extends StatelessWidget {
  const TripRouteSection({
    super.key,
    required this.routeType,
    required this.onRouteTypeChanged,

    // 单程/去程
    required this.forwardWaypoints,
    required this.onAddForward,
    required this.onRemoveForward,
    required this.onReorderForward,
    this.onEditForwardNote,
    this.forwardNotes,

    // 返程（仅往返时用）
    required this.returnWaypoints,
    required this.onAddReturn,
    required this.onRemoveReturn,
    required this.onReorderReturn,
    this.onEditReturnNote,
    this.returnNotes,
    
    this.waypointAddressMap,
  });

  final EventRouteType routeType;
  final ValueChanged<EventRouteType> onRouteTypeChanged;

  final List<LatLng> forwardWaypoints; // 途经点位置
  final ValueChanged<PlaceDetails> onAddForward; // 改为接收 PlaceDetails
  final ValueChanged<int> onRemoveForward;
  final void Function(int oldIndex, int newIndex) onReorderForward;
  final ValueChanged<int>? onEditForwardNote; // 点击编辑备注
  final Map<String, String>? forwardNotes; // 备注数据

  final List<LatLng> returnWaypoints; // 途经点位置
  final ValueChanged<PlaceDetails> onAddReturn; // 改为接收 PlaceDetails
  final ValueChanged<int> onRemoveReturn;
  final void Function(int oldIndex, int newIndex) onReorderReturn;
  final ValueChanged<int>? onEditReturnNote; // 点击编辑备注
  final Map<String, String>? returnNotes; // 备注数据
  
  final Map<String, String>? waypointAddressMap; // 途经点地址映射

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return EventSectionCard(
      icon: Icons.route_outlined,
      title: loc.road_trip_route_section_title,
      subtitle: loc.road_trip_route_section_subtitle,
      headerTrailing: SegmentedButton<EventRouteType>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: EventRouteType.roundTrip,
            label: Text(
              loc.road_trip_route_type_round,
              style: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.autorenew, size: 18),
          ),
          ButtonSegment(
            value: EventRouteType.oneWay,
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
      children: [
        // 添加途径点按钮
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              debugPrint('添加途径点按钮被点击');
              _onAddWaypoint(context);
            },
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('添加途径点'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ),
        // 列表区域
        if (routeType == EventRouteType.oneWay)
          _WaypointListSection(
            title: loc.road_trip_route_waypoints_one_way(forwardWaypoints.length),
            items: forwardWaypoints,
            onRemove: onRemoveForward,
            onReorder: onReorderForward,
            onTap: onEditForwardNote,
            notes: forwardNotes,
            addressMap: waypointAddressMap,
          )
        else
          // 往返模式：去程和返程并排显示
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 去程列表
              Expanded(
                child: _WaypointListSection(
                  title:
                      '${loc.road_trip_route_forward_label}${loc.road_trip_route_waypoints_count(forwardWaypoints.length)}',
                  items: forwardWaypoints,
                  onRemove: onRemoveForward,
                  onReorder: onReorderForward,
                  onTap: onEditForwardNote,
                  notes: forwardNotes,
                  addressMap: waypointAddressMap,
                ),
              ),
              const SizedBox(width: 12),
              // 返程列表
              Expanded(
                child: _WaypointListSection(
                  title:
                      '${loc.road_trip_route_return_label}${loc.road_trip_route_waypoints_count(returnWaypoints.length)}',
                  items: returnWaypoints,
                  onRemove: onRemoveReturn,
                  onReorder: onReorderReturn,
                  onTap: onEditReturnNote,
                  notes: returnNotes,
                  addressMap: waypointAddressMap,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _onAddWaypoint(BuildContext context) async {
    debugPrint('_onAddWaypoint 方法被调用');
    
    if (!context.mounted) {
      debugPrint('Context 未挂载，无法导航');
      return;
    }
    
    final loc = AppLocalizations.of(context)!;
    debugPrint('准备导航到 LocationSearchScreen，往返模式: ${routeType == EventRouteType.roundTrip}');
    
    try {
      // 跳转到 LocationSearchScreen，如果是往返模式，会在页面中显示下拉菜单
      final result = await Navigator.of(context).push<LocationSelectionResult>(
        MaterialPageRoute(
          builder: (context) {
            debugPrint('正在构建 LocationSearchScreen');
            return LocationSearchScreen(
              title: loc.map_select_location_title,
              isRoundTrip: routeType == EventRouteType.roundTrip,
              onLocationSelected: (place) {
                // 单程模式下使用，但往返模式下会直接返回 LocationSelectionResult
                debugPrint('onLocationSelected 被调用（单程模式）');
              },
            );
          },
        ),
      );

      debugPrint('从 LocationSearchScreen 返回，结果: ${result != null}');
      
      if (!context.mounted) {
        debugPrint('Context 在返回后未挂载');
        return;
      }
      
      if (result != null) {
        debugPrint('处理返回结果，isForward: ${result.isForward}');
        if (result.isForward) {
          onAddForward(result.place);
        } else {
          onAddReturn(result.place);
        }
      }
    } catch (e, stackTrace) {
      // 如果导航失败，打印错误（调试用）
      debugPrint('导航到 LocationSearchScreen 失败: $e');
      debugPrint('堆栈跟踪: $stackTrace');
    }
  }
}

class _WaypointListSection extends StatelessWidget {
  const _WaypointListSection({
    required this.title,
    required this.items,
    required this.onRemove,
    this.onReorder,
    this.onTap,
    this.notes,
    this.addressMap,
  });

  final String title;
  final List<LatLng> items;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final ValueChanged<int>? onTap; // 点击编辑备注
  final Map<String, String>? notes; // 备注数据
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
        const SizedBox(height: 6),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '暂无途径点',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else if (onReorder != null)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            onReorder: onReorder!,
            itemBuilder: (context, index) {
              final loc = AppLocalizations.of(context)!;
              final item = items[index];
              final key = '${item.latitude}_${item.longitude}';
              final address = addressMap?[key];
              final note = notes?[key];
              final text = address != null
                  ? address.truncate(maxLength: 20)
                  : loc.road_trip_route_waypoint_label(index + 1); // 显示地址或编号
              // ReorderableListView 需要基于内容的 key，而不是 index
              final itemKey = ValueKey('wp-${item.latitude}-${item.longitude}');
              return Dismissible(
                key: itemKey,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onRemove(index),
                child: ListTile(
                  key: itemKey,
                  leading: const Icon(Icons.drag_handle, size: 20),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${index + 1}. $text',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          note,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onRemove(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  onTap: onTap != null ? () => onTap!(index) : null,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            },
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final loc = AppLocalizations.of(context)!;
              final item = items[index];
              final key = '${item.latitude}_${item.longitude}';
              final address = addressMap?[key];
              final note = notes?[key];
              final text = address != null
                  ? address.truncate(maxLength: 20)
                  : loc.road_trip_route_waypoint_label(index + 1); // 显示地址或编号
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
                  leading: const Icon(Icons.place_outlined, size: 20),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}. $text',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          note,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => onRemove(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  onTap: onTap != null ? () => onTap!(index) : null,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            },
          ),
      ],
    );
  }
}

