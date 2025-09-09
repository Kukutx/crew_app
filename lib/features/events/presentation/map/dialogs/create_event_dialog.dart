// dialogs/create_event_dialog.dart
import 'package:crew_app/features/events/data/event_data.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

Future<EventData?> showCreateEventDialog(BuildContext context, LatLng pos) {
  final title = TextEditingController();
  final desc = TextEditingController();
  final city = TextEditingController(text: '正在获取…');
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
                : (p.administrativeArea ?? '未知');
        city.text = name;
      } else {
        city.text = '未知';
      }
    } catch (_) {
      city.text = '未知';
    }
  }();

  return showDialog<EventData>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Create Event'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '位置: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 12),
              // 城市（可编辑）
              TextFormField(
                controller: city,
                decoration: const InputDecoration(
                  labelText: '城市/地点(可编辑)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入城市' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                    labelText: '活动标题', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入活动标题' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: desc,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: '活动描述', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() != true) return;
            Navigator.pop(
                context, EventData(title: title.text, description: desc.text,                locationName: city.text.trim().isEmpty ? '未知' : city.text.trim(),));
          },
          child: const Text('创建'),
        ),
      ],
    ),
  );
}
