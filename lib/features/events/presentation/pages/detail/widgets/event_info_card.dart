import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/theme/app_colors.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
  const EventInfoCard({
    super.key,
    required this.event,
    required this.loc,
    required this.onTapLocation,
    required this.onTapCostCalculator,
  });

  final Event event;
  final AppLocalizations loc;
  final VoidCallback onTapLocation;
  final VoidCallback onTapCostCalculator;

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final addressText =
        event.address?.isNotEmpty == true ? event.address! : event.location;
    final localeTag = Localizations.localeOf(context).toString();
    final distance = event.distanceKm;
    final distanceText = distance != null
        ? loc.event_distance_value(_formatDistance(distance, localeTag))
        : null;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.event_details_title, style: AppTextStyles.subtitle),
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.calendar_today_rounded,
              title: loc.event_time_title,
              value: timeText,
            ),
            _DetailRow(
              icon: Icons.people_outline,
              title: loc.event_participants_title,
              value: participantText,
            ),
            _DetailRow(
              icon: Icons.place_outlined,
              title: loc.event_meeting_point_title,
              value: addressText,
              onTap: onTapLocation,
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: addressText));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.event_copy_address_success)),
                  );
                },
              ),
            ),
            if (event.waypoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              _WaypointList(waypoints: event.waypoints, loc: loc),
            ],
            if (event.isRoundTrip != null)
              _DetailRow(
                icon: event.isRoundTrip! ? Icons.loop : Icons.trending_flat,
                title: loc.event_route_type_title,
                value: event.isRoundTrip!
                    ? loc.event_route_type_round
                    : loc.event_route_type_one_way,
              ),
            if (distanceText != null)
              _DetailRow(
                icon: Icons.straighten,
                title: loc.event_distance_title,
                value: distanceText,
              ),
            const SizedBox(height: 16),
            _CalculatorTile(onTap: onTapCostCalculator, loc: loc),
          ],
        ),
      ),
    );
  }

  String _formatTime() {
    final start = event.startTime;
    final end = event.endTime;
    if (start == null) return loc.to_be_announced;
    final formatter = DateFormat('MMM d · HH:mm');
    final startLabel = formatter.format(start.toLocal());
    if (end == null) return startLabel;
    final endLabel = DateFormat('HH:mm').format(end.toLocal());
    return '$startLabel - $endLabel';
  }

  String _formatDistance(double distanceKm, String localeTag) {
    if (localeTag.startsWith('en')) {
      final miles = distanceKm * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.chip),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: content,
            )
          : content,
    );
  }
}

class _WaypointList extends StatelessWidget {
  const _WaypointList({required this.waypoints, required this.loc});

  final List<String> waypoints;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.event_waypoints_title, style: AppTextStyles.chip),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: waypoints
              .map(
                (point) => Chip(
                  label: Text(point),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _CalculatorTile extends StatelessWidget {
  const _CalculatorTile({required this.onTap, required this.loc});

  final VoidCallback onTap;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calculate_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc.event_cost_calculator_title,
                      style: AppTextStyles.subtitle),
                  const SizedBox(height: 4),
                  Text(
                    loc.event_cost_calculator_description,
                    style: AppTextStyles.bodyMuted,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
