import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/theme/app_colors.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MapEventFloatingCard extends StatelessWidget {
  const MapEventFloatingCard({
    required this.event,
    required this.onClose,
    required this.onTap,
    required this.onRegister,
    required this.onFavorite,
    super.key,
  });

  final Event event;
  final VoidCallback onClose;
  final VoidCallback onTap;
  final VoidCallback onRegister;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final imageUrl = event.firstAvailableImageUrl;
    final participantSummary =
        event.participantSummary ?? loc.to_be_announced;
    final startTime = event.startTime;
    final timeLabel = startTime != null
        ? DateFormat('MM.dd HH:mm').format(startTime.toLocal())
        : loc.to_be_announced;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'event-media-${event.id}',
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const DecoratedBox(
                              decoration: BoxDecoration(color: Color(0xFFDFE6F4)),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => const DecoratedBox(
                              decoration: BoxDecoration(color: Color(0xFFD6DDEB)),
                              child: Center(child: Icon(Icons.landscape_outlined)),
                            ),
                          )
                        : const DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFD6DDEB)),
                            child: Center(child: Icon(Icons.landscape_outlined)),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Pill(text: timeLabel),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      children: [
                        _CircularIconButton(
                          icon: event.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: onFavorite,
                          selected: event.isFavorite,
                        ),
                        const SizedBox(height: 8),
                        _CircularIconButton(
                          icon: Icons.close,
                          onTap: onClose,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          event.title,
                          style: AppTextStyles.headline.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTextStyles.bodyMuted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Chip(icon: Icons.groups_rounded, label: participantSummary),
                      if (event.distanceLabel != null &&
                          event.distanceLabel!.trim().isNotEmpty)
                        _Chip(
                          icon: Icons.navigation_outlined,
                          label: event.distanceLabel!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: FilledButton.icon(
                onPressed: onRegister,
                icon: const Icon(Icons.auto_awesome),
                label: Text(loc.action_register_now),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: AppTextStyles.chip.copyWith(color: AppColors.onSurface),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.chip.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withOpacity(0.92)
          : Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: selected ? Colors.white : AppColors.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }
}
