import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

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
            _detailRow(
              Icons.calendar_today,
              loc.event_time_title,
              event.formattedStartTime(loc.localeName) ?? loc.to_be_announced,
            ),
            _detailRow(
              Icons.people,
              loc.event_participants_title,
              event.participantsDisplayText ?? loc.to_be_announced,
            ),
            InkWell(
              onTap: onTapLocation,
              child: _detailRow(
                Icons.place,
                loc.event_meeting_point_title,
                event.location,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) => Padding(
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
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      );
}
