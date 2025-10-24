import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  static const List<String> _defaultWaypoints = [
    '柏林大教堂',
    '御林广场',
    '波茨坦广场',
  ];
  static const bool _defaultIsRoundTrip = true;
  static const TextStyle _valueTextStyle =
      TextStyle(fontSize: 14, color: Colors.black54);

  final Event event;
  final AppLocalizations loc;
  final VoidCallback onTapLocation;
  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
    required this.onTapLocation,
  });

  @override
  Widget build(BuildContext context) {
    final startTimeText = _formatStartTime();
    final endTimeText = _formatEndTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final waypoints = event.waypoints;
    final displayWaypoints =
        waypoints.isNotEmpty ? waypoints : _defaultWaypoints;
    final routeType = event.isRoundTrip;
    final displayRouteType = routeType ?? _defaultIsRoundTrip;
    final localeTag = Localizations.localeOf(context).toString();
    final feeText = _formatFee(localeTag);
    final addressText =
        event.address?.isNotEmpty == true ? event.address! : event.location;
    final linkColor = Theme.of(context).colorScheme.primary;
    final hostDisclaimer = event.hostDisclaimer;
    final hasHostDisclaimer =
        hostDisclaimer != null && hostDisclaimer.trim().isNotEmpty;
    final tooltipMessage = hasHostDisclaimer ? hostDisclaimer!.trim() : null;
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
            _timeRow(startTimeText, endTimeText),
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
            if (displayWaypoints.isNotEmpty)
              _waypointsRow(displayWaypoints, loc),
            _detailRow(
              displayRouteType ? Icons.loop : Icons.trending_flat,
              loc.event_route_type_title,
              displayRouteType
                  ? loc.event_route_type_round
                  : loc.event_route_type_one_way,
            ),
            _detailRow(
              Icons.shield_outlined,
              loc.event_host_disclaimer_title,
              hasHostDisclaimer
                  ? loc.event_host_disclaimer_link
                  : loc.event_host_disclaimer_empty,
              valueStyle:
                  hasHostDisclaimer ? null : _valueTextStyle,
              valueWidget: hasHostDisclaimer
                  ? Tooltip(
                      message: tooltipMessage!,
                      triggerMode: TooltipTriggerMode.tap,
                      child: Text(
                        loc.event_host_disclaimer_link,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: linkColor,
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor,
                        ),
                      ),
                    )
                  : null,
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
    Widget? valueWidget,
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
              child: valueWidget ??
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle ?? _valueTextStyle,
                  ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              trailing,
            ],
          ],
        ),
      );

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

  Widget _timeRow(String startText, String endText) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_time_title, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.event_start_time_label}: $startText',
                    style: _valueTextStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.event_end_time_label}: $endText',
                    style: _valueTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  String _formatStartTime() {
    final start = event.startTime;
    if (start == null) {
      return loc.to_be_announced;
    }
    return DateFormat('MM.dd HH:mm').format(start.toLocal());
  }

  String _formatEndTime() {
    final end = event.endTime;
    if (end == null) {
      return loc.to_be_announced;
    }
    final endLocal = end.toLocal();
    final startLocal = event.startTime?.toLocal();
    final sameDay = startLocal != null &&
        startLocal.year == endLocal.year &&
        startLocal.month == endLocal.month &&
        startLocal.day == endLocal.day;
    if (sameDay) {
      return DateFormat('HH:mm').format(endLocal);
    }
    return DateFormat('MM.dd HH:mm').format(endLocal);
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

}
