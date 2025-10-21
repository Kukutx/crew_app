import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/map/event_waypoint_picker_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatefulWidget {
  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
    required this.onTapLocation,
  });

  final Event event;
  final AppLocalizations loc;
  final VoidCallback onTapLocation;

  @override
  State<EventInfoCard> createState() => _EventInfoCardState();
}

class _EventInfoCardState extends State<EventInfoCard> {
  late bool _isRoundTrip;
  late List<String> _waypoints;

  @override
  void initState() {
    super.initState();
    _syncFromEvent();
  }

  @override
  void didUpdateWidget(covariant EventInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _syncFromEvent();
    }
  }

  void _syncFromEvent() {
    _isRoundTrip =
        widget.event.isRoundTrip ?? widget.event.waypoints.isNotEmpty;
    _waypoints = List<String>.from(widget.event.waypoints);
  }

  Future<void> _openRouteEditor() async {
    final result = await showModalBottomSheet<_RouteEditorResult>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _RouteEditorSheet(
        initialIsRoundTrip: _isRoundTrip,
        initialWaypoints: _waypoints,
        onPickWaypoint: _pickWaypoint,
      ),
    );
    if (result == null) {
      return;
    }
    setState(() {
      _isRoundTrip = result.isRoundTrip;
      _waypoints = result.waypoints;
    });
  }

  Future<String?> _pickWaypoint() {
    final event = widget.event;
    final initial = LatLng(event.latitude, event.longitude);
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => EventWaypointPickerPage(initialPosition: initial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = widget.loc;
    final timeText = _formatTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
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
    final theme = Theme.of(context);
    final linkColor = theme.colorScheme.primary;
    final showWaypoints = _isRoundTrip && _waypoints.isNotEmpty;
    final showRouteType = _isRoundTrip;
    final showManageButton =
        (event.isRoundTrip ?? false) || showRouteType || _waypoints.isNotEmpty;

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
            _detailRow(
              Icons.people,
              loc.event_participants_title,
              participantText,
            ),
            InkWell(
              onTap: widget.onTapLocation,
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
            if (showWaypoints)
              GestureDetector(
                onTap: _openRouteEditor,
                child: _waypointsRow(_waypoints, loc, theme),
              ),
            if (showRouteType)
              InkWell(
                onTap: _openRouteEditor,
                child: _detailRow(
                  Icons.loop,
                  loc.event_route_type_title,
                  loc.event_route_type_round,
                ),
              ),
            if (distanceText != null)
              _detailRow(
                Icons.straighten,
                loc.event_distance_title,
                distanceText,
              ),
            if (showManageButton) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _openRouteEditor,
                  icon: const Icon(Icons.edit_road),
                  label: Text(loc.event_route_manage_button),
                ),
              ),
            ],
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

  Widget _waypointsRow(
    List<String> waypoints,
    AppLocalizations loc,
    ThemeData theme,
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
                  Text(loc.event_waypoints_title,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: waypoints
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(point),
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.08),
                                labelStyle: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  String _formatTime() {
    final start = widget.event.startTime;
    final end = widget.event.endTime;
    if (start == null) {
      return widget.loc.to_be_announced;
    }
    final startFmt = DateFormat('MM.dd HH:mm').format(start.toLocal());
    if (end == null) {
      return startFmt;
    }
    final endFmt = DateFormat('HH:mm').format(end.toLocal());
    return '$startFmt - $endFmt';
  }

  String _formatFee(String localeTag) {
    final loc = widget.loc;
    if (widget.event.isFree) {
      return loc.event_fee_free;
    }
    final price = widget.event.price;
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

class _RouteEditorResult {
  const _RouteEditorResult({
    required this.isRoundTrip,
    required this.waypoints,
  });

  final bool isRoundTrip;
  final List<String> waypoints;
}

class _RouteEditorSheet extends StatefulWidget {
  const _RouteEditorSheet({
    required this.initialIsRoundTrip,
    required this.initialWaypoints,
    required this.onPickWaypoint,
  });

  final bool initialIsRoundTrip;
  final List<String> initialWaypoints;
  final Future<String?> Function() onPickWaypoint;

  @override
  State<_RouteEditorSheet> createState() => _RouteEditorSheetState();
}

class _RouteEditorSheetState extends State<_RouteEditorSheet> {
  late bool _roundTrip;
  late List<String> _waypoints;
  bool _addingWaypoint = false;

  @override
  void initState() {
    super.initState();
    _roundTrip = widget.initialIsRoundTrip;
    _waypoints = List<String>.from(widget.initialWaypoints);
  }

  Future<void> _handleAddWaypoint() async {
    if (_addingWaypoint) {
      return;
    }
    setState(() => _addingWaypoint = true);
    try {
      final label = await widget.onPickWaypoint();
      if (!mounted) {
        return;
      }
      if (label != null && label.trim().isNotEmpty) {
        setState(() => _waypoints.add(label.trim()));
      }
    } finally {
      if (mounted) {
        setState(() => _addingWaypoint = false);
      }
    }
  }

  void _handleRemove(int index) {
    setState(() => _waypoints.removeAt(index));
  }

  void _handleSave() {
    Navigator.of(context).pop(
      _RouteEditorResult(
        isRoundTrip: _roundTrip,
        waypoints: List<String>.unmodifiable(_waypoints),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: media.viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              loc.event_waypoint_editor_title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              loc.event_route_type_title,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  icon: const Icon(Icons.loop),
                  label: Text(loc.event_route_type_round),
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: const Icon(Icons.trending_flat),
                  label: Text(loc.event_route_type_one_way),
                ),
              ],
              selected: <bool>{_roundTrip},
              onSelectionChanged: (values) {
                setState(() => _roundTrip = values.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              loc.event_waypoints_title,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (_waypoints.isEmpty)
              Text(
                loc.event_waypoint_editor_empty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else ...[
              Text(
                loc.event_waypoint_editor_swipe_hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _waypoints.length,
                  itemBuilder: (context, index) {
                    final label = _waypoints[index];
                    return Dismissible(
                      key: ValueKey('${label}_$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _handleRemove(index),
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.16),
                              child: Text(
                                '${index + 1}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                label,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _addingWaypoint ? null : _handleAddWaypoint,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(loc.event_waypoint_editor_add_button),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.action_cancel),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _handleSave,
                  child: Text(loc.action_apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
