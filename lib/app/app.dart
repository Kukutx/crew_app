import 'package:crew_app/core/state/legal/disclaimer_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/disclaimer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/events/presentation/list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';
import '../features/profile/presentation/profile/profile_page.dart';

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
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.event), label: loc.events),
          NavigationDestination(icon: Icon(Icons.map), label: loc.map),
          const NavigationDestination(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // extendBody: true,  // 是否延伸到 bottomNavigationBar 背后 适合做半透明效果，比如底部做玻璃罩
    );
  }
}



// class App extends ConsumerStatefulWidget {
//   const App({super.key});
//   @override
//   ConsumerState<App> createState() => _AppState();
// }

// class _AppState extends ConsumerState<App> {
//   int _index = 1;
//   final _pages = const [EventsListPage(), EventsMapPage(), ProfilePage()];
//   int? _promptedVersion; // 防止同一版本重复弹

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;

//     // 监听放在 build 内，交给 Riverpod 管
//     ref.listen<AsyncValue<DisclaimerState>>(disclaimerStateProvider,
//         (prev, next) {
//       final s = next.asData?.value;
//       if (s == null || !s.needsReconsent) return;

//       final ver = s.toShow.version;
//       if (_promptedVersion == ver) return; // 已经弹过了
//       _promptedVersion = ver;

//       WidgetsBinding.instance.addPostFrameCallback((_) async {
//         if (!mounted) return;
//         final accept = ref.read(acceptDisclaimerProvider);
//         await showDisclaimerDialog(
//           context: context,
//           d: s.toShow,
//           onAccept: () => accept(ver),
//         );
//       });
//     });

//     final legal = ref.watch(disclaimerStateProvider);
//     if (legal.isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       body: IndexedStack(index: _index, children: _pages),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _index,
//         onDestinationSelected: (i) => setState(() => _index = i),
//         destinations: [
//           NavigationDestination(icon: const Icon(Icons.event), label: loc.events),
//           NavigationDestination(icon: const Icon(Icons.map), label: loc.map),
//           const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }
