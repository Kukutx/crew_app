// lib/app/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  // 用 record 定义 Tab：第一个是 IconData，第二个是 label
  static const _tabs = [
    (Icons.event, 'Events'),
    (Icons.map, 'Map'),
    (Icons.search, 'Search'),
    (Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      // ✅ navigationShell 自带 IndexedStack + 各分支 Navigator
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          navigationShell.goBranch(i, initialLocation: true);
        },
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.$1), label: t.$2))
            .toList(),
      ),
    );
  }
}
