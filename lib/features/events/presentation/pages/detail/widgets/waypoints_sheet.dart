import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> showWaypointsSheet(
  BuildContext context,
  Event event,
  AppLocalizations loc,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _WaypointsSheet(event: event, loc: loc),
  );
}

class _WaypointsSheet extends StatelessWidget {
  const _WaypointsSheet({
    required this.event,
    required this.loc,
  });

  final Event event;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRoundTrip = event.isRoundTrip ?? false;
    final waypointSegments = event.waypointSegments;

    // 分组途径点：往返路线按方向分组，单程路线全部显示
    final forwardWaypointsList = waypointSegments
        .where((s) => s.direction == EventWaypointDirection.forward)
        .toList();
    forwardWaypointsList.sort((a, b) => a.seq.compareTo(b.seq));
    final forwardWaypoints = forwardWaypointsList;
    
    final returnWaypointsList = isRoundTrip
        ? waypointSegments
            .where((s) => s.direction == EventWaypointDirection.returnTrip)
            .toList()
        : <EventWaypointResponse>[];
    if (returnWaypointsList.isNotEmpty) {
      returnWaypointsList.sort((a, b) => a.seq.compareTo(b.seq));
    }
    final returnWaypoints = returnWaypointsList;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // 拖拽手柄
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.alt_route,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.event_waypoints_title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 内容区域
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // 路线类型提示
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRoundTrip ? Icons.loop : Icons.trending_flat,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRoundTrip
                                ? loc.event_route_type_round
                                : loc.event_route_type_one_way,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 去程途径点
                    if (forwardWaypoints.isNotEmpty) ...[
                      _WaypointSection(
                        title: isRoundTrip
                            ? '${loc.road_trip_route_forward_label}程途径点'
                            : loc.event_waypoints_title,
                        waypoints: forwardWaypoints,
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                      if (returnWaypoints.isNotEmpty) const SizedBox(height: 24),
                    ],
                    // 返程途径点（仅往返路线显示）
                    if (returnWaypoints.isNotEmpty)
                      _WaypointSection(
                        title: '${loc.road_trip_route_return_label}程途径点',
                        waypoints: returnWaypoints,
                        colorScheme: colorScheme,
                        theme: theme,
                      ),
                    // 空状态
                    if (waypointSegments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '暂无途径点',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaypointSection extends StatelessWidget {
  const _WaypointSection({
    required this.title,
    required this.waypoints,
    required this.colorScheme,
    required this.theme,
  });

  final String title;
  final List<EventWaypointResponse> waypoints;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...waypoints.asMap().entries.map((entry) {
          final index = entry.key;
          final waypoint = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 序号
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 坐标信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${waypoint.latitude.toStringAsFixed(6)}, ${waypoint.longitude.toStringAsFixed(6)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (waypoint.note != null && waypoint.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          waypoint.note!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

