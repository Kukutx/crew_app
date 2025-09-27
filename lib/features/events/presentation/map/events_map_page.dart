import 'dart:async';

import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../data/event.dart';
import '../../data/event_filter.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/state/event_map_state/events_providers.dart';
import '../../../../core/state/event_map_state/location_provider.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'sheets/event_filter_sheet.dart';
import 'sheets/event_bottom_sheet.dart';
import 'dialogs/create_event_dialog.dart';

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
  final _api = ApiService();
  EventFilter _filter = const EventFilter();
  List<Event> _searchResults = const <Event>[];
  bool _isSearching = false;
  bool _showSearchResults = false;
  String? _searchError;
  String _currentSearchQuery = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
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
        final ev = widget.selectedEvent!;
        _map.move(LatLng(ev.latitude, ev.longitude), 15);
        _showEventCard(ev);
        _movedToSelected = true;
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
    final data = await showCreateEventDialog(context, latlng);
    if (data == null || data.title.trim().isEmpty) return;

    await ref.read(eventsProvider.notifier).createEvent(
          title: data.title.trim(),
          description: data.description.trim(),
          pos: latlng,
          locationName: data.locationName,
        );
  }

  void _showEventCard(Event ev) {
    showEventBottomSheet(context: context, event: ev);
  }

  void _onAvatarTap(bool authed) {
    if (authed) {
      Navigator.pushNamed(context, '/profile');
    } else {
      Navigator.pushNamed(context, '/login');
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
