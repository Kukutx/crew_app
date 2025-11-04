import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// 起始位置选择Sheet
class StartLocationSheet extends StatelessWidget {
  const StartLocationSheet({
    super.key,
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.scrollController,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + viewPadding + viewInsets,
      ),
      children: [
        const SheetHandle(),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.map_select_location_title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.map_select_location_tip,
                    style: tipStyle,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: loc.action_cancel,
              onPressed: onCancel,
            ),
          ],
        ),
        const SizedBox(height: 20),
        ValueListenableBuilder<LatLng?>(
          valueListenable: positionListenable,
          builder: (context, position, _) {
            if (position == null) {
              return const SizedBox.shrink();
            }

            final coords = loc.location_coordinates(
              position.latitude.toStringAsFixed(6),
              position.longitude.toStringAsFixed(6),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coords,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  key: ValueKey(
                    '${position.latitude}_${position.longitude}_start_info',
                  ),
                  future: reverseGeocode(position),
                  builder: (context, snapshot) {
                    final icon = Icon(
                      Icons.home_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: .7),
                    );
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LocationSheetRow(
                        icon: icon,
                        child: Text(loc.map_location_info_address_loading),
                      );
                    }
                    if (snapshot.hasError) {
                      return LocationSheetRow(
                        icon: icon,
                        child: Text(loc.map_location_info_address_unavailable),
                      );
                    }
                    final address = snapshot.data;
                    final display = (address == null || address.trim().isEmpty)
                        ? loc.map_location_info_address_unavailable
                        : address;
                    return LocationSheetRow(
                      icon: icon,
                      child: Text(display),
                    );
                  },
                ),
                const SizedBox(height: 16),
                NearbyPlacesPreview(
                  key: ValueKey(
                    '${position.latitude}_${position.longitude}_start_nearby',
                  ),
                  future: fetchNearbyPlaces(position),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(loc.action_cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onConfirm,
                child: Text(loc.map_location_info_create_event),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
