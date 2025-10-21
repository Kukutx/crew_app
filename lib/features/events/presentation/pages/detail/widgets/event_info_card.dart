import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/utils/waypoint_formatter.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final VoidCallback onTapLocation;
  final ValueChanged<int>? onWaypointTap;
  final VoidCallback? onAddWaypointTap;
  final VoidCallback? onRouteTypeTap;
  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
    required this.onTapLocation,
    this.onWaypointTap,
    this.onAddWaypointTap,
    this.onRouteTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final waypoints = event.waypoints;
    final routeType = event.isRoundTrip;
    final distanceKm = event.distanceKm;
    final localeTag = Localizations.localeOf(context).toString();
    final feeText = _formatFee(localeTag);
    final addressText =
        event.address?.isNotEmpty == true ? event.address! : event.location;
    final distanceText = distanceKm != null
        ? loc.event_distance_value(
            _formatDistance(distanceKm, localeTag),
          )
        : null;
    final linkColor = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.event_details_title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            const SizedBox(height: 12),
            _detailRow(Icons.calendar_today, loc.event_time_title, timeText),
            _detailRow(Icons.payments, loc.event_fee_title, feeText),
            _detailRow(Icons.people, loc.event_participants_title, participantText),
            InkWell(
              onTap: onTapLocation,
              child: _detailRow(
                Icons.place,
                loc.event_meeting_point_title,
                addressText,
                valueStyle: TextStyle(
                  fontSize: 14,
                  color: linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: linkColor,
                  tooltip: loc.event_copy_address_button,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: addressText));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.event_copy_address_success),
                      ),
                    );
                  },
                ),
              ),
            ),
            _waypointsSection(context, waypoints, loc),
            _routeTypeRow(context, routeType, loc),
            if (distanceText != null)
              _detailRow(
                Icons.straighten,
                loc.event_distance_title,
                distanceText,
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    TextStyle? valueStyle,
    Widget? trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: valueStyle ??
                    const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing,
            ],
          ],
        ),
      );

  Widget _waypointsSection(
    BuildContext context,
    List<String> waypoints,
    AppLocalizations loc,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.alt_route, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_waypoints_title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: _WaypointsTagList(
                      waypoints: waypoints,
                      onTap: onWaypointTap,
                      onAddTap: onAddWaypointTap,
                    ),
                  ),
                  if (waypoints.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        loc.event_waypoints_empty_hint,
                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _routeTypeRow(
    BuildContext context,
    bool? routeType,
    AppLocalizations loc,
  ) {
    final label = _formatRouteTypeLabel(loc, routeType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(routeType == true ? Icons.loop : Icons.trending_flat,
              size: 20, color: Colors.orange),
          const SizedBox(width: 12),
          Text(loc.event_route_type_title, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          OutlinedButton(
            onPressed: onRouteTypeTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRouteTypeLabel(AppLocalizations loc, bool? routeType) {
    if (routeType == null) {
      return '${loc.to_be_announced} ⚙️';
    }
    return routeType
        ? '${loc.event_route_type_round} 🔁'
        : '${loc.event_route_type_one_way} 🚗';
  }

  String _formatTime() {
    final start = event.startTime;
    final end = event.endTime;
    if (start == null) {
      return loc.to_be_announced;
    }
    final startFmt = DateFormat('MM.dd HH:mm').format(start.toLocal());
    if (end == null) {
      return startFmt;
    }
    final endFmt = DateFormat('HH:mm').format(end.toLocal());
    return '$startFmt - $endFmt';
  }

  String _formatFee(String localeTag) {
    if (event.isFree) {
      return loc.event_fee_free;
    }
    final price = event.price;
    if (price == null) {
      return loc.to_be_announced;
    }
    final formatter = NumberFormat.simpleCurrency(locale: localeTag);
    if (price <= 0) {
      return loc.event_fee_free;
    }
    return formatter.format(price);
  }

  String _formatDistance(double kilometers, String localeTag) {
    final formatter = NumberFormat('#,##0.0', localeTag);
    return formatter.format(kilometers);
  }
}

class _WaypointsTagList extends StatefulWidget {
  final List<String> waypoints;
  final ValueChanged<int>? onTap;
  final VoidCallback? onAddTap;

  const _WaypointsTagList({
    required this.waypoints,
    this.onTap,
    this.onAddTap,
  });

  @override
  State<_WaypointsTagList> createState() => _WaypointsTagListState();
}

class _WaypointsTagListState extends State<_WaypointsTagList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List<String>.of(widget.waypoints);
  }

  @override
  void didUpdateWidget(covariant _WaypointsTagList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems(widget.waypoints);
  }

  void _syncItems(List<String> newItems) {
    final listState = _listKey.currentState;
    if (listState == null) {
      _items = List<String>.of(newItems);
      return;
    }

    var index = 0;
    while (index < _items.length && index < newItems.length) {
      final oldItem = _items[index];
      final newItem = newItems[index];
      if (oldItem == newItem) {
        index++;
        continue;
      }
      final newIndexOfOld = newItems.indexOf(oldItem);
      if (newIndexOfOld == -1) {
        final removed = _items.removeAt(index);
        listState.removeItem(
          index,
          (context, animation) => _buildTag(
            context,
            removed,
            animation,
            index: index,
            enableTap: false,
          ),
        );
      } else {
        final inserted = newItems[index];
        _items.insert(index, inserted);
        listState.insertItem(index);
        index++;
      }
    }

    while (_items.length > newItems.length) {
      final removeIndex = _items.length - 1;
      final removed = _items.removeAt(removeIndex);
      listState.removeItem(
        removeIndex,
        (context, animation) => _buildTag(
          context,
          removed,
          animation,
          index: removeIndex,
          enableTap: false,
        ),
      );
    }

    while (_items.length < newItems.length) {
      final insertIndex = _items.length;
      final inserted = newItems[insertIndex];
      _items.insert(insertIndex, inserted);
      listState.insertItem(insertIndex);
    }

    for (var i = 0; i < _items.length; i++) {
      if (_items[i] != newItems[i]) {
        _items[i] = newItems[i];
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final addTap = widget.onAddTap;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: AnimatedList(
              key: _listKey,
              scrollDirection: Axis.horizontal,
              initialItemCount: _items.length,
              itemBuilder: (context, index, animation) => _buildTag(
                context,
                _items[index],
                animation,
                index: index,
              ),
            ),
          ),
          if (addTap != null) ...[
            const SizedBox(width: 6),
            _AddWaypointButton(onTap: addTap),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    String value,
    Animation<double> animation, {
    required int index,
    bool enableTap = true,
  }) {
    final label = formatWaypointLabel(value);
    final tag = InkWell(
      onTap: enableTap && widget.onTap != null ? () => widget.onTap!(index) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
    return SizeTransition(
      sizeFactor: animation,
      axis: Axis.horizontal,
      child: FadeTransition(
        opacity: animation,
        child: tag,
      ),
    );
  }
}

class _AddWaypointButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddWaypointButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: const Icon(Icons.add, size: 18, color: Colors.orange),
      ),
    );
  }
}
