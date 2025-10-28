import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWithPlannerSheetPage extends StatefulWidget {
  const MapWithPlannerSheetPage({super.key});

  @override
  State<MapWithPlannerSheetPage> createState() => _MapWithPlannerSheetPageState();
}

class _MapWithPlannerSheetPageState extends State<MapWithPlannerSheetPage>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late final TabController _tab;
  final _sheetCtrl = DraggableScrollableController();

  // 面板配置
  static const double _min = 0.12;   // 折叠高度（占屏高比例）
  static const double _init = 0.18;  // 初始高度
  static const double _max = 0.9;    // 最大高度

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _sheetCtrl.addListener(_updateMapPadding);
  }

  @override
  void dispose() {
    _sheetCtrl.removeListener(_updateMapPadding);
    _tab.dispose();
    super.dispose();
  }

  void _updateMapPadding() {
    if (_mapController == null) return;
    final h = MediaQuery.of(context).size.height;
    final extent = _sheetCtrl.size.clamp(_min, _max);
    final bottomPadding = (extent * h) + 12; // 给地图控件让出空间
    // _mapController!.setPadding(0, 0, 0, bottomPadding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 地图层
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(45.4841, 9.1839), // Milan
              zoom: 14,
            ),
            onMapCreated: (c) {
              _mapController = c;
              _updateMapPadding();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // 用自定义悬浮按钮
            compassEnabled: false,
            zoomControlsEnabled: false,
          ),

          // 悬浮操作（定位 / 筛选）
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _fab(Icons.my_location, onTap: () {/* 定位到我 */}),
                const SizedBox(height: 12),
                _fab(Icons.tune, onTap: () {/* 打开筛选 */}),
              ],
            ),
          ),

          // 可拖拽底部面板
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              _updateMapPadding();
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetCtrl,
              minChildSize: _min,
              initialChildSize: _init,
              maxChildSize: _max,
              snap: true,
              snapSizes: const [_min, 0.35, 0.6, _max],
              builder: (context, scrollController) {
                return Material(
                  elevation: 12,
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Tab 头
                      TabBar(
                        controller: _tab,
                        labelColor: Colors.teal[700],
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: Colors.teal,
                        tabs: const [
                          Tab(text: 'Connection'),
                          Tab(text: 'Station / Location'),
                        ],
                      ),
                      // 内容
                      Expanded(
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            // 页 1：行程规划（示例）
                            ListView(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              children: const [
                                _PlannerTile(title: 'My Location'),
                                SizedBox(height: 12),
                                _PlannerTile(title: 'Destination Address'),
                                SizedBox(height: 32),
                                Center(child: Text('Your favoured and searched connections appear here.')),
                              ],
                            ),
                            // 页 2：站点/地点
                            ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: 20,
                              itemBuilder: (_, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _PlannerTile(title: 'Place #$i'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // 底部导航（示例）
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Tickets'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }

  Widget _fab(IconData icon, {VoidCallback? onTap}) {
    return Material(
      shape: const CircleBorder(),
      elevation: 6,
      color: Colors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}

class _PlannerTile extends StatelessWidget {
  final String title;
  const _PlannerTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
