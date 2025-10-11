import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> showMapLocationInfoSheet({
  required BuildContext context,
  required LatLng position,
  required Future<String?> addressFuture,
  VoidCallback? onCreateEvent,
}) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _MapLocationInfoSheet(
      position: position,
      addressFuture: addressFuture,
      onCreateEvent: onCreateEvent,
    ),
  );
}

class _MapLocationInfoSheet extends StatelessWidget {
  const _MapLocationInfoSheet({
    required this.position,
    required this.addressFuture,
    this.onCreateEvent,
  });

  final LatLng position;
  final Future<String?> addressFuture;
  final VoidCallback? onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
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
          Text(
            loc.map_location_info_title,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  loc.location_coordinates(
                    position.latitude.toStringAsFixed(6),
                    position.longitude.toStringAsFixed(6),
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String?>(
            future: addressFuture,
            builder: (context, snapshot) {
              final icon = Icon(
                Icons.home_outlined,
                color: Colors.blueGrey.shade600,
              );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _SheetRow(
                  icon: icon,
                  child: Text(loc.map_location_info_address_loading),
                );
              }
              if (snapshot.hasError) {
                return _SheetRow(
                  icon: icon,
                  child: Text(loc.map_location_info_address_unavailable),
                );
              }
              final address = snapshot.data;
              final text = (address == null || address.trim().isEmpty)
                  ? loc.map_location_info_address_unavailable
                  : address;
              return _SheetRow(
                icon: icon,
                child: Text(text),
              );
            },
          ),
          if (onCreateEvent != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCreateEvent,
                child: Text(loc.map_location_info_create_event),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.child});

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
