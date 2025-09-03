// import 'package:crew_app/features/events/data/event.dart';
// import 'package:crew_app/features/events/data/event_data.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import '../../../../core/network/api_service.dart';

// class EventsMapPage extends StatefulWidget {
//   final Event? selectedEvent;
    
//   const EventsMapPage({super.key, this.selectedEvent});

//   @override
//   EventsMapPageState createState() => EventsMapPageState();
// }

// class EventsMapPageState extends State<EventsMapPage> {
//   final ApiService api = ApiService();
//   List<Marker> markers = [];
//   List<Event> events = [];
//   final MapController _mapController = MapController();
//   LatLng? userLocation;
//   bool movedToSelected = false; // 标记是否已经跳到搜索结果

//   @override
//   void initState() {
//     super.initState();
//     _loadEvents();
//     _determinePosition(); // 获取用户当前位置

//     // 如果从搜索跳转过来，地图先跳到选中的Event位置
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (widget.selectedEvent != null) {
//         final ev = widget.selectedEvent!;
//         final target = LatLng(ev.latitude, ev.longitude);
//         _mapController.move(target, 15); // 移动地图到目标位置
//         _showEventDetails(ev); // 弹出详情BottomSheet
//         movedToSelected = true;
//       }
//     });
//   }

//   Future<void> _loadEvents() async {
//     final data = await api.getEvents();
//     setState(() {
//       events = data;
//       markers = events.map((ev) {
//         return Marker(
//           width: 80,
//           height: 80,
//           point: LatLng(ev.latitude, ev.longitude),
//           child: GestureDetector(
//             onTap: () => _showEventDetails(ev),
//             child: Icon(Icons.location_pin, color: Colors.red, size: 40),
//           ),
//         );
//       }).toList();
//     });
//   }

//   // 获取用户定位
//   Future<void> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // 检查是否启用位置服务
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('请开启位置服务')),
//       );
//       return;
//     }

//     // 检查权限
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('位置权限被拒绝')),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('位置权限被永久拒绝，请在设置中开启')),
//       );
//       return;
//     }

//     // 获取当前位置
//     final position = await Geolocator.getCurrentPosition();
//     if (!mounted) return; // widget 可能已销毁
//     setState(() {
//       userLocation = LatLng(position.latitude, position.longitude);
//     });

//     // 打开地图的时候将地图移动到当前位置，以及只有当没有跳转到搜索结果时，才自动移到用户位置
//     if (!movedToSelected && userLocation != null) {
//       _mapController.move(userLocation!, 14);
//     }
//   }

//   void _showEventDetails(Event ev) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(ev.title,
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text(ev.description, style: TextStyle(fontSize: 16)),
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.location_on, color: Colors.grey),
//                   SizedBox(width: 5),
//                   Text("Lat: ${ev.latitude}, Lng: ${ev.longitude}"),
//                 ],
//               ),
//               SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("报名功能还没做 😅")),
//                   );
//                 },
//                 icon: Icon(Icons.check_circle),
//                 label: Text("报名参加"),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _onMapLogPress(TapPosition tapPosition, LatLng latlng) async {
//     final eventData = await _showCreateEventDialog(latlng);

//     if (eventData != null && eventData.title.isNotEmpty) {
//       // 通过经纬度获取城市或省份
//       String locationName = "Unknown";
//       try {
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           latlng.latitude, latlng.longitude,
//         );
//         if (placemarks.isNotEmpty) {
//           // city 或 subAdministrativeArea 作为大区/城市
//           locationName = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "Unknown";
//         }
//       } catch (e) {
//         debugPrint("无法获取位置名称: $e");
//       }

//       final newEvent = await api.createEvent(
//         eventData.title,
//         locationName,
//         eventData.description, // 使用描述
//         latlng.latitude,
//         latlng.longitude,
//       );

//       setState(() {
//         markers.add(Marker(
//           width: 80,
//           height: 80,
//           point: LatLng(newEvent.latitude, newEvent.longitude),
//           child: Icon(Icons.location_pin,
//               color: const Color.fromARGB(255, 68, 243, 33), size: 40),
//         ));
//       });
//     }
//   }

//   Future<EventData?> _showCreateEventDialog(LatLng pos) {
//     final eventController = TextEditingController();
//     final eventDescriptionController = TextEditingController();

//     return showDialog<EventData>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Create Event",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(
//             // 添加滚动支持
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "位置: ${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}",
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//                 SizedBox(height: 16),
//                 TextField(
//                   controller: eventController,
//                   decoration: InputDecoration(
//                     labelText: "活动标题",
//                     border: OutlineInputBorder(),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                   ),
//                   textInputAction: TextInputAction.next,
//                 ),
//                 SizedBox(height: 12),
//                 TextField(
//                   controller: eventDescriptionController,
//                   decoration: InputDecoration(
//                     labelText: "活动描述",
//                     border: OutlineInputBorder(),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                   ),
//                   maxLines: 3,
//                   keyboardType: TextInputType.multiline,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text("取消", style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (eventController.text.trim().isEmpty) {
//                   // 添加简单的验证
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("请输入活动标题")),
//                   );
//                   return;
//                 }

//                 Navigator.of(context).pop(EventData(
//                   title: eventController.text.trim(),
//                   description: eventDescriptionController.text.trim(),
//                 ));
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Theme.of(context).primaryColor,
//               ),
//               child: Text("创建"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final startCenter = userLocation ?? LatLng(48.8566, 2.3522); // 默认巴黎，如果没有用户坐标，作为地图视觉中心
//     return Scaffold(
//       body: FlutterMap(
//         mapController: _mapController,
//         options: MapOptions(
//           initialCenter: startCenter,
//           initialZoom: 5,
//           onLongPress: _onMapLogPress,
//           onMapReady: () {
//             if (!movedToSelected && userLocation != null) {    // 同样加判断，避免覆盖搜索跳转
//               _mapController.move(userLocation!, 14);
//             }
//           },
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//             userAgentPackageName: 'com.example.crewapp',
//           ),
//           MarkerLayer(markers: [
//             ...markers,
//             if (userLocation != null)
//               Marker(
//                 point: userLocation!,
//                 width: 80,
//                 height: 80,
//                 child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
//               ),
//           ]),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.my_location),
//         onPressed: () {
//           // 点击按钮时，用户主动触发，可以移动地图到当前坐标
//           if (userLocation != null) {
//             _mapController.move(userLocation!, 14);
//           } 
//         },
//       ),
//     );
//   }
// }

// /*
// // 在 TileLayer 的 urlTemplate 中使用不同的URL：

// // 1. 标准OSM地图
// urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

// // 2. 深色主题
// urlTemplate: 'https://tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png',

// // 3. 地形图
// urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',

// // 4. 自行车地图
// urlTemplate: 'https://tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',

// // 5. 航海图
// urlTemplate: 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',

// */