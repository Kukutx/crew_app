import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// Sheet手柄
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .12);
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// 位置Sheet行
class LocationSheetRow extends StatelessWidget {
  const LocationSheetRow({super.key, required this.icon, required this.child});

  final Icon icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

/// 附近地点预览
class NearbyPlacesPreview extends StatelessWidget {
  const NearbyPlacesPreview({super.key, required this.future});

  final Future<List<NearbyPlace>> future;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.map_location_info_nearby_title,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<NearbyPlace>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text(
                loc.map_location_info_nearby_error,
                style: theme.textTheme.bodySmall,
              );
            }
            final places = snapshot.data;
            if (places == null || places.isEmpty) {
              return Text(
                loc.map_location_info_nearby_empty,
                style: theme.textTheme.bodySmall,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < places.length; i++) ...[
                  NearbyPlaceTile(place: places[i]),
                  if (i < places.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 附近地点瓦片
class NearbyPlaceTile extends StatelessWidget {
  const NearbyPlaceTile({super.key, required this.place});

  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );
    final address = place.formattedAddress?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.displayName,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
                  style: subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 快速行程结果
class QuickRoadTripResult {
  const QuickRoadTripResult({
    required this.title,
    required this.start,
    required this.destination,
    required this.startAddress,
    required this.destinationAddress,
    required this.openDetailed,
  });

  final String title;
  final LatLng start;
  final LatLng? destination;
  final String? startAddress;
  final String? destinationAddress;
  final bool openDetailed;
}
