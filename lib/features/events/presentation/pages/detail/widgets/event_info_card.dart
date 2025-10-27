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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
    final linkColor = colorScheme.primary;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );
    final detailTitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final fallbackDetailTitleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
    final valueTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final fallbackValueStyle = TextStyle(
      fontSize: 14,
      color: colorScheme.onSurfaceVariant,
    );
    final linkTextStyle = valueTextStyle?.copyWith(
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    );
    final fallbackLinkStyle = TextStyle(
      fontSize: 14,
      color: linkColor,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    );
    final chipBackground = colorScheme.primaryContainer;
    final chipTextColor = colorScheme.onPrimaryContainer;
    final chipBorderColor = colorScheme.primary.withOpacity(0.4);
    final chipTextStyle = theme.textTheme.labelMedium?.copyWith(
      color: chipTextColor,
      fontWeight: FontWeight.w600,
    );
    final fallbackChipTextStyle = TextStyle(
      fontSize: 13,
      color: chipTextColor,
      fontWeight: FontWeight.w600,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surfaceVariant,
      shadowColor: Colors.black.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.event_details_title,
              style: titleStyle ??
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(
              height: 24,
              color: colorScheme.outline.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            _timeRow(
              startTimeText,
              endTimeText,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
            ),
            _detailRow(
              Icons.payments,
              loc.event_fee_title,
              feeText,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
            ),
            _detailRow(
              Icons.people,
              loc.event_participants_title,
              participantText,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
            ),
            InkWell(
              onTap: onTapLocation,
              child: _detailRow(
                Icons.place,
                loc.event_meeting_point_title,
                addressText,
                iconColor: colorScheme.primary,
                titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
                valueStyle: linkTextStyle ?? fallbackLinkStyle,
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
              _waypointsRow(
                displayWaypoints,
                loc,
                colorScheme.primary,
                detailTitleStyle ?? fallbackDetailTitleStyle,
                chipBackground,
                chipBorderColor,
                chipTextStyle ?? fallbackChipTextStyle,
              ),
            _detailRow(
              displayRouteType ? Icons.loop : Icons.trending_flat,
              loc.event_route_type_title,
              displayRouteType
                  ? loc.event_route_type_round
                  : loc.event_route_type_one_way,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
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
    required Color iconColor,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    Widget? trailing,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Text(title, style: titleStyle),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: valueStyle,
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
    Color iconColor,
    TextStyle titleStyle,
    Color chipBackground,
    Color chipBorderColor,
    TextStyle chipTextStyle,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.alt_route, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_waypoints_title, style: titleStyle),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: waypoints
                          .map(
                            (point) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(point, style: chipTextStyle),
                                backgroundColor: chipBackground,
                                side: BorderSide(color: chipBorderColor),
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

  Widget _timeRow(
    String startText,
    String endText, {
    required Color iconColor,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.calendar_today, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_time_title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.event_start_time_label}: $startText',
                    style: valueStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.event_end_time_label}: $endText',
                    style: valueStyle,
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
