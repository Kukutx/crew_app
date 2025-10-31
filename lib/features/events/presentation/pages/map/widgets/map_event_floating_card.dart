import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MapEventFloatingCard extends StatelessWidget {
  const MapEventFloatingCard({
    super.key,
    this.event,
    this.title,
    this.timeLabel,
    this.location,
    this.imageUrl,
    this.primaryAction,
    this.isFavorite,
    this.onClose,
    this.onTap,
    this.onFavorite,
    this.onRegister,
  });

  final Event? event;
  final String? title;
  final String? timeLabel;
  final String? location;
  final String? imageUrl;
  final Widget? primaryAction;
  final bool? isFavorite;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final event = this.event;
    final imageUrl = this.imageUrl ?? event?.firstAvailableImageUrl;
    final startTime = event?.startTime;
    final resolvedTimeLabel =
        timeLabel ??
        (startTime != null
            ? DateFormat('MM.dd HH:mm').format(startTime.toLocal())
            : (event != null ? loc.to_be_announced : null));
    final resolvedTitle = title ?? event?.title ?? '';
    final resolvedLocation = location ?? event?.location;
    final resolvedIsFavorite = isFavorite ?? event?.isFavorite ?? false;
    final participantSummary = event?.participantSummary ?? loc.to_be_announced;

    final actionButton =
        primaryAction ??
        (event != null && onRegister != null
            ? FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onRegister,
                child: Text(
                  loc.action_register_now,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              )
            : null);

    final trailingActions = [
      if (onFavorite != null)
        IconButton(
          onPressed: onFavorite,
          visualDensity: VisualDensity.compact,
          icon: Icon(resolvedIsFavorite ? Icons.star : Icons.star_border),
        ),
      if (onClose != null)
        IconButton(
          onPressed: onClose,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.close),
        ),
    ];

    Widget? footer;
    if (event != null) {
      footer = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _smallChip(context, loc.registration_open),
          const SizedBox(width: 6),
          Icon(Icons.groups, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              participantSummary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (actionButton != null) ...[const SizedBox(width: 8), actionButton],
        ],
      );
    } else if (actionButton != null) {
      footer = Row(children: [const Spacer(), actionButton]);
    }

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(0.9)),
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => ColoredBox(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: Icon(
                                      Icons.error,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            : ColoredBox(
                                color: colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  resolvedTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              ...trailingActions,
                            ],
                          ),
                          if (resolvedTimeLabel != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              resolvedTimeLabel,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (resolvedLocation != null &&
                              resolvedLocation.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 16,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    resolvedLocation,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (footer != null) const SizedBox(height: 6),
                          if (footer != null) footer,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
