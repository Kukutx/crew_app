import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  static const List<String> _defaultWaypoints = ['柏林大教堂', '御林广场', '波茨坦广场'];
  static const bool _defaultIsRoundTrip = true;

  final Event event;
  final AppLocalizations loc;
  const EventInfoCard({super.key, required this.event, required this.loc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final startTimeText = _formatStartTime();
    final endTimeText = _formatEndTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final waypoints = event.waypoints;
    final displayWaypoints = waypoints.isNotEmpty
        ? waypoints
        : _defaultWaypoints;
    final routeType = event.isRoundTrip;
    final displayRouteType = routeType ?? _defaultIsRoundTrip;
    final localeTag = Localizations.localeOf(context).toString();
    final feeText = _formatFee(localeTag);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      height: 1.3,
      letterSpacing: -0.2,
    );
    final detailTitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.3,
      letterSpacing: 0,
    );
    final fallbackDetailTitleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      height: 1.3,
      letterSpacing: 0,
    );
    final valueTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0,
    );
    final fallbackValueStyle = TextStyle(
      fontSize: 14,
      color: colorScheme.onSurfaceVariant,
      height: 1.4,
      letterSpacing: 0,
    );
    final chipBackground = colorScheme.primaryContainer;
    final chipTextColor = colorScheme.onPrimaryContainer;
    final chipBorderColor = colorScheme.primary.withValues(alpha: 0.4);
    final chipTextStyle = theme.textTheme.labelMedium?.copyWith(
      color: chipTextColor,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      height: 1.3,
      letterSpacing: 0,
    );
    final fallbackChipTextStyle = TextStyle(
      fontSize: 12,
      color: chipTextColor,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: 0,
    );

    final startPoint = event.address?.isNotEmpty == true
        ? event.address!
        : event.location;
    final endPoint = event.waypoints.isNotEmpty
        ? event.waypoints.last
        : event.location;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.surfaceContainerHighest,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.event_details_title,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
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
            _detailRow(
              Icons.trip_origin,
              loc.event_route_start_label,
              startPoint,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
            ),
            _detailRow(
              Icons.flag,
              loc.event_route_end_label,
              endPoint,
              iconColor: colorScheme.primary,
              titleStyle: detailTitleStyle ?? fallbackDetailTitleStyle,
              valueStyle: valueTextStyle ?? fallbackValueStyle,
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
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 18,
            color: iconColor.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: titleStyle,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: valueStyle,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
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
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.alt_route,
            size: 18,
            color: iconColor.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.event_waypoints_title, style: titleStyle),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: waypoints
                    .map(
                      (point) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: chipBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: chipBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          point,
                          style: chipTextStyle,
                        ),
                      ),
                    )
                    .toList(growable: false),
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
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.calendar_today,
            size: 18,
            color: iconColor.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.event_time_title, style: titleStyle),
              const SizedBox(height: 6),
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
    final sameDay =
        startLocal != null &&
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
