import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/core/state/legal/disclaimer_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/disclaimer_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/event.dart';
import '../../data/event_filter.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/di/providers.dart';
import '../../../../core/state/event_map_state/events_providers.dart';
import '../../../../core/state/event_map_state/location_provider.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'sheets/event_filter_sheet.dart';
import 'sheets/event_bottom_sheet.dart';
import 'sheets/create_event_sheet.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _map = MapController();
  bool _movedToSelected = false;
  final _allCategories = const ['派对', '运动', '音乐', '户外', '学习', '展览', '美食'];
  static const _quickTags = [
    'today',
    'nearby',
    'party',
    'sports',
    'music',
    'free',
    'trending',
    'friends',
  ];
  final _selectedTags = <String>{};

  // 搜索框
  final _searchController = TextEditingController();
  late final FocusNode _searchFocusNode;
  late final ApiService _api;
  EventFilter _filter = const EventFilter();
  List<Event> _searchResults = const <Event>[];
  bool _isSearching = false;
  bool _showSearchResults = false;
  String? _searchError;
  String _currentSearchQuery = '';
  Timer? _searchDebounce;
  ProviderSubscription<Event?>? _mapFocusSubscription;

  @override
  void initState() {
    super.initState();
    _api = ref.read(apiServiceProvider);
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _mapFocusSubscription = ref.listenManual(
      mapFocusEventProvider,
      (previous, next) {
        final event = next;
        if (event == null) {
          return;
        }
        _focusOnEvent(event);
        ref.read(mapFocusEventProvider.notifier).state = null;
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapFocusSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // 跟随定位（只在无选中事件时）
    ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (prev, next) {
      final loc = next.value;
      if (!_movedToSelected && widget.selectedEvent == null && loc != null) {
        _map.move(loc, 14);
      }
    });

    final events = ref.watch(eventsProvider);
    final userLoc = ref.watch(userLocationProvider).value;
    final startCenter = userLoc ?? const LatLng(48.8566, 2.3522);

    // 页面首帧跳转至选中事件,如果有选中事件，页面初始化时直接跳过去
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedEvent != null && !_movedToSelected) {
        _focusOnEvent(widget.selectedEvent!);
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true, // 关键：让地图顶到状态栏
      appBar: SearchEventAppBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onSearch: _onSearchSubmitted,
        onChanged: _onQueryChanged,
        onClear: _onSearchClear,
        onAvatarTap: _onAvatarTap,
        tags: _quickTags,
        selected: _selectedTags,
        onTagToggle: (t, v) => setState(() {
          v ? _selectedTags.add(t) : _selectedTags.remove(t);
          // TODO: 将标签映射到 _filter 并刷新 Provider
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
        }),
        onOpenFilter: () async {
          final res = await showEventFilterSheet(
            context: context,
            initial: _filter,
            allCategories: _allCategories,
          );
          if (res != null) setState(() => _filter = res);
          // TODO: 根据 _filter 刷新数据
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
        },
        onResultTap: _onSearchResultTap,
        showResults: _showSearchResults,
        isLoading: _isSearching,
        results: _searchResults,
        errorText: _searchError,
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
          } else if (_showSearchResults) {
            setState(() => _showSearchResults = false);
          }
        },
        child: MapCanvas(
          mapController: _map,
          initialCenter: startCenter,
          onMapReady: () {
            final loc = ref.read(userLocationProvider).value;
            if (!_movedToSelected && loc != null) _map.move(loc, 14);
          },
          onLongPress: _onMapLongPress,
          children: [
            // OSM图层已内置在 MapCanvas 里，这里只放标记层
            events.when(
              loading: () => const MarkersLayer(markers: []),
              error: (_, __) => const MarkersLayer(markers: []),
              data: (list) => MarkersLayer.fromEvents(
                events: list,
                userLoc: userLoc,
                onEventTap: _showEventCard,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 120 + MediaQuery.of(context).viewPadding.bottom,
          right: 6,
        ),
        child: FloatingActionButton(
          onPressed: () {
            final loc = ref.read(userLocationProvider).value;
            if (loc != null) {
              _map.move(loc, 14);
              _map.rotate(0);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Unable to get location")));
            }
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }

  Future<void> _onMapLongPress(TapPosition _, LatLng latlng) async {
    if (!await _ensureNetworkAvailable()) {
      return;
    }

    if (!await _ensureDisclaimerAccepted()) {
      return;
    }

    final data = await showCreateEventBottomSheet(context, latlng);
    if (data == null || data.title.trim().isEmpty) return;

    await ref.read(eventsProvider.notifier).createEvent(
          title: data.title.trim(),
          description: data.description.trim(),
          pos: latlng,
          locationName: data.locationName,
        );
  }

  Future<bool> _ensureNetworkAvailable() async {
    bool hasConnection = false;

    try {
      final result = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 3));
      hasConnection = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      hasConnection = false;
    } on TimeoutException {
      hasConnection = false;
    } catch (_) {
      hasConnection = false;
    }

    if (!mounted) {
      return hasConnection;
    }

    if (!hasConnection) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('网络未连接')));
      return false;
    }

    return true;
  }

  void _showEventCard(Event ev) {
    if (!mounted) {
      return;
    }
    showEventBottomSheet(
      context: context,
      event: ev,
      onShowOnMap: _focusOnEvent,
    );
  }

  void _focusOnEvent(Event event) {
    if (!mounted) {
      return;
    }
    _map.move(LatLng(event.latitude, event.longitude), 14);
    _movedToSelected = true;
    _map.rotate(0);
    _showEventCard(event);
  }

  void _onAvatarTap(bool authed) {
    if (authed) {
      Navigator.pushNamed(context, '/profile');
    } else {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Future<bool> _ensureDisclaimerAccepted() async {
    final state = await ref.read(disclaimerStateProvider.future);
    if (!mounted) {
      return false;
    }
    if (!state.needsReconsent || state.toShow == null) {
      return true;
    }

    final accept = ref.read(acceptDisclaimerProvider);
    final acknowledged = await showDisclaimerBottomSheet(
      context: context,
      d: state.toShow!,
      onAccept: () => accept(state.toShow!.version),
    );

    return acknowledged;
  }

  Future<bool> _ensureNetworkAvailable() async {
    const offlineMessage = 'No internet connection detected.';
    final host = Uri.parse(Env.current).host;
    var lookupHost = host;

    if (lookupHost.isEmpty) {
      debugPrint(
        'Env.current host is empty; falling back to example.com for connectivity checks.',
      );
      lookupHost = 'example.com';
    }

    if (lookupHost.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(offlineMessage)),
        );
      }
      return false;
    }

    try {
      final result = await InternetAddress.lookup(lookupHost);
      final hasConnection =
          result.isNotEmpty && result.first.rawAddress.isNotEmpty;

      if (!hasConnection && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(offlineMessage)),
        );
      }

      return hasConnection;
    } on SocketException catch (error) {
      debugPrint('Network check failed for $lookupHost: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(offlineMessage)),
        );
      }
      return false;
    }
  }

  /// 搜索框事件
  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      _searchDebounce?.cancel();
      if (_showSearchResults) {
        setState(() => _showSearchResults = false);
      }
      return;
    }

    final text = _searchController.text.trim();
    if (text.isEmpty) {
      if (_showSearchResults) {
        setState(() => _showSearchResults = false);
      }
      return;
    }

    if (_searchResults.isNotEmpty || _isSearching || _searchError != null) {
      setState(() => _showSearchResults = true);
    } else {
      _triggerSearch(text);
    }
  }

  void _onQueryChanged(String raw) {
    _triggerSearch(raw);
  }

  void _triggerSearch(String raw, {bool immediate = false}) {
    final query = raw.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    setState(() {
      _currentSearchQuery = query;
      _showSearchResults = true;
      _isSearching = true;
      _searchError = null;
    });

    if (immediate) {
      _performSearch(query);
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 350), () {
        _performSearch(query);
      });
    }
  }

  void _onSearchSubmitted(String keyword) {
    _triggerSearch(keyword, immediate: true);
  }

  Future<void> _performSearch(String keyword) async {
    final query = keyword.trim();
    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    try {
      final data = await _api.searchEvents(query);
      if (!mounted || _currentSearchQuery != query) return;
      setState(() {
        _searchResults = data;
      });
    } on ApiException catch (e) {
      if (!mounted || _currentSearchQuery != query) return;
      setState(() {
        _searchResults = const <Event>[];
        _searchError = e.message;
      });
    } finally {
      if (mounted && _currentSearchQuery == query) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchClear() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _clearSearchResults();
  }

  void _onSearchResultTap(Event event) {
    FocusScope.of(context).unfocus();
    setState(() {
      _showSearchResults = false;
      _searchResults = const <Event>[];
      _searchError = null;
      _currentSearchQuery = '';
      _searchController.text = event.title;
    });
    _map.move(LatLng(event.latitude, event.longitude), 15);
    _showEventCard(event);
  }

  void _clearSearchResults() {
    setState(() {
      _searchResults = const <Event>[];
      _searchError = null;
      _showSearchResults = false;
      _isSearching = false;
      _currentSearchQuery = '';
    });
  }
}
