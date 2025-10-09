import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_image_placeholder.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/sheets/share_sheet/app_share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventShareSheet extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final GlobalKey previewKey;
  final String shareLink;
  final Future<void> Function() onSaveImage;
  final Future<void> Function() onShareSystem;

  const EventShareSheet({
    super.key,
    required this.event,
    required this.loc,
    required this.previewKey,
    required this.shareLink,
    required this.onSaveImage,
    required this.onShareSystem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppShareSheet(
      preview: SharePreviewCard(
        event: event,
        loc: loc,
        previewKey: previewKey,
        shareLink: shareLink,
      ),
      description: Text(
        loc.share_card_subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        AppShareActionButton(
          icon: Icons.image_outlined,
          label: loc.share_action_save_image,
          onTap: onSaveImage,
          iconColor: colorScheme.primary,
          labelColor: colorScheme.primary,
        ),
        AppShareActionButton(
          icon: Icons.ios_share,
          label: loc.share_action_share_system,
          onTap: onShareSystem,
          iconColor: colorScheme.primary,
          labelColor: colorScheme.primary,
        ),
      ],
    );
  }
}

class SharePreviewCard extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final GlobalKey previewKey;
  final String shareLink;

  const SharePreviewCard({
    super.key,
    required this.event,
    required this.loc,
    required this.previewKey,
    required this.shareLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeLabel = event.startTime != null
        ? DateFormat('MM.dd HH:mm').format(event.startTime!.toLocal())
        : loc.to_be_announced;
    final participantsLabel = event.participantSummary ?? loc.to_be_announced;
    final organizerName = event.organizer?.name;
    return RepaintBoundary(
      key: previewKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.hardEdge,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.65),
                colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _SharePreviewImage(event: event),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 20,
                      right: 20,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: loc.registration_open,
                            backgroundColor: colorScheme.primary,
                            textColor: colorScheme.onPrimary,
                          ),
                          _StatusChip(
                            label: timeLabel,
                            textColor: colorScheme.onSurface,
                            backgroundColor:
                                colorScheme.surfaceContainerHigh.withValues(
                              alpha: 0.9,
                            ),
                            icon: Icons.calendar_today,
                            iconColor: colorScheme.primary,
                          ),
                          _StatusChip(
                            label: participantsLabel,
                            textColor: colorScheme.onSurface,
                            backgroundColor:
                                colorScheme.surfaceContainerHigh.withValues(
                              alpha: 0.9,
                            ),
                            icon: Icons.people,
                            iconColor: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.place_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event.address?.isNotEmpty == true
                                      ? event.address!
                                      : event.location,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (organizerName != null && organizerName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                organizerName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.share_card_title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.share_card_subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  loc.share_card_qr_caption,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onLongPress: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: shareLink),
                                    );
                                    HapticFeedback.lightImpact();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(loc.share_copy_success),
                                        ),
                                      );
                                  },
                                  child: Text(
                                    shareLink,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: QrImageView(
                              data: shareLink,
                              version: QrVersions.auto,
                              size: 80,
                              backgroundColor: colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;

  const _StatusChip({
    required this.label,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ??
            colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor ?? textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharePreviewImage extends StatelessWidget {
  final Event event;

  const _SharePreviewImage({required this.event});

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.firstAvailableImageUrl;
    if (imageUrl == null) {
      return const EventImagePlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const EventImagePlaceholder(),
    );
  }
}
