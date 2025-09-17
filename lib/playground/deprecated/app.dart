// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../features/events/presentation/list/events_list_page.dart';
// import '../features/events/presentation/map/events_map_page.dart';
// import '../features/profile/presentation/profile/profile_page.dart';

// class App extends StatefulWidget {
//   const App({super.key});
//   @override
//   State<App> createState() => _AppState();
// }

// class _AppState extends State<App> {
//   static const _mapIndex = 1;

//   int _index = _mapIndex; // 默认打开“地图”
//   bool _isMapInteracting = false;

//   void _onDestinationSelected(int newIndex) {
//     if (newIndex != _mapIndex && _isMapInteracting) {
//       setState(() {
//         _index = newIndex;
//         _isMapInteracting = false;
//       });
//       return;
//     }
//     setState(() => _index = newIndex);
//   }

//   void _onMapInteractionChanged(bool active) {
//     if (_index != _mapIndex || _isMapInteracting == active) return;
//     setState(() => _isMapInteracting = active);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = [
//       const EventsListPage(),
//       EventsMapPage(onMapInteractionChanged: _onMapInteractionChanged),
//       const ProfilePage(),
//     ];
  
//     return Scaffold(
//        extendBody: true,
//       body: IndexedStack(index: _index, children: pages),
//       bottomNavigationBar: _buildNavigationBar(context),
//     );
//   }

//   Widget _buildNavigationBar(BuildContext context) {
//     final destinations = const [
//       NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
//       NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
//       NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
//     ];

//     final navBar = NavigationBar(
//       backgroundColor: _index == _mapIndex ? Colors.transparent : null,
//       selectedIndex: _index,
//       onDestinationSelected: _onDestinationSelected,
//       destinations: destinations,
//     );

//     if (_index != _mapIndex) {
//       return navBar;
//     }

//     final colorScheme = Theme.of(context).colorScheme;
//     final borderRadius = BorderRadius.circular(28);

//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 240),
//           curve: Curves.easeOutCubic,
//           decoration: BoxDecoration(
//             color: _isMapInteracting
//                 ? colorScheme.surface.withValues(alpha: .55)
//                 : colorScheme.surface,
//             borderRadius: borderRadius,
//             border: _isMapInteracting
//                 ? Border.all(color: Colors.white.withValues(alpha: 0.35))
//                 : null,
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x1A000000),
//                 blurRadius: 20,
//                 offset: Offset(0, 8),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: borderRadius,
//             child: BackdropFilter(
//               filter: ImageFilter.blur(
//                 sigmaX: _isMapInteracting ? 18 : 0,
//                 sigmaY: _isMapInteracting ? 18 : 0,
//               ),
//               child: navBar,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
