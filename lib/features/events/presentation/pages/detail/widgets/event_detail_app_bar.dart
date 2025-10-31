import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final Event event;

  const EventDetailAppBar({
    super.key,
    required this.onBack,
    required this.onShare,
    required this.onMore,
    required this.event,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final statusBadge = _buildStatusBadge(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      title: statusBadge,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: onMore,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: const SizedBox.shrink(),
    );
  }

  Widget? _buildStatusBadge(BuildContext context) {
    final status = event.status;
    // if (status == null) {
    //   return null;
    // }

    final loc = AppLocalizations.of(context)!;
    final label = _localizedStatusLabel(loc, status ?? EventStatus.reviewing);

    final colorScheme = Theme.of(context).colorScheme;
    final visuals = _statusVisualStyle(colorScheme, status ?? EventStatus.reviewing);
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
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
      child: Text(label, style: textStyle),
    );
  }

  String _localizedStatusLabel(AppLocalizations loc, EventStatus status) {
    
    switch (status) {
      case EventStatus.reviewing:
        return loc.event_status_reviewing;
      case EventStatus.recruiting:
        return loc.event_status_recruiting;
      case EventStatus.ongoing:
        return loc.event_status_ongoing;
      case EventStatus.ended:
        return loc.event_status_ended;
    }
  }

  _StatusVisualStyle _statusVisualStyle(
    ColorScheme colorScheme,
    EventStatus status,
  ) {
    switch (status) {
      case EventStatus.reviewing:
        return _StatusVisualStyle(
          background: colorScheme.secondaryContainer.withOpacity(0.9),
          foreground: colorScheme.onSecondaryContainer,
          border: colorScheme.secondary.withOpacity(0.45),
        );
      case EventStatus.recruiting:
        return _StatusVisualStyle(
          background: colorScheme.primaryContainer.withOpacity(0.9),
          foreground: colorScheme.onPrimaryContainer,
          border: colorScheme.primary.withOpacity(0.45),
        );
      case EventStatus.ongoing:
        return _StatusVisualStyle(
          background: colorScheme.tertiaryContainer.withOpacity(0.9),
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withOpacity(0.45),
        );
      case EventStatus.ended:
        return _StatusVisualStyle(
          background: colorScheme.errorContainer.withOpacity(0.9),
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withOpacity(0.45),
        );
    }
  }
}

class _StatusVisualStyle {
  const _StatusVisualStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
