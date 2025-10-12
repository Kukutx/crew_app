import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
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
    final theme = Theme.of(context);
    final imageUrl = event.firstAvailableImageUrl;
    final participantSummary =
        event.participantSummary ?? loc.to_be_announced;
    final startTime = event.startTime;
    final timeLabel = startTime != null
        ? DateFormat('MMM d · HH:mm').format(startTime.toLocal())
        : loc.to_be_announced;
    final description = event.description.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderImage(
                imageUrl: imageUrl,
                onClose: onClose,
                onFavorite: onFavorite,
                isFavorite: event.isFavorite,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.schedule,
                      label: timeLabel,
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.groups,
                      label: participantSummary,
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(loc.event_details_title),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: onRegister,
                        child: Text(
                          loc.action_register_now,
                          style: theme.textTheme.labelLarge,
                        ),
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

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({
    required this.imageUrl,
    required this.onClose,
    required this.onFavorite,
    required this.isFavorite,
  });

  final String? imageUrl;
  final VoidCallback onClose;
  final VoidCallback onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 176,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE0E0E0),
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  )
                : const ColoredBox(
                    color: Color(0xFFE0E0E0),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _CircleIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: isFavorite ? Colors.redAccent : Colors.white,
              backgroundColor: Colors.black.withOpacity(0.35),
              onPressed: onFavorite,
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _CircleIconButton(
              icon: Icons.close,
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.4),
      shape: const CircleBorder(),
      child: IconButton(
        iconSize: 22,
        padding: const EdgeInsets.all(10),
        onPressed: onPressed,
        color: iconColor ?? theme.colorScheme.onPrimary,
        icon: Icon(icon),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
