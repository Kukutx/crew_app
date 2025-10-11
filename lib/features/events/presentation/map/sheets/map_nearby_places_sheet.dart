import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/network/places/places_service.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import 'map_place_details_sheet.dart';

Future<void> showMapNearbyPlacesSheet({
  required BuildContext context,
  required Future<List<PlaceDetails>> placesFuture,
  String? emptyMessage,
  Future<void> Function(PlaceDetails place)? onPlaceSelected,
}) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MapNearbyPlacesSheet(
      placesFuture: placesFuture,
      emptyMessage: emptyMessage,
      onPlaceSelected: onPlaceSelected,
    ),
  );
}

class _MapNearbyPlacesSheet extends StatefulWidget {
  const _MapNearbyPlacesSheet({
    required this.placesFuture,
    this.emptyMessage,
    this.onPlaceSelected,
  });

  final Future<List<PlaceDetails>> placesFuture;
  final String? emptyMessage;
  final Future<void> Function(PlaceDetails place)? onPlaceSelected;

  @override
  State<_MapNearbyPlacesSheet> createState() => _MapNearbyPlacesSheetState();
}

class _MapNearbyPlacesSheetState extends State<_MapNearbyPlacesSheet> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      child: FutureBuilder<List<PlaceDetails>>(
        future: widget.placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.map_nearby_places_title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.map_nearby_places_title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.map_place_details_error,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final places = snapshot.data ?? const <PlaceDetails>[];
          if (places.isEmpty) {
            return SizedBox(
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.map_nearby_places_title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.emptyMessage ?? loc.map_place_details_not_found,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return SizedBox(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.map_nearby_places_title,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.map_nearby_places_swipe_hint,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return _PlaceCard(
                        place: place,
                        onTap: widget.onPlaceSelected == null
                            ? null
                            : () => unawaited(widget.onPlaceSelected!(place)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    this.onTap,
  });

  final PlaceDetails place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final ratingText = place.rating != null
        ? loc.map_place_details_rating_value(place.rating!.toStringAsFixed(1))
        : loc.map_place_details_no_rating;
    final reviewsText = loc.map_place_details_reviews(place.userRatingsTotal ?? 0);
    final priceLevel = describePlacePriceLevel(loc, place.priceLevel);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.displayName,
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                if (place.formattedAddress != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.formattedAddress!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (place.formattedAddress != null) const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rate_rounded, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      ratingText,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reviewsText,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: Text(loc.map_nearby_places_more_details),
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
