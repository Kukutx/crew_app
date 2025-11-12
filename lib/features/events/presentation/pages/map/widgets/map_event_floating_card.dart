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
    final memberSummary = event?.memberSummary ?? loc.to_be_announced;

    final actionButton =
        primaryAction ??
        (event != null && onRegister != null
            ? FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onRegister,
                child: Text(
                  loc.action_register_now,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0,
                  ),
                ),
              )
            : null);

    final trailingActions = [
      if (onFavorite != null)
        IconButton(
          onPressed: onFavorite,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          icon: Icon(
            resolvedIsFavorite ? Icons.star : Icons.star_border,
            size: 20,
          ),
        ),
      if (onClose != null)
        IconButton(
          onPressed: onClose,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          icon: const Icon(
            Icons.close,
            size: 20,
          ),
        ),
    ];

    Widget? footer;
    if (event != null) {
      footer = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _smallChip(context, loc.registration_open),
          const SizedBox(width: 6),
          Icon(
            Icons.groups,
            size: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              memberSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
          if (actionButton != null) ...[const SizedBox(width: 6), actionButton],
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            memCacheHeight: 512,
                            placeholder: (_, _) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
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
                                  size: 20,
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
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                                fontSize: 16,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ...trailingActions.map((action) => SizedBox(
                            width: 36,
                            height: 36,
                            child: action,
                          )),
                        ],
                      ),
                      if (resolvedTimeLabel != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          resolvedTimeLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.3,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                      if (resolvedLocation != null &&
                          resolvedLocation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.place,
                              size: 14,
                              color: colorScheme.outline.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                resolvedLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                  height: 1.3,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 6),
                        footer,
                      ],
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.secondary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.2,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
