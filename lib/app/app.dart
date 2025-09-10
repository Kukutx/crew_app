import 'package:flutter/material.dart';
import '../features/events/presentation/list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';
import '../features/events/presentation/search_events_page.dart';
import '../features/profile/presentation/profile_page.dart';

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 1; // 默认打开“地图”
  final List<Widget> _pages = const [
    EventsListPage(),
    EventsMapPage(),
    SearchEventsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event),  label: 'Events'),
          NavigationDestination(icon: Icon(Icons.map),    label: 'Map'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // extendBody: true, 
    );
  }
}
