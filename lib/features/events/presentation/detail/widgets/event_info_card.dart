import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventInfoCard extends StatelessWidget {
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
    final timeText = _formatTime();
    final participantText = event.participantSummary ?? loc.to_be_announced;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.event_details_title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20),
            const SizedBox(height: 12),
            _detailRow(
              context,
              Icons.calendar_today,
              loc.event_time_title,
              timeText,
            ),
            _detailRow(
              context,
              Icons.people,
              loc.event_participants_title,
              participantText,
            ),
            InkWell(
              onTap: onTapLocation,
              child: _detailRow(
                context,
                Icons.place,
                loc.event_meeting_point_title,
                event.address?.isNotEmpty == true ? event.address! : event.location,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
}
