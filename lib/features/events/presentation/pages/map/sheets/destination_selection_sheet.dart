import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'location_selection_sheets.dart';

/// 目标位置选择Sheet
class DestinationSelectionSheet extends StatefulWidget {
  const DestinationSelectionSheet({
    super.key, 
    required this.startPositionListenable,
    required this.destinationListenable,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
    required this.collapsedListenable,
    required this.onExpand,
    required this.onCancel,
  });

  final ValueListenable<LatLng?> startPositionListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final Future<String?> Function(LatLng) reverseGeocode;
  final Future<List<NearbyPlace>> Function(LatLng) fetchNearbyPlaces;
  final ValueListenable<bool> collapsedListenable;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  State<DestinationSelectionSheet> createState() =>
      DestinationSelectionSheetState();
}

class DestinationSelectionSheetState extends State<DestinationSelectionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleController.addListener(_onTitleChanged);
    widget.destinationListenable.addListener(_onDestinationChanged);
  }

  @override
  void didUpdateWidget(covariant DestinationSelectionSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinationListenable != widget.destinationListenable) {
      oldWidget.destinationListenable.removeListener(_onDestinationChanged);
      widget.destinationListenable.addListener(_onDestinationChanged);
    }
  }

  void _onDestinationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTitleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.destinationListenable.removeListener(_onDestinationChanged);
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  bool get _canCreate {
    return !_isSubmitting &&
        widget.destinationListenable.value != null &&
        _titleController.text.trim().isNotEmpty;
  }

  Future<void> _handleCreate() async {
    final loc = AppLocalizations.of(context)!;
    final destination = widget.destinationListenable.value;
    final start = widget.startPositionListenable.value;
    if (destination == null || start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.map_select_location_destination_missing)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      String? startAddress;
      String? destinationAddress;
      try {
        startAddress = await widget.reverseGeocode(start);
      } catch (_) {}
      try {
        destinationAddress = await widget.reverseGeocode(destination);
      } catch (_) {}
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        QuickRoadTripResult(
          title: _titleController.text.trim(),
          start: start,
          destination: destination,
          startAddress: startAddress,
          destinationAddress: destinationAddress,
          openDetailed: false,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleOpenDetailed() async {
    final start = widget.startPositionListenable.value;
    if (start == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isSubmitting = true);
    String? startAddress;
    String? destinationAddress;
    LatLng? destination;
    try {
      try {
        startAddress = await widget.reverseGeocode(start);
      } catch (_) {}
      destination = widget.destinationListenable.value;
      if (destination != null) {
        try {
          destinationAddress = await widget.reverseGeocode(destination);
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        QuickRoadTripResult(
          title: _titleController.text.trim(),
          start: start,
          destination: destination,
          startAddress: startAddress,
          destinationAddress: destinationAddress,
          openDetailed: true,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<bool>(
          valueListenable: widget.collapsedListenable,
          builder: (context, collapsed, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: collapsed
                  ? DestinationCollapsedView(
                      key: const ValueKey('destination_collapsed'),
                      startListenable: widget.startPositionListenable,
                      destinationListenable: widget.destinationListenable,
                      onExpand: widget.onExpand,
                      onCancel: widget.onCancel,
                    )
                  : DestinationExpandedView(
                      key: const ValueKey('destination_expanded'),
                      formKey: _formKey,
                      titleController: _titleController,
                      isSubmitting: _isSubmitting,
                      canCreate: _canCreate,
                      onCreate: _handleCreate,
                      onOpenDetailed: _handleOpenDetailed,
                      onCancel: widget.onCancel,
                      startListenable: widget.startPositionListenable,
                      destinationListenable: widget.destinationListenable,
                      reverseGeocode: widget.reverseGeocode,
                      fetchNearbyPlaces: widget.fetchNearbyPlaces,
                    ),
            );
          },
        ),
      ),
    );
  }
}

/// 目标位置展开视图
class DestinationExpandedView extends StatelessWidget {
  const DestinationExpandedView({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.isSubmitting,
    required this.canCreate,
    required this.onCreate,
    required this.onOpenDetailed,
    required this.onCancel,
    required this.startListenable,
    required this.destinationListenable,
    required this.reverseGeocode,
    required this.fetchNearbyPlaces,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final bool isSubmitting;
  final bool canCreate;
  final Future<void> Function() onCreate;
  final Future<void> Function() onOpenDetailed;
  final VoidCallback onCancel;
  final ValueListenable<LatLng?> startListenable;
  final ValueListenable<LatLng?> destinationListenable;
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
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: formKey,
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
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: loc.map_select_location_trip_title_label,
                  hintText: loc.map_select_location_trip_title_hint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.map_select_location_title_required;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<LatLng?>(
                valueListenable: startListenable,
                builder: (context, position, _) {
                  if (position == null) {
                    return const SizedBox.shrink();
                  }

                  final coords = loc.location_coordinates(
                    position.latitude.toStringAsFixed(6),
                    position.longitude.toStringAsFixed(6),
                  );
                  final icon = Icon(
                    Icons.flag_circle_outlined,
                    color: theme.colorScheme.primary,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.map_select_location_start_label,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      LocationSheetRow(
                        icon: icon,
                        child: Text(
                          coords,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<String?>(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start',
                        ),
                        future: reverseGeocode(position),
                        builder: (context, snapshot) {
                          final addressIcon = Icon(
                            Icons.home_outlined,
                            color: Colors.blueGrey.shade600,
                          );
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_loading),
                            );
                          }
                          if (snapshot.hasError) {
                            return LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_unavailable),
                            );
                          }
                          final address = snapshot.data;
                          final display = (address == null || address.trim().isEmpty)
                              ? loc.map_location_info_address_unavailable
                              : address;
                          return LocationSheetRow(
                            icon: addressIcon,
                            child: Text(display),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      NearbyPlacesPreview(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start_nearby_trip',
                        ),
                        future: fetchNearbyPlaces(position),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<LatLng?>(
                valueListenable: destinationListenable,
                builder: (context, position, _) {
                  final icon = Icon(
                    Icons.flag,
                    color: Colors.green.shade700,
                  );
                  final label = Text(
                    loc.map_select_location_destination_label,
                    style: theme.textTheme.labelLarge,
                  );
                  if (position == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label,
                        const SizedBox(height: 6),
                        LocationSheetRow(
                          icon: icon,
                          child: Text(
                            loc.map_select_location_destination_tip,
                            style: tipStyle,
                          ),
                        ),
                      ],
                    );
                  }

                  final coords = loc.location_coordinates(
                    position.latitude.toStringAsFixed(6),
                    position.longitude.toStringAsFixed(6),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      const SizedBox(height: 6),
                      LocationSheetRow(
                        icon: icon,
                        child: Text(
                          coords,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<String?>(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_destination',
                        ),
                        future: reverseGeocode(position),
                        builder: (context, snapshot) {
                          final addressIcon = Icon(
                            Icons.place_outlined,
                            color: Colors.green.shade700,
                          );
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_loading),
                            );
                          }
                          if (snapshot.hasError) {
                            return LocationSheetRow(
                              icon: addressIcon,
                              child: Text(loc.map_location_info_address_unavailable),
                            );
                          }
                          final address = snapshot.data;
                          final display = (address == null || address.trim().isEmpty)
                              ? loc.map_location_info_address_unavailable
                              : address;
                          return LocationSheetRow(
                            icon: addressIcon,
                            child: Text(display),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      NearbyPlacesPreview(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_destination_nearby_trip',
                        ),
                        future: fetchNearbyPlaces(position),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: isSubmitting ? null : () => onOpenDetailed(),
                icon: const Icon(Icons.auto_awesome_motion_outlined),
                label: Text(loc.map_select_location_open_detailed),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : onCancel,
                      child: Text(loc.action_cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canCreate ? () => onCreate() : null,
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(loc.map_select_location_create_trip),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 目标位置折叠视图
class DestinationCollapsedView extends StatelessWidget {
  const DestinationCollapsedView({
    super.key,
    required this.startListenable,
    required this.destinationListenable,
    required this.onExpand,
    required this.onCancel,
  });

  final ValueListenable<LatLng?> startListenable;
  final ValueListenable<LatLng?> destinationListenable;
  final VoidCallback onExpand;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
                        loc.map_select_location_create_trip,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.map_selection_sheet_tap_to_expand,
                        style: subtitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 12),
            ValueListenableBuilder<LatLng?>(
              valueListenable: startListenable,
              builder: (context, position, _) {
                if (position == null) {
                  return const SizedBox.shrink();
                }
                final coords = loc.location_coordinates(
                  position.latitude.toStringAsFixed(6),
                  position.longitude.toStringAsFixed(6),
                );
                return LocationSheetRow(
                  icon: Icon(
                    Icons.flag_circle_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  child: Text(
                    coords,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<LatLng?>(
              valueListenable: destinationListenable,
              builder: (context, position, _) {
                final icon = Icon(
                  Icons.flag,
                  color: Colors.green.shade700,
                );
                if (position == null) {
                  return LocationSheetRow(
                    icon: icon,
                    child: Text(
                      loc.map_select_location_destination_tip,
                      style: subtitleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                final coords = loc.location_coordinates(
                  position.latitude.toStringAsFixed(6),
                  position.longitude.toStringAsFixed(6),
                );
                return LocationSheetRow(
                  icon: icon,
                  child: Text(
                    coords,
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
