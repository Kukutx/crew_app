// dialogs/create_event_dialog.dart
import 'package:crew_app/features/events/data/event_data.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class _DialogImage {
  _DialogImage({required this.file, required this.bytes});

  final XFile file;
  final Uint8List bytes;
}

Future<EventData?> showCreateEventDialog(BuildContext context, LatLng pos) {
  final loc = AppLocalizations.of(context)!;
  final title = TextEditingController();
  final desc = TextEditingController();
  final city = TextEditingController(text: loc.city_loading);
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final images = <_DialogImage>[];
  int? coverIndex;

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
  return showModalBottomSheet<EventData>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> handleAddImages() async {
            final remain = 5 - images.length;
            if (remain <= 0) return;

            final picked = await picker.pickMultiImage();
            if (picked.isEmpty) return;

            for (final img in picked.take(remain)) {
              final bytes = await img.readAsBytes();
              images.add(_DialogImage(file: img, bytes: bytes));
            }

            if (images.isNotEmpty && coverIndex == null) {
              coverIndex = 0;
            }

            setState(() {});
          }

          void handleRemoveImage(int index) {
            setState(() {
              images.removeAt(index);
              if (images.isEmpty) {
                coverIndex = null;
              } else if (coverIndex != null) {
                if (coverIndex! == index) {
                  coverIndex = 0;
                } else if (coverIndex! > index) {
                  coverIndex = coverIndex! - 1;
                }
              }
            });
          }

          void handleSelectCover(int index) {
            setState(() {
              coverIndex = index;
            });
          }
          return AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.create_event_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Form(
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: city,
                          decoration: InputDecoration(
                            labelText: loc.city_field_label,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.location_city),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? loc.please_enter_city
                              : null,
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '活动图片 (最多5张)',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${images.length}/5',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (images.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < images.length; i++)
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => handleSelectCover(i),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: coverIndex == i
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.grey.shade300,
                                            width: coverIndex == i ? 2 : 1,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.memory(
                                          images[i].bytes,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => handleRemoveImage(i),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (coverIndex == i)
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '封面',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        if (images.length < 5)
                          OutlinedButton.icon(
                            onPressed: handleAddImages,
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('添加图片'),
                          ),
                        if (images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              coverIndex == null
                                  ? '未选择封面，默认使用第一张图片。'
                                  : '已选择第${coverIndex! + 1}张作为封面。',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(loc.action_cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() != true) {
                            return;
                          }
                          Navigator.pop(
                            context,
                            EventData(
                              title: title.text,
                              description: desc.text,
                              locationName: city.text.trim().isEmpty
                                  ? loc.unknown
                                  : city.text.trim(),
                            ),
                          );
                        },
                        child: Text(loc.action_create),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
