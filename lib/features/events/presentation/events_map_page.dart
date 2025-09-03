import 'package:crew_app/core/state/events_providers.dart';
import 'package:crew_app/core/state/location_provider.dart';
import 'package:crew_app/features/events/data/event_filter.dart';
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

  final List<String> _allCategories = [
    '派对',
    '运动',
    '音乐',
    '户外',
    '学习',
    '展览',
    '美食'
  ];

  EventFilter _filter = const EventFilter();

  Future<EventFilter?> showEventFilterSheet(
    BuildContext context,
    EventFilter initial,
    List<String> allCategories,
  ) {
    return showModalBottomSheet<EventFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        var temp = initial;
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 距离
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('距离'),
                      Text('${temp.distanceKm.toStringAsFixed(0)} km'),
                    ],
                  ),
                  Slider(
                    value: temp.distanceKm,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${temp.distanceKm.toStringAsFixed(0)} km',
                    onChanged: (v) => setState(() {
                      temp = temp.copyWith(distanceKm: v);
                    }),
                  ),
                  const SizedBox(height: 8),

                  // 日期
                  Align(alignment: Alignment.centerLeft, child: Text('日期')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final e in [
                        ('today', '今天'),
                        ('week', '本周'),
                        ('month', '本月'),
                        ('any', '不限'),
                      ])
                        ChoiceChip(
                          label: Text(e.$2),
                          selected: temp.date == e.$1,
                          onSelected: (_) => setState(() {
                            temp = temp.copyWith(date: e.$1);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 仅免费
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('仅显示免费活动'),
                    value: temp.onlyFree,
                    onChanged: (v) => setState(() {
                      temp = temp.copyWith(onlyFree: v);
                    }),
                  ),

                  // 分类
                  Align(alignment: Alignment.centerLeft, child: Text('分类')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in allCategories)
                        FilterChip(
                          label: Text(c),
                          selected: temp.categories.contains(c),
                          onSelected: (v) => setState(() {
                            final next = {...temp.categories};
                            v ? next.add(c) : next.remove(c);
                            temp = temp.copyWith(categories: next);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 操作
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          temp = const EventFilter();
                        }),
                        child: const Text('重置'),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, temp),
                        child: const Text('应用'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  final _tags = ['今天', '附近', '派对', '运动', '音乐', '免费', '热门', '朋友在'];
  final _selected = <String>{};
  // 放在 StatefulWidget 里，替换你的 AppBar 段
  final String avatarUrl = 'https://i.pravatar.cc/100?img=3';

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsProvider);
    final userLoc = ref.watch(userLocationProvider).valueOrNull;
    final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);

    return Scaffold(
      extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  toolbarHeight: 0,
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(110),
    child: SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索框（左“定位”只是图标，右头像可点）
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: Material(
              elevation: 3, // 若仍显压，可改为 3
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              surfaceTintColor: Colors.transparent,
              child: TextField(
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: '搜索活动',
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.my_location_outlined), // 纯图标
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkResponse(
                      radius: 22,
                      onTap: () {
                        // TODO: 个人页 / 侧边栏
                      },
                      child: CircleAvatar(
                        radius: 16,
                        foregroundImage: NetworkImage(avatarUrl),
                        child: const Icon(Icons.person, size: 18),
                      ),
                    ),
                  ),
                ),
                onSubmitted: (kw) => debugPrint('搜索: $kw'),
              ),
            ),
          ),

          const SizedBox(height: 8), // 关键：给阴影留“呼吸”空间

          // 标签 + 筛选
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ..._tags.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        visualDensity: VisualDensity.compact, //视觉更轻：给 ChoiceChip 用 visualDensity: VisualDensity.compact（可选）。
                        label: Text(t),
                        selected: _selected.contains(t),
                        onSelected: (v) => setState(() {
                          v ? _selected.add(t) : _selected.remove(t);
                          // TODO: 触发筛选逻辑
                        }),
                      ),
                    )),
                const SizedBox(width: 4),
                OutlinedButton.icon(
                  icon: const Icon(Icons.tune),
                  label: const Text('筛选'),
                  onPressed: () async {
                    final res = await showEventFilterSheet(
                        context, _filter, _allCategories);
                    if (res != null) {
                      setState(() => _filter = res);
                      // TODO: 刷新地图/列表
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
