import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/waypoints_sheet.dart';
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
    final memberText = event.memberSummary ?? loc.to_be_announced;
    // 从 waypointSegments 提取途经点名称（暂时使用坐标作为占位符）
    final waypointSegments = event.waypointSegments;
    final displayWaypoints = waypointSegments.isNotEmpty
        ? waypointSegments.map((s) => '${s.latitude.toStringAsFixed(4)}, ${s.longitude.toStringAsFixed(4)}').toList()
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

    final startPoint = event.address?.isNotEmpty == true
        ? event.address!
        : event.location;
    // 从 waypointSegments 获取终点
    final endPoint = event.waypointSegments.isNotEmpty
        ? '${event.waypointSegments.last.latitude.toStringAsFixed(4)}, ${event.waypointSegments.last.longitude.toStringAsFixed(4)}'
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
              context,
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
              loc.event_members_title,
              memberText,
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
                context,
                loc,
                colorScheme.primary,
                detailTitleStyle ?? fallbackDetailTitleStyle,
                valueTextStyle ?? fallbackValueStyle,
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
    BuildContext context,
    AppLocalizations loc,
    Color iconColor,
    TextStyle titleStyle,
    TextStyle valueStyle,
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
          child: Text(
            loc.event_waypoints_title,
            style: titleStyle,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: TextButton(
            onPressed: () {
              showWaypointsSheet(context, event, loc);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              loc.event_waypoints_view_button,
              textAlign: TextAlign.right,
              style: valueStyle.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _timeRow(
    BuildContext context,
    String startText,
    String endText, {
    required Color iconColor,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasTime = event.startTime != null && event.endTime != null;
    final isSameDay = hasTime &&
        event.startTime!.toLocal().year == event.endTime!.toLocal().year &&
        event.startTime!.toLocal().month == event.endTime!.toLocal().month &&
        event.startTime!.toLocal().day == event.endTime!.toLocal().day;

    return Padding(
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
                const SizedBox(height: 10),
                if (hasTime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 14,
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loc.event_start_time_label,
                          style: valueStyle.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          startText,
                          style: valueStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: iconColor.withValues(alpha: 0.6),
                          ),
                        ),
                        Icon(
                          Icons.stop,
                          size: 14,
                          color: iconColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loc.event_end_time_label,
                          style: valueStyle.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            endText,
                            style: valueStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      startText,
                      style: valueStyle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
