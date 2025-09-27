import 'dart:async';
import 'dart:ui';

import 'package:crew_app/core/state/legal/disclaimer_providers.dart';
import 'package:crew_app/features/chat/user_event/prestantion/user_events_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/disclaimer_dialog.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/events/presentation/list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';

// class App extends StatefulWidget {
//   const App({super.key});
//   @override
//   State<App> createState() => _AppState();
// }

// class _AppState extends State<App> {
//   int _index = 1; // 默认打开“地图”
//   final List<Widget> _pages = const [
//     EventsListPage(),
//     EventsMapPage(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;
//     return Scaffold(
//       body: IndexedStack(index: _index, children: _pages),
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _index,
//         onDestinationSelected: (i) => setState(() => _index = i),
//         destinations: [
//           NavigationDestination(icon: Icon(Icons.event), label: loc.events),
//           NavigationDestination(icon: Icon(Icons.map), label: loc.map),
//           const NavigationDestination(
//               icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//       extendBody: true,  // 是否延伸到 bottomNavigationBar 背后 适合做半透明效果，比如底部做玻璃罩
//     );
//   }
// }


/// 添加免责声明，缺测试
class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 1; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  late final List<Widget> _pages;
  int? _promptedVersion; // 防止同一版本重复弹

  @override
  void initState() {
    super.initState();
    _pages = [
      ScrollActivityListener(
        onScrollActivityChanged: _handleScrollActivity,
        child: const EventsListPage(),
      ),
      ScrollActivityListener(
        onScrollActivityChanged: _handleScrollActivity,
        listenToPointerActivity: true,
        child: const EventsMapPage(),
      ),
      ScrollActivityListener(
        onScrollActivityChanged: _handleScrollActivity,
        child: const UserEventsPage(),
      ),
    ];
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  void _handleScrollActivity(bool scrolling) {
    _scrollDebounceTimer?.cancel();
    if (scrolling) {
      if (!_isScrolling) {
        setState(() => _isScrolling = true);
      }
      return;
    }

    _scrollDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      if (_isScrolling) {
        setState(() => _isScrolling = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // 监听放在 build 内，交给 Riverpod 管
    ref.listen<AsyncValue<DisclaimerState>>(disclaimerStateProvider,
        (prev, next) {
      final s = next.asData?.value;
      if (s == null || !s.needsReconsent) return;

      final ver = s.toShow.version;
      if (_promptedVersion == ver) return; // 已经弹过了
      _promptedVersion = ver;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final accept = ref.read(acceptDisclaimerProvider);
        await showDisclaimerDialog(
          context: context,
          d: s.toShow,
          onAccept: () => accept(ver),
        );
      });
    });

    final legal = ref.watch(disclaimerStateProvider);
    if (legal.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(32),
      topRight: Radius.circular(32),
      bottomLeft: Radius.circular(40),
      bottomRight: Radius.circular(40),
    );
    final glassBorderColor = colorScheme.outline.withOpacity(0.14);
    final glassDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.surface.withOpacity(0.65),
          colorScheme.surfaceVariant.withOpacity(0.45),
        ],
      ),
      borderRadius: borderRadius,
      border: Border.all(color: glassBorderColor),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 18),
        ),
      ],
    );
    final solidDecoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 28),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 0.88,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  decoration: _isScrolling ? glassDecoration : solidDecoration,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: NavigationBarTheme(
                    data: theme.navigationBarTheme.copyWith(
                      backgroundColor: Colors.transparent,
                      height: 64,
                      indicatorColor: colorScheme.primary.withOpacity(0.18),
                      indicatorShape: const StadiumBorder(),
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      labelTextStyle: MaterialStateProperty.resolveWith(
                        (states) => theme.textTheme.labelMedium?.copyWith(
                          fontWeight: states.contains(MaterialState.selected)
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: states.contains(MaterialState.selected)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      iconTheme: MaterialStateProperty.resolveWith(
                        (states) => IconThemeData(
                          size: states.contains(MaterialState.selected)
                              ? 30
                              : 26,
                          color: states.contains(MaterialState.selected)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedIndex: _index,
                      onDestinationSelected: (i) =>
                          setState(() => _index = i),
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.event_outlined),
                          selectedIcon: const Icon(Icons.event),
                          label: loc.events,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.map_outlined),
                          selectedIcon: const Icon(Icons.map),
                          label: loc.map,
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.chat_bubble_outline),
                          selectedIcon: Icon(Icons.chat_bubble),
                          label: 'Group',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
