// import 'package:crew_app/core/state/event_map_state/events_providers.dart';
// import 'package:crew_app/core/state/event_map_state/location_provider.dart';
// import 'package:crew_app/features/events/data/event_filter.dart';
// import 'package:crew_app/features/events/presentation/events_detail_page.dart';
// import 'package:firebase_auth/firebase_auth.dart' as fa;
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:latlong2/latlong.dart';
// import '../../data/event.dart';
// import '../../data/event_data.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class EventsMapPage extends ConsumerStatefulWidget {
//   final Event? selectedEvent;
//   const EventsMapPage({super.key, this.selectedEvent});

//   @override
//   ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
// }

// class _EventsMapPageState extends ConsumerState<EventsMapPage> {
//   final _map = MapController();
//   bool movedToSelected = false;

//   final List<String> _allCategories = [
//     '派对',
//     '运动',
//     '音乐',
//     '户外',
//     '学习',
//     '展览',
//     '美食'
//   ];

//   final _tags = ['今天', '附近', '派对', '运动', '音乐', '免费', '热门', '朋友在'];
//   final _selected = <String>{};
//   EventFilter _filter = const EventFilter();
//   fa.User? _user;

//   @override
//   void initState() {
//     super.initState();
//     _user = fa.FirebaseAuth.instance.currentUser;
//     // 监听用户状态变化
//     fa.FirebaseAuth.instance.authStateChanges().listen((user) {
//       if (mounted) {
//         setState(() {
//           _user = user;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 用 ref.listen 来监听 userLocationProvider
//     ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (prev, next) {
//       final loc = next.valueOrNull;
//       if (!movedToSelected && widget.selectedEvent == null && loc != null) {
//         _map.move(loc, 14);
//       }
//     });

//     final events = ref.watch(eventsProvider);
//     final userLoc = ref.watch(userLocationProvider).valueOrNull;
//     final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);

//     // 如果有选中事件，页面初始化时直接跳过去
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.selectedEvent != null && !movedToSelected) {
//         final ev = widget.selectedEvent!;
//         _map.move(LatLng(ev.latitude, ev.longitude), 15);
//         _showEventCard(ev);
//         movedToSelected = true;
//       }
//     });

//     return Scaffold(
//       extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         toolbarHeight: 0,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(110),
//           child: SafeArea(
//             bottom: false,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 搜索框（左“定位”只是图标，右头像可点）
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//                   child: Material(
//                     elevation: 3, // 若仍显压，可改为 3
//                     borderRadius: BorderRadius.circular(24),
//                     clipBehavior: Clip.antiAlias,
//                     surfaceTintColor: Colors.transparent,
//                     child: TextField(
//                       textInputAction: TextInputAction.search,
//                       decoration: InputDecoration(
//                         hintText: '搜索活动',
//                         filled: true,
//                         fillColor: Colors.white,
//                         isDense: true,
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 10),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(24),
//                           borderSide: BorderSide.none,
//                         ),
//                         prefixIcon:
//                             const Icon(Icons.my_location_outlined), // 纯图标
//                         suffixIconConstraints:
//                             const BoxConstraints(minWidth: 44, minHeight: 44),
//                         suffixIcon: Padding(
//                           padding: const EdgeInsets.only(right: 6),
//                           child: InkResponse(
//                             radius: 22,
//                             onTap: _onAvatarTap,
//                             child: _buildAvatar(),
//                           ),
//                         ),
//                       ),
//                       onSubmitted: (kw) => debugPrint('搜索: $kw'),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 8), // 关键：给阴影留“呼吸”空间

//                 // 标签 + 筛选
//                 SizedBox(
//                   height: 44,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     children: [
//                       ..._tags.map((t) => Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: ChoiceChip(
//                               visualDensity: VisualDensity
//                                   .compact, //视觉更轻：给 ChoiceChip 用 visualDensity: VisualDensity.compact（可选）。
//                               label: Text(t),
//                               selected: _selected.contains(t),
//                               onSelected: (v) => setState(() {
//                                 v ? _selected.add(t) : _selected.remove(t);
//                                 // TODO: 触发筛选逻辑
//                               }),
//                             ),
//                           )),
//                       const SizedBox(width: 4),
//                       OutlinedButton.icon(
//                         icon: const Icon(Icons.tune),
//                         label: const Text('筛选'),
//                         onPressed: () async {
//                           final res = await showEventFilterSheet(
//                               context, _filter, _allCategories);
//                           if (res != null) {
//                             setState(() => _filter = res);
//                             // TODO: 刷新地图/列表
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: FlutterMap(
//         mapController: _map,
//         options: MapOptions(
//           initialCenter: startCenter,
//           initialZoom: 5,
//           onLongPress: _onMapLongPress,
//           onMapReady: () {
//             if (!movedToSelected && userLoc != null) {
//               _map.move(userLoc, 14);
//             }
//           },
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//             userAgentPackageName: 'com.example.crewapp',
//             tileProvider: NetworkTileProvider(), // 禁用磁盘缓存（如果不需要可删）
//           ),
//           events.when(
//             loading: () => const MarkerLayer(markers: []),
//             error: (_, __) => const MarkerLayer(markers: []),
//             data: (list) => MarkerLayer(
//               markers: [
//                 ...list.map((ev) => Marker(
//                       width: 80,
//                       height: 80,
//                       point: LatLng(ev.latitude, ev.longitude),
//                       child: GestureDetector(
//                         onTap: () => _showEventCard(ev),
//                         child: const Icon(Icons.location_pin,
//                             color: Colors.red, size: 40),
//                       ),
//                     )),
//                 if (userLoc != null)
//                   Marker(
//                     point: userLoc,
//                     width: 80,
//                     height: 80,
//                     child: const Icon(Icons.location_pin,
//                         color: Colors.blue, size: 40),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           final loc = ref.read(userLocationProvider).valueOrNull;
//           if (loc != null) {
//             _map.move(loc, 14);
//             _map.rotate(0);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('无法获取定位')),
//             );
//           }
//         },
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }

//   /// 地图创建事件
//   Future<void> _onMapLongPress(TapPosition _, LatLng latlng) async {
//     final data = await _showCreateEventDialog(latlng);
//     if (data == null || data.title.trim().isEmpty) return;

//     // 反地理编码（容错）
//     String locationName = 'Unknown';
//     try {
//       final list =
//           await placemarkFromCoordinates(latlng.latitude, latlng.longitude)
//               .timeout(const Duration(seconds: 5));
//       if (list.isNotEmpty) {
//         locationName = list.first.locality ??
//             list.first.subAdministrativeArea ??
//             'Unknown';
//       }
//     } catch (_) {}

//     await ref.read(eventsProvider.notifier).createEvent(
//           title: data.title.trim(),
//           description: data.description.trim(),
//           pos: latlng,
//           locationName: locationName,
//         );
//   }

//   Future<EventData?> _showCreateEventDialog(LatLng pos) {
//     final title = TextEditingController();
//     final desc = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     return showDialog<EventData>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Create Event'),
//         content: Form(
//           key: formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                     '位置: ${pos.latitude.toStringAsFixed(6)}, '
//                     '${pos.longitude.toStringAsFixed(6)}',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: title,
//                   decoration: const InputDecoration(
//                       labelText: '活动标题', border: OutlineInputBorder()),
//                   validator: (v) =>
//                       (v == null || v.trim().isEmpty) ? '请输入活动标题' : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: desc,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                       labelText: '活动描述', border: OutlineInputBorder()),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('取消'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (formKey.currentState?.validate() != true) return;
//               Navigator.pop(context,
//                   EventData(title: title.text, description: desc.text));
//             },
//             child: const Text('创建'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// 地图搜索事件
//   Future<EventFilter?> showEventFilterSheet(
//     BuildContext context,
//     EventFilter initial,
//     List<String> allCategories,
//   ) {
//     return showModalBottomSheet<EventFilter>(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       showDragHandle: true,
//       builder: (ctx) {
//         var temp = initial;
//         return StatefulBuilder(
//           builder: (ctx, setState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 left: 16,
//                 right: 16,
//                 top: 8,
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // 距离
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('距离'),
//                       Text('${temp.distanceKm.toStringAsFixed(0)} km'),
//                     ],
//                   ),
//                   Slider(
//                     value: temp.distanceKm,
//                     min: 1,
//                     max: 50,
//                     divisions: 49,
//                     label: '${temp.distanceKm.toStringAsFixed(0)} km',
//                     onChanged: (v) => setState(() {
//                       temp = temp.copyWith(distanceKm: v);
//                     }),
//                   ),
//                   const SizedBox(height: 8),

//                   // 日期
//                   Align(alignment: Alignment.centerLeft, child: Text('日期')),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       for (final e in [
//                         ('today', '今天'),
//                         ('week', '本周'),
//                         ('month', '本月'),
//                         ('any', '不限'),
//                       ])
//                         ChoiceChip(
//                           label: Text(e.$2),
//                           selected: temp.date == e.$1,
//                           onSelected: (_) => setState(() {
//                             temp = temp.copyWith(date: e.$1);
//                           }),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // 仅免费
//                   SwitchListTile(
//                     contentPadding: EdgeInsets.zero,
//                     title: const Text('仅显示免费活动'),
//                     value: temp.onlyFree,
//                     onChanged: (v) => setState(() {
//                       temp = temp.copyWith(onlyFree: v);
//                     }),
//                   ),

//                   // 分类
//                   Align(alignment: Alignment.centerLeft, child: Text('分类')),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       for (final c in allCategories)
//                         FilterChip(
//                           label: Text(c),
//                           selected: temp.categories.contains(c),
//                           onSelected: (v) => setState(() {
//                             final next = {...temp.categories};
//                             v ? next.add(c) : next.remove(c);
//                             temp = temp.copyWith(categories: next);
//                           }),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   // 操作
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () => setState(() {
//                           temp = const EventFilter();
//                         }),
//                         child: const Text('重置'),
//                       ),
//                       const Spacer(),
//                       OutlinedButton(
//                         onPressed: () => Navigator.pop(ctx, null),
//                         child: const Text('取消'),
//                       ),
//                       const SizedBox(width: 8),
//                       FilledButton(
//                         onPressed: () => Navigator.pop(ctx, temp),
//                         child: const Text('应用'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildAvatar() {
//     final photo = _user?.photoURL;
//     if (photo != null && photo.isNotEmpty) {
//       return CircleAvatar(
//         radius: 16,
//         backgroundColor: Colors.grey.shade200,
//         foregroundImage: NetworkImage(photo),
//         onForegroundImageError: (_, __) {}, // 加载失败 → 会显示 child
//         child: const Icon(Icons.person, size: 18),
//       );
//     }
//     return const CircleAvatar(
//       radius: 16,
//       child: Icon(Icons.person, size: 18),
//     );
//   }

//   void _onAvatarTap() {
//     if (_user != null) {
//       Navigator.pushNamed(context, '/profile');
//     } else {
//       Navigator.pushNamed(context, '/login');
//     }
//   }

//   /// 地图报名页事件
//   void _showEventCard(Event ev) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => DraggableScrollableSheet(
//         initialChildSize: 0.28,
//         minChildSize: 0.2,
//         maxChildSize: 0.7,
//         expand: false,
//         builder: (_, controller) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
//             ),
//             padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
//             child: ListView(
//               controller: controller,
//               children: [
//                 // 卡片
//                 Material(
//                   color: Colors.white,
//                   elevation: 0,
//                   borderRadius: BorderRadius.circular(12),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 缩略图
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: SizedBox(
//                           width: 96,
//                           height: 96,
//                           child: CachedNetworkImage(
//                             imageUrl: /* ev.coverAsset ?? */
//                                 'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66', // 默认图地址
//                             fit: BoxFit.cover,
//                             placeholder: (context, url) => const Center(
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                             errorWidget: (context, url, error) => const Center(
//                               child: Icon(Icons.error),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       // 文本区
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // 标题 + 收藏
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.pop(context); // 先收起
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) =>
//                                               EventDetailPage(event: ev),
//                                         ),
//                                       );
//                                     },
//                                     child: Text(
//                                       ev.title,
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 IconButton(
//                                   visualDensity: VisualDensity.compact,
//                                   icon: const Icon(Icons.favorite_border),
//                                   onPressed: () {}, // TODO: 收藏
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 const Icon(Icons.place,
//                                     size: 16, color: Colors.grey),
//                                 const SizedBox(width: 4),
//                                 Expanded(
//                                   child: Text(
//                                     ev.location,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style:
//                                         const TextStyle(color: Colors.black54),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 _smallChip('正在报名中'),
//                                 const SizedBox(width: 6),
//                                 const Icon(Icons.groups,
//                                     size: 16, color: Colors.grey),
//                                 const SizedBox(width: 2),
//                                 Text(/*ev.peopleText ?? */ '3-5人',
//                                     style:
//                                         const TextStyle(color: Colors.black54)),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             Row(
//                               children: [
//                                 const Icon(Icons.event,
//                                     size: 16, color: Colors.grey),
//                                 const SizedBox(width: 4),
//                                 Text(/*ev.timeText ??*/ '12月28日 8:00',
//                                     style:
//                                         const TextStyle(color: Colors.black87)),
//                                 const Spacer(),
//                                 SizedBox(
//                                   height: 36,
//                                   child: FilledButton(
//                                     style: FilledButton.styleFrom(
//                                       backgroundColor: Colors.orange,
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                     ),
//                                     onPressed: () {
//                                       Navigator.pop(context);
//                                       // TODO: 报名逻辑
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                             content: Text('报名功能未实现')),
//                                       );
//                                     },
//                                     child: const Text('立即报名'),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _smallChip(String text) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFE7C2),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(text,
//             style: const TextStyle(fontSize: 11, color: Colors.black87)),
//       );
// }
