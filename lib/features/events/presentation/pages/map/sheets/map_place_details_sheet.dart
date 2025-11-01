import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../widgets/map_draggable_sheet.dart';
import '../../../../../../core/network/places/places_service.dart';

Future<void> showMapPlaceDetailsSheet({
  required BuildContext context,
  required Future<PlaceDetails?> detailsFuture,
  String? fallbackName,
  String? emptyMessage,
}) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MapPlaceDetailsSheet(
      detailsFuture: detailsFuture,
      fallbackName: fallbackName,
      emptyMessage: emptyMessage,
    ),
  );
}

class _MapPlaceDetailsSheet extends StatelessWidget {
  const _MapPlaceDetailsSheet({
    required this.detailsFuture,
    this.fallbackName,
    this.emptyMessage,
  });

  final Future<PlaceDetails?> detailsFuture;
  final String? fallbackName;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return MapDraggableSheet(
      minChildSize: 0.25,
      initialChildSize: 0.4,
      maxChildSize: 0.9,
      childBuilder: (context) {
        return FutureBuilder<PlaceDetails?>(
          future: detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              final title = fallbackName ?? loc.map_place_details_title;
              return _MapDetailsContent(
                title: title,
                children: const [
                  SizedBox(height: 16),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return _MapDetailsContent(
                title: loc.map_place_details_title,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    loc.map_place_details_error,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final details = snapshot.data;
            if (details == null) {
              return _MapDetailsContent(
                title: loc.map_place_details_title,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    emptyMessage ?? loc.map_place_details_not_found,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final ratingText = details.rating != null
                ? loc.map_place_details_rating_value(
                    details.rating!.toStringAsFixed(1),
                  )
                : loc.map_place_details_no_rating;
            final reviewsText = loc.map_place_details_reviews(
              details.userRatingsTotal ?? 0,
            );

            return _MapDetailsContent(
              title: details.displayName,
              children: [
                const SizedBox(height: 12),
                if (details.formattedAddress != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          details.formattedAddress!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                if (details.formattedAddress != null) const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rate_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      ratingText,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      reviewsText,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (details.location != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.location_coordinates(
                            details.location!.latitude.toStringAsFixed(6),
                            details.location!.longitude.toStringAsFixed(6),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _MapDetailsContent extends StatelessWidget {
  const _MapDetailsContent({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        ...children,
      ],
    );
  }
}
