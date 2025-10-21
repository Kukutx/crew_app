import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventWaypointPickerPage extends StatefulWidget {
  const EventWaypointPickerPage({super.key, this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<EventWaypointPickerPage> createState() => _EventWaypointPickerPageState();
}

class _EventWaypointPickerPageState extends State<EventWaypointPickerPage> {
  GoogleMapController? _controller;
  late LatLng _initialCameraPosition;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = widget.initialPosition ?? const LatLng(31.2304, 121.4737);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Set<Marker> get _markers => {
        if (_selectedPosition != null)
          Marker(
            markerId: const MarkerId('selected_waypoint'),
            position: _selectedPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
      };

  Future<void> _handleLongPress(LatLng position) async {
    setState(() => _selectedPosition = position);
    HapticFeedback.mediumImpact();
    final label = await _showConfirmSheet(position);
    if (!mounted) return;
    if (label != null && label.trim().isNotEmpty) {
      Navigator.of(context).pop(label.trim());
    }
  }

  Future<String?> _showConfirmSheet(LatLng position) {
    final loc = AppLocalizations.of(context)!;
    final coordinates = '${position.latitude.toStringAsFixed(4)}, '
        '${position.longitude.toStringAsFixed(4)}';

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(sheetContext).viewPadding.bottom,
            ),
            child: FutureBuilder<String?>(
              future: _resolveAddress(position),
              builder: (context, snapshot) {
                final isLoading = snapshot.connectionState == ConnectionState.waiting;
                final hasError = snapshot.hasError;
                final resolvedAddress = snapshot.data;
                final displayLabel = (resolvedAddress == null || resolvedAddress.trim().isEmpty)
                    ? coordinates
                    : resolvedAddress.trim();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.event_waypoint_picker_confirm_title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      displayLabel,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.location_coordinates(
                        position.latitude.toStringAsFixed(6),
                        position.longitude.toStringAsFixed(6),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(loc.map_location_info_address_loading),
                          ),
                        ],
                      ),
                    ] else if (hasError) ...[
                      const SizedBox(height: 16),
                      Text(
                        loc.map_location_info_address_unavailable,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(null),
                          child: Text(loc.action_cancel),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(displayLabel),
                          child: Text(loc.event_waypoint_picker_confirm_button),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<String?> _resolveAddress(LatLng position) async {
    try {
      final localeTag = Localizations.localeOf(context).toLanguageTag();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: localeTag,
      );
      if (placemarks.isEmpty) {
        return null;
      }
      for (final placemark in placemarks) {
        final formatted = _formatPlacemark(placemark);
        if (formatted != null) {
          return formatted;
        }
      }
      return _formatPlacemark(placemarks.first);
    } catch (_) {
      return null;
    }
  }

  String? _formatPlacemark(Placemark placemark) {
    final parts = <String?>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
    ]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (parts.isEmpty && placemark.name != null && placemark.name!.trim().isNotEmpty) {
      parts.add(placemark.name!.trim());
    }
    final seen = <String>{};
    final unique = <String>[];
    for (final part in parts) {
      if (seen.add(part)) {
        unique.add(part);
      }
    }
    if (unique.isEmpty) {
      return null;
    }
    return unique.take(3).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.event_waypoint_picker_title),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialCameraPosition, zoom: 10),
            onMapCreated: (controller) => _controller = controller,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            onLongPress: _handleLongPress,
          ),
          Positioned(
            top: 16 + MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            child: Material(
              color: theme.colorScheme.surface.withOpacity(0.92),
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  loc.event_waypoint_picker_tip,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
