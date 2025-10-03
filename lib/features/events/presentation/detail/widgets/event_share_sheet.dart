import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EventShareSheet extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final GlobalKey previewKey;
  final String shareLink;
  final Future<void> Function() onCopyLink;
  final Future<void> Function() onShareSystem;

  const EventShareSheet({
    super.key,
    required this.event,
    required this.loc,
    required this.previewKey,
    required this.shareLink,
    required this.onCopyLink,
    required this.onShareSystem,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SharePreviewCard(
                event: event,
                loc: loc,
                previewKey: previewKey,
                shareLink: shareLink,
              ),
              const SizedBox(height: 20),
              Text(
                loc.share_card_subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ShareActionButton(
                    icon: Icons.copy_rounded,
                    label: loc.share_action_copy_link,
                    onTap: onCopyLink,
                  ),
                  ShareActionButton(
                    icon: Icons.ios_share,
                    label: loc.share_action_share_system,
                    onTap: onShareSystem,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    return RepaintBoundary(
      key: previewKey,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF0E0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image(
                      image: CachedNetworkImageProvider(event.coverImageUrl),
                      fit: BoxFit.cover,
                    ),
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
                          backgroundColor: Colors.orange,
                        ),
                        _StatusChip(
                          label: loc.to_be_announced,
                        ),
                        _StatusChip(
                          label: loc.to_be_announced,
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
                                event.location,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
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
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shareLink,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
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
                            backgroundColor: Colors.white,
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;

  const _StatusChip({
    required this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
class ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const ShareActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.orange),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
