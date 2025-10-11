import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final Event event;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;
  final VoidCallback? onTap;
  final VoidCallback? onLocate;
  final String? registerLabel;
  final bool isFocused;

  const EventDetailBottomBar({
    super.key,
    required this.loc,
    required this.event,
    required this.isFavorite,
    required this.onFavorite,
    required this.onRegister,
    this.onTap,
    this.onLocate,
    this.registerLabel,
    this.isFocused = true,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.firstAvailableImageUrl;
    final participantSummary = event.participantSummary ?? loc.to_be_announced;
    final startTime = event.startTime;
    final timeLabel = startTime != null
        ? DateFormat('MM.dd HH:mm').format(startTime.toLocal())
        : loc.to_be_announced;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isFocused ? 0.18 : 0.1),
            blurRadius: isFocused ? 20 : 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventThumbnail(imageUrl: imageUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: onFavorite,
                            splashRadius: 20,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.place,
                        text: event.location,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.event,
                        text: timeLabel,
                      ),
                      const SizedBox(height: 6),
                      _InfoRow(
                        icon: Icons.groups,
                        text: participantSummary,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (onLocate != null)
                            SizedBox(
                              height: 40,
                              child: OutlinedButton.icon(
                                onPressed: onLocate,
                                icon: const Icon(Icons.my_location_outlined),
                                label: Text(loc.map_focus_event),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: const BorderSide(color: Colors.black12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          if (onLocate != null) const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: onRegister,
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(registerLabel ?? loc.action_register),
                              ),
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
        ),
      ),
    );
  }
}

class _EventThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _EventThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 84,
        height: 84,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
      child: Icon(
        Icons.image_outlined,
        color: Colors.black26,
        size: 28,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
