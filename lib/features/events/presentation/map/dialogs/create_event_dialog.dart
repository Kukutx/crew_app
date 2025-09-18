// dialogs/create_event_dialog.dart
import 'package:crew_app/features/events/data/event_data.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

Future<EventData?> showCreateEventDialog(BuildContext context, LatLng pos) {
  final loc = AppLocalizations.of(context)!;
  final title = TextEditingController();
  final desc = TextEditingController();
  final city = TextEditingController(text: loc.city_loading);
  final formKey = GlobalKey<FormState>();

  // 开始反地理编码
  () async {
    try {
      final list = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      ).timeout(const Duration(seconds: 5));
      if (list.isNotEmpty) {
        final p = list.first;
        // 优先 city/locality，其次 subAdministrativeArea 或 administrativeArea
        final name = (p.locality?.trim().isNotEmpty == true)
            ? p.locality!
            : (p.subAdministrativeArea?.trim().isNotEmpty == true)
                ? p.subAdministrativeArea!
                : (p.administrativeArea ?? loc.unknown);
        city.text = name;
      } else {
        city.text = loc.unknown;
      }
    } catch (_) {
      city.text = loc.unknown;
    }
  }();

  return showDialog<EventData>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(loc.create_event_title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.location_coordinates(
                  pos.latitude.toStringAsFixed(6),
                  pos.longitude.toStringAsFixed(6),
                ),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              // 城市（可编辑）
              TextFormField(
                controller: city,
                decoration: InputDecoration(
                  labelText: loc.city_field_label,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? loc.please_enter_city : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: title,
                decoration: InputDecoration(
                  labelText: loc.event_title_field_label,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? loc.please_enter_event_title
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desc,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.event_description_field_label,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.action_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() != true) return;
            Navigator.pop(
              context,
              EventData(
                title: title.text,
                description: desc.text,
                locationName:
                    city.text.trim().isEmpty ? loc.unknown : city.text.trim(),
              ),
            );
          },
          child: Text(loc.action_create),
        ),
      ],
    ),
  );
}
