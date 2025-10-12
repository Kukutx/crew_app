import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final VoidCallback onTapLocation;
  final VoidCallback onTapCostCalculator;

  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
    required this.onTapLocation,
    required this.onTapCostCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final waypoints = event.waypoints;
    final routeType = event.isRoundTrip;
    final distanceKm = event.distanceKm;
    final localeTag = Localizations.localeOf(context).toString();
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
            _detailRow(Icons.people, loc.event_participants_title, participantText),
            _meetingPointRow(context, addressText, linkColor),
            if (waypoints.isNotEmpty) _waypointsRow(waypoints, loc),
            if (routeType != null)
              _detailRow(
                routeType ? Icons.loop : Icons.trending_flat,
                loc.event_route_type_title,
                routeType ? loc.event_route_type_round : loc.event_route_type_one_way,
              ),
            if (distanceText != null)
              _detailRow(
                Icons.straighten,
                loc.event_distance_title,
                distanceText,
              ),
            const SizedBox(height: 8),
            _calculatorRow(context),
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
          ],
        ),
      );

  Widget _meetingPointRow(
    BuildContext context,
    String addressText,
    Color linkColor,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.place, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_meeting_point_title,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onTapLocation,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        addressText,
                        style: TextStyle(
                          fontSize: 14,
                          color: linkColor,
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _CopyAddressButton(
              addressText: addressText,
              onCopied: () => _showCopySuccess(context),
              label: loc.event_copy_address_button,
            ),
          ],
        ),
      );

  void _showCopySuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.event_copy_address_success),
      ),
    );
  }

  Widget _waypointsRow(List<String> waypoints, AppLocalizations loc) => Padding(
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: waypoints
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(point),
                                backgroundColor: Colors.orange.shade50,
                                labelStyle:
                                    const TextStyle(fontSize: 13, color: Colors.black87),
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

  Widget _calculatorRow(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calculate_outlined, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.event_cost_calculator_title,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.event_cost_calculator_description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: onTapCostCalculator,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                minimumSize: const Size(0, 0),
              ),
              child: Text(
                loc.event_cost_calculator_button,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

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

  String _formatDistance(double kilometers, String localeTag) {
    final formatter = NumberFormat('#,##0.0', localeTag);
    return formatter.format(kilometers);
  }
}

class _CopyAddressButton extends StatelessWidget {
  final String addressText;
  final VoidCallback onCopied;
  final String label;

  const _CopyAddressButton({
    required this.addressText,
    required this.onCopied,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: addressText));
        if (!context.mounted) {
          return;
        }
        onCopied();
      },
      icon: const Icon(Icons.copy, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
