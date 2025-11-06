import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventMeetingPointCard extends StatelessWidget {
  final AppLocalizations loc;
  final String meetingPoint;
  final VoidCallback onViewOnMap;

  const EventMeetingPointCard({
    super.key,
    required this.loc,
    required this.meetingPoint,
    required this.onViewOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.w700,
    );
    final meetingPointStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );
    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainerHighest,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              loc.event_meeting_point_title,
              style:
                  titleStyle ??
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _MeetingPointButton(
              meetingPoint: meetingPoint,
              onTap: onViewOnMap,
              colorScheme: colorScheme,
              meetingPointStyle: meetingPointStyle,
              tooltip: loc.event_meeting_point_view_button,
            ),
            const SizedBox(height: 12),
            Text(
              loc.event_meeting_point_hint,
              style:
                  helperStyle ??
                  TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: meetingPoint));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.event_copy_address_success)),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(loc.event_copy_address_button),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingPointButton extends StatelessWidget {
  final String meetingPoint;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextStyle? meetingPointStyle;
  final String tooltip;

  const _MeetingPointButton({
    required this.meetingPoint,
    required this.onTap,
    required this.colorScheme,
    required this.meetingPointStyle,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        meetingPointStyle ??
        TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        );

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    meetingPoint.truncate(maxLength: 30),
                    style: effectiveStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
