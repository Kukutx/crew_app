import 'package:crew_app/core/state/events_providers.dart';
import 'package:crew_app/core/state/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../data/event.dart';
import '../data/event_data.dart';
import 'package:geocoding/geocoding.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _map = MapController();
  bool movedToSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 监听定位或选中事件变化后移动镜头（只移一次选中事件）
    ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (_, next) {
      final loc = next.valueOrNull;
      if (!movedToSelected && widget.selectedEvent == null && loc != null) {
        _map.move(loc, 14);
      }
    });

    if (widget.selectedEvent != null && !movedToSelected) {
      final ev = widget.selectedEvent!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _map.move(LatLng(ev.latitude, ev.longitude), 15);
        _showEventDetails(ev);
        movedToSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final userLoc = ref.watch(userLocationProvider).valueOrNull;
    final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);

    return Scaffold(
      extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0), // 半透明背景
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索活动',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onSubmitted: (keyword) {
              // TODO: 调用搜索逻辑
              debugPrint('搜索: $keyword');
            },
          ),
        ),
      ),
      body: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: startCenter,
          initialZoom: 5,
          onLongPress: _onMapLongPress,
          onMapReady: () {
            if (!movedToSelected && userLoc != null) {
              _map.move(userLoc, 14);
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.crewapp',
          ),
          events.when(
            loading: () => const MarkerLayer(markers: []),
            error: (_, __) => const MarkerLayer(markers: []),
            data: (list) => MarkerLayer(
              markers: [
                ...list.map((ev) => Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(ev.latitude, ev.longitude),
                      child: GestureDetector(
                        onTap: () => _showEventDetails(ev),
                        child: const Icon(Icons.location_pin,
                            color: Colors.red, size: 40),
                      ),
                    )),
                if (userLoc != null)
                  Marker(
                    point: userLoc,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_pin,
                        color: Colors.blue, size: 40),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final loc = ref.read(userLocationProvider).valueOrNull;
          if (loc != null) {
            _map.move(loc, 14);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('无法获取定位')),
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _onMapLongPress(TapPosition _, LatLng latlng) async {
    final data = await _showCreateEventDialog(latlng);
    if (data == null || data.title.trim().isEmpty) return;

    // 反地理编码（容错）
    String locationName = 'Unknown';
    try {
      final list =
          await placemarkFromCoordinates(latlng.latitude, latlng.longitude)
              .timeout(const Duration(seconds: 5));
      if (list.isNotEmpty) {
        locationName = list.first.locality ??
            list.first.subAdministrativeArea ??
            'Unknown';
      }
    } catch (_) {}

    await ref.read(eventsProvider.notifier).createEvent(
          title: data.title.trim(),
          description: data.description.trim(),
          pos: latlng,
          locationName: locationName,
        );
  }

  Future<EventData?> _showCreateEventDialog(LatLng pos) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                    '位置: ${pos.latitude.toStringAsFixed(6)}, '
                    '${pos.longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(context,
                  EventData(title: title.text, description: desc.text));
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Event ev) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ev.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ev.description),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.location_on, color: Colors.grey),
              const SizedBox(width: 6),
              Text('Lat: ${ev.latitude}, Lng: ${ev.longitude}'),
            ]),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('报名功能还没做 😅')),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('报名参加'),
            ),
          ],
        ),
      ),
    );
  }
}
