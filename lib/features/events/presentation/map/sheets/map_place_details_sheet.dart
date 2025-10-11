import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../core/network/places/places_service.dart';

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

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder<PlaceDetails?>(
        future: detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            final title = fallbackName ?? loc.map_place_details_title;
            return _MapBottomSheetFrame(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }

          if (snapshot.hasError) {
            return _MapBottomSheetFrame(
              children: [
                Text(
                  loc.map_place_details_title,
                  style: theme.textTheme.titleMedium,
                ),
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
            return _MapBottomSheetFrame(
              children: [
                Text(
                  loc.map_place_details_title,
                  style: theme.textTheme.titleMedium,
                ),
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
          final priceLevel = describePlacePriceLevel(loc, details.priceLevel);

          return _MapBottomSheetFrame(
            children: [
              Text(
                details.displayName,
                style: theme.textTheme.titleMedium,
              ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.payments_rounded, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    priceLevel,
                    style: theme.textTheme.bodyMedium,
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
      ),
    );
  }

}

String describePlacePriceLevel(AppLocalizations loc, String? value) {
  switch (value) {
    case 'PRICE_LEVEL_FREE':
      return loc.map_place_details_price_free;
    case 'PRICE_LEVEL_INEXPENSIVE':
      return loc.map_place_details_price_inexpensive;
    case 'PRICE_LEVEL_MODERATE':
      return loc.map_place_details_price_moderate;
    case 'PRICE_LEVEL_EXPENSIVE':
      return loc.map_place_details_price_expensive;
    case 'PRICE_LEVEL_VERY_EXPENSIVE':
      return loc.map_place_details_price_very_expensive;
    default:
      return loc.map_place_details_price_unknown;
  }
}

class _MapBottomSheetFrame extends StatelessWidget {
  const _MapBottomSheetFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}
