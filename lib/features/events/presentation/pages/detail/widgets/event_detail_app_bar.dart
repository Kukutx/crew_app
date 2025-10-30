import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final Event event;
  final AppLocalizations loc;

  const EventDetailAppBar({
    super.key,
    required this.onBack,
    required this.onShare,
    required this.onMore,
    required this.event,
    required this.loc,
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
    final rawStatus = event.status?.trim();
    if (rawStatus == null || rawStatus.isEmpty) {
      return null;
    }

    final detected = _detectStatus(rawStatus);
    final label = detected != null
        ? _localizedStatusLabel(detected)
        : rawStatus;
    if (label.isEmpty) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visuals = _statusVisualStyle(colorScheme, detected);
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

  _EventStatus? _detectStatus(String status) {
    final trimmed = status.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final lower = trimmed.toLowerCase();

    bool matchesChinese(String keyword) => trimmed.contains(keyword);
    bool matchesEnglish(Iterable<String> keywords) =>
        keywords.any((keyword) => lower.contains(keyword));

    if (matchesChinese('审核') || matchesEnglish(['review'])) {
      return _EventStatus.reviewing;
    }
    if (matchesChinese('招募') || matchesEnglish(['recruit', 'signup'])) {
      return _EventStatus.recruiting;
    }
    if (matchesChinese('进行') || matchesEnglish(['ongoing', 'progress', 'running', 'active'])) {
      return _EventStatus.ongoing;
    }
    if (matchesChinese('结束') ||
        matchesEnglish(['ended', 'finish', 'finished', 'complete', 'closed', 'done'])) {
      return _EventStatus.ended;
    }
    return null;
  }

  String _localizedStatusLabel(_EventStatus status) {
    switch (status) {
      case _EventStatus.reviewing:
        return loc.event_status_reviewing;
      case _EventStatus.recruiting:
        return loc.event_status_recruiting;
      case _EventStatus.ongoing:
        return loc.event_status_ongoing;
      case _EventStatus.ended:
        return loc.event_status_ended;
    }
  }

  _StatusVisualStyle _statusVisualStyle(
    ColorScheme colorScheme,
    _EventStatus? status,
  ) {
    switch (status) {
      case _EventStatus.reviewing:
        return _StatusVisualStyle(
          background: colorScheme.secondaryContainer.withOpacity(0.9),
          foreground: colorScheme.onSecondaryContainer,
          border: colorScheme.secondary.withOpacity(0.45),
        );
      case _EventStatus.recruiting:
        return _StatusVisualStyle(
          background: colorScheme.primaryContainer.withOpacity(0.9),
          foreground: colorScheme.onPrimaryContainer,
          border: colorScheme.primary.withOpacity(0.45),
        );
      case _EventStatus.ongoing:
        return _StatusVisualStyle(
          background: colorScheme.tertiaryContainer.withOpacity(0.9),
          foreground: colorScheme.onTertiaryContainer,
          border: colorScheme.tertiary.withOpacity(0.45),
        );
      case _EventStatus.ended:
        return _StatusVisualStyle(
          background: colorScheme.errorContainer.withOpacity(0.9),
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error.withOpacity(0.45),
        );
      case null:
        return _StatusVisualStyle(
          background: Colors.black.withOpacity(0.45),
          foreground: Colors.white,
          border: Colors.white24,
        );
    }
  }
}

enum _EventStatus { reviewing, recruiting, ongoing, ended }

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
