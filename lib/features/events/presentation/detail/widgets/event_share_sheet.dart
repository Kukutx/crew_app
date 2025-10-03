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
    final timeText = event.formattedStartTime(loc.localeName);
    final participantsText = event.participantsDisplayText;
    final showDetails =
        (timeText?.isNotEmpty ?? false) || (participantsText?.isNotEmpty ?? false);
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
                    child: _SharePreviewImage(imageUrl: event.primaryImageUrl),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        loc.registration_open,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
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
                  if (showDetails) ...[
                    const SizedBox(height: 18),
                    _ShareEventDetails(
                      timeText: timeText,
                      participantsText: participantsText,
                      loc: loc,
                    ),
                    const SizedBox(height: 18),
                  ],
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

class _SharePreviewImage extends StatelessWidget {
  final String imageUrl;

  const _SharePreviewImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: Colors.white70, size: 48),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) => Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.white70, size: 48),
        ),
      ),
    );
  }
}

class _ShareEventDetails extends StatelessWidget {
  final String? timeText;
  final String? participantsText;
  final AppLocalizations loc;

  const _ShareEventDetails({
    required this.timeText,
    required this.participantsText,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final details = <Widget>[];
    final timeValue = timeText;
    final participantsValue = participantsText;

    if (timeValue != null && timeValue.isNotEmpty) {
      details.add(_detailRow(Icons.calendar_today_rounded, loc.event_time_title, timeValue));
    }

    if (participantsValue != null && participantsValue.isNotEmpty) {
      if (details.isNotEmpty) {
        details.add(const SizedBox(height: 12));
      }
      details.add(_detailRow(Icons.people_alt_rounded, loc.event_participants_title, participantsValue));
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: details,
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
