import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
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
  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
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

    final startPoint = event.address?.isNotEmpty == true
        ? event.address!
        : event.location;
    final endPoint = event.waypoints.isNotEmpty
        ? event.waypoints.last
        : event.location;
    final statusChip = _buildStatusChip(
      loc: loc,
      theme: theme,
      colorScheme: colorScheme,
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
            if (statusChip != null) ...[
              const SizedBox(height: 12),
              statusChip,
            ],
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

  Widget? _buildStatusChip({
    required AppLocalizations loc,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final statusType = event.lifecycleStatus;
    final statusLabel = statusType != null
        ? _localizedStatusLabel(loc, statusType)
        : event.status?.trim();
    if (statusLabel == null || statusLabel.isEmpty) {
      return null;
    }

    final visuals = _statusVisualStyle(colorScheme, statusType);
    final textStyle = theme.textTheme.labelMedium?.copyWith(
          color: visuals.foreground,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          color: visuals.foreground,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: visuals.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visuals.border, width: 1),
      ),
      child: Text(statusLabel, style: textStyle),
    );
  }

  String _localizedStatusLabel(
    AppLocalizations loc,
    EventLifecycleStatus status,
  ) {
    switch (status) {
      case EventLifecycleStatus.reviewing:
        return loc.event_status_reviewing;
      case EventLifecycleStatus.recruiting:
        return loc.event_status_recruiting;
      case EventLifecycleStatus.ongoing:
        return loc.event_status_ongoing;
      case EventLifecycleStatus.ended:
        return loc.event_status_ended;
    }
  }

  _EventStatusVisualStyle _statusVisualStyle(
    ColorScheme colorScheme,
    EventLifecycleStatus? status,
  ) {
    switch (status) {
      case EventLifecycleStatus.reviewing:
        return _EventStatusVisualStyle(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
          border: colorScheme.secondary.withOpacity(0.6),
        );
      case EventLifecycleStatus.recruiting:
        return _EventStatusVisualStyle(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          border: colorScheme.primary.withOpacity(0.6),
        );
      case EventLifecycleStatus.ongoing:
        return _EventStatusVisualStyle(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withOpacity(0.6),
        );
      case EventLifecycleStatus.ended:
        return _EventStatusVisualStyle(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withOpacity(0.6),
        );
      case null:
        return _EventStatusVisualStyle(
          background: colorScheme.surfaceVariant,
          foreground: colorScheme.onSurfaceVariant,
          border: colorScheme.outline.withOpacity(0.4),
        );
    }
  }

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

class _EventStatusVisualStyle {
  const _EventStatusVisualStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
