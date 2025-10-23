import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'location_selection_sheets.dart';

/// 起始位置选择Sheet
class StartLocationSheet extends StatelessWidget {
  const StartLocationSheet({
    super.key, 
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.collapsedListenable,
    required this.onExpand,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueListenable<bool> collapsedListenable;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: collapsedListenable,
          builder: (context, collapsed, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: collapsed
                  ? CollapsedSheetView(
                      key: const ValueKey('start_collapsed'),
                      title: AppLocalizations.of(context)!.map_select_location_title,
                      subtitle: AppLocalizations.of(context)!
                          .map_selection_sheet_tap_to_expand,
                      onExpand: onExpand,
                      onCancel: onCancel,
                    )
                  : StartExpandedView(
                      key: const ValueKey('start_expanded'),
                      positionListenable: positionListenable,
                      onConfirm: onConfirm,
                      onCancel: onCancel,
                      reverseGeocode: reverseGeocode,
                      fetchNearbyPlaces: fetchNearbyPlaces,
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// 起始位置展开视图
class StartExpandedView extends StatelessWidget {
  const StartExpandedView({
    super.key,
    required this.positionListenable,
    required this.onConfirm,
    required this.onCancel,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
  });

  final ValueListenable<LatLng?> positionListenable;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: Colors.blueGrey.shade600,
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
        ),
      ),
    );
  }
}

/// 折叠Sheet视图
class CollapsedSheetView extends StatelessWidget {
  const CollapsedSheetView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onExpand,
    required this.onCancel,
  });

  final String title;
  final String subtitle;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return InkWell(
      onTap: onExpand,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          16,
          24 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: AppLocalizations.of(context)!.action_cancel,
                  onPressed: onCancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
