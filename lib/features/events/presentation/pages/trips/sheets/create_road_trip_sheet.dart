import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/trips/data/road_trip_editor_models.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_basic_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_gallery_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_host_disclaimer_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_preferences_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_route_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_story_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_team_section.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/trips/sheets/location_selection_sheets.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ===== 1) imports：把你的分段组件引入 =====

Future<void> showCreateRoadTripSheet(
  BuildContext context, {
  QuickRoadTripResult? initialRoute,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlannerSheet(initialRoute: initialRoute),
  );
}

class _PlannerSheet extends ConsumerStatefulWidget {
  const _PlannerSheet({this.initialRoute});

  final QuickRoadTripResult? initialRoute;

  @override
  ConsumerState<_PlannerSheet> createState() => _PlannerSheetState();
}

// 1) 定义 Section 锚点
enum TripSection { basic, route, team, prefs, gallery, story, disclaimer }

class _PlannerSheetState extends ConsumerState<_PlannerSheet>
    with TickerProviderStateMixin {
  final _dragCtrl = DraggableScrollableController();
  final _pageCtrl = PageController();
  bool _canSwipe = false; // 初始仅展示第一页，不可横滑

  RoadTripEditorState _editorState = const RoadTripEditorState();

  // ==== 基本信息 ====
  final _titleCtrl = TextEditingController();

  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  String? _startAddress;
  String? _destinationAddress;
  Future<String?>? _startAddressFuture;
  Future<String?>? _destinationAddressFuture;
  Future<List<NearbyPlace>>? _startNearbyFuture;
  Future<List<NearbyPlace>>? _destinationNearbyFuture;

  // ==== 路线 ====
  RoadTripRouteType _routeType = RoadTripRouteType.roundTrip;
  final List<String> _forwardWps = []; // 去程
  final List<String> _returnWps = []; // 返程

  // ==== 团队/费用 ====
  final _maxParticipantsCtrl = TextEditingController(text: '4');
  final _priceCtrl = TextEditingController();
  RoadTripPricingType _pricingType = RoadTripPricingType.free;

  // ==== 偏好 ====
  String? _carType;
  final _tagInputCtrl = TextEditingController();
  final List<String> _tags = [];

  // ==== 图集 ====
  final ImagePicker _picker = ImagePicker();

  // ==== 文案 ====
  final _storyCtrl = TextEditingController();
  final _disclaimerCtrl = TextEditingController();

  // ==== 分页顺序（除启动页） ====
  static const List<TripSection> _sectionsOrder = [
    TripSection.basic,
    TripSection.route,
    TripSection.team,
    TripSection.prefs,
    TripSection.gallery,
    TripSection.story,
    TripSection.disclaimer,
  ];
  int get _totalPages => 1 + _sectionsOrder.length;

  // ==== 必要回调 ====
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange:
          _editorState.dateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) {
      setState(() {
        _editorState = _editorState.copyWith(dateRange: picked);
      });
    }
  }

  // 点击创建
  Future<void> _onCreatePressed() async {
    // TODO: 收集数据并执行创建
    Navigator.of(context).maybePop();
  }

  void _onRouteTypeChanged(RoadTripRouteType t) {
    setState(() => _routeType = t);
    // 可选：从往返切到单程时，仅保留去程；反之保持现状
  }

  void _onAddForward() =>
      setState(() => _forwardWps.add('途经点 ${_forwardWps.length + 1}'));
  void _onRemoveForward(int i) => setState(() {
    if (i >= 0 && i < _forwardWps.length) _forwardWps.removeAt(i);
  });
  void _onReorderForward(int oldIndex, int newIndex) => setState(() {
    final item = _forwardWps.removeAt(oldIndex);
    _forwardWps.insert(newIndex, item);
  });

  void _onAddReturn() =>
      setState(() => _returnWps.add('返程点 ${_returnWps.length + 1}'));
  void _onRemoveReturn(int i) => setState(() {
    if (i >= 0 && i < _returnWps.length) _returnWps.removeAt(i);
  });
  void _onReorderReturn(int oldIndex, int newIndex) => setState(() {
    final item = _returnWps.removeAt(oldIndex);
    _returnWps.insert(newIndex, item);
  });

  void _onCarTypeChanged(String? v) => setState(() => _carType = v);
  void _onSubmitTag() {
    final t = _tagInputCtrl.text.trim();
    if (t.isNotEmpty && !_tags.contains(t)) setState(() => _tags.add(t));
    _tagInputCtrl.clear();
  }

  void _onRemoveTag(String t) => setState(() => _tags.remove(t));

  Future<void> _onPickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) {
        return;
      }
      setState(() {
        final newItems = picked
            .map((x) => RoadTripGalleryItem.file(File(x.path)))
            .toList();
        _editorState = _editorState.copyWith(
          galleryItems: [..._editorState.galleryItems, ...newItems],
        );
      });
    } on PlatformException catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack('选择图片失败，请检查权限设置');
    }
  }

  void _onRemoveImage(int i) {
    final items = _editorState.galleryItems;
    if (i < 0 || i >= items.length) {
      return;
    }
    setState(() {
      final updated = List<RoadTripGalleryItem>.of(items)..removeAt(i);
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _onSetCover(int i) {
    final items = _editorState.galleryItems;
    if (i <= 0 || i >= items.length) {
      return;
    }
    setState(() {
      final updated = List<RoadTripGalleryItem>.of(items);
      final item = updated.removeAt(i);
      updated.insert(0, item);
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 删掉：DateTimeRange? _dateRange;
  int _currentPage = 0;

  bool get _isBasicPage => _currentPage == 1; // 0是启动页，1是basic
  bool get _basicValid =>
      _titleCtrl.text.trim().isNotEmpty && _editorState.dateRange != null;

  Future<String?> _loadAddress(LatLng latLng, {required bool isStart}) {
    final manager = ref.read(locationSelectionManagerProvider);
    final future = manager.reverseGeocode(latLng);
    future.then((value) {
      if (!mounted) {
        return;
      }
      final trimmed = value?.trim();
      if (isStart) {
        setState(() {
          _startAddress = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
        });
      } else {
        setState(() {
          _destinationAddress = (trimmed == null || trimmed.isEmpty)
              ? null
              : trimmed;
        });
      }
    });
    return future;
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng latLng) {
    final manager = ref.read(locationSelectionManagerProvider);
    return manager.fetchNearbyPlaces(latLng);
  }

  Future<void> _restartSelectionFlow({required bool skipStart}) async {
    final navigator = Navigator.of(context);
    final navContext = navigator.context;
    final manager = ref.read(locationSelectionManagerProvider);
    navigator.pop();
    await Future<void>.microtask(
      () => manager.startRouteSelectionFlow(
        navContext,
        initialStart: _startLatLng,
        initialDestination: _destinationLatLng,
        skipStart: skipStart && _startLatLng != null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final initialRoute = widget.initialRoute;
    if (initialRoute != null) {
      _startLatLng = initialRoute.start;
      _destinationLatLng = initialRoute.destination;
      _startAddress = initialRoute.startAddress;
      _destinationAddress = initialRoute.destinationAddress;
      final trimmedTitle = initialRoute.title.trim();
      if (trimmedTitle.isNotEmpty) {
        _titleCtrl.text = trimmedTitle;
      }
    }
    if (_startLatLng != null) {
      final hasAddress =
          _startAddress != null && _startAddress!.trim().isNotEmpty;
      _startAddressFuture = hasAddress
          ? Future<String?>.value(_startAddress)
          : _loadAddress(_startLatLng!, isStart: true);
      _startNearbyFuture = _loadNearbyPlaces(_startLatLng!);
    }
    if (_destinationLatLng != null) {
      final hasAddress =
          _destinationAddress != null && _destinationAddress!.trim().isNotEmpty;
      _destinationAddressFuture = hasAddress
          ? Future<String?>.value(_destinationAddress)
          : _loadAddress(_destinationLatLng!, isStart: false);
      _destinationNearbyFuture = _loadNearbyPlaces(_destinationLatLng!);
    }
    _pageCtrl.addListener(() {
      final p = _pageCtrl.hasClients ? _pageCtrl.page?.round() ?? 0 : 0;
      if (p != _currentPage) setState(() => _currentPage = p);
    });
    _titleCtrl.addListener(() => setState(() {})); // 标题变更触发校验
  }

  // ==== 构建各分段页 ====
  Widget _buildSectionPage(TripSection s) {
    switch (s) {
      case TripSection.basic:
        return RoadTripBasicSection(
          titleController: _titleCtrl,
          dateRange: _editorState.dateRange,
          onPickDateRange: _pickDateRange,
        );
      case TripSection.route:
        return RoadTripRouteSection(
          routeType: _routeType,
          onRouteTypeChanged: _onRouteTypeChanged,

          forwardWaypoints: _forwardWps,
          onAddForward: _onAddForward,
          onRemoveForward: _onRemoveForward,
          onReorderForward: _onReorderForward,

          returnWaypoints: _returnWps,
          onAddReturn: _onAddReturn,
          onRemoveReturn: _onRemoveReturn,
          onReorderReturn: _onReorderReturn,
        );
      case TripSection.team:
        return RoadTripTeamSection(
          maxParticipantsController: _maxParticipantsCtrl,
          priceController: _priceCtrl,
          pricingType: _pricingType,
          onPricingTypeChanged: (v) => setState(() => _pricingType = v),
        );
      case TripSection.prefs:
        return RoadTripPreferencesSection(
          carType: _carType,
          onCarTypeChanged: _onCarTypeChanged,
          tagInputController: _tagInputCtrl,
          onSubmitTag: _onSubmitTag,
          tags: _tags,
          onRemoveTag: _onRemoveTag,
        );
      case TripSection.gallery:
        return RoadTripGallerySection(
          items: _editorState.galleryItems,
          onPickImages: _onPickImages,
          onRemoveImage: _onRemoveImage,
          onSetCover: _onSetCover,
        );
      case TripSection.story:
        return RoadTripStorySection(descriptionController: _storyCtrl);
      case TripSection.disclaimer:
        return RoadTripHostDisclaimerSection(
          disclaimerController: _disclaimerCtrl,
        );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _priceCtrl.dispose();
    _tagInputCtrl.dispose();
    _storyCtrl.dispose();
    _disclaimerCtrl.dispose();
    _dragCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // 便捷：根据锚点跳页（会跳到对应分段页）
  Future<void> goToSection(TripSection s) async {
    final idx = _sectionsOrder.indexOf(s);
    if (idx < 0) return;
    setState(() => _canSwipe = true); // 确保可横滑
    try {
      await _dragCtrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {}
    try {
      await _pageCtrl.animateToPage(
        1 + idx, // 0 是启动页，所以 +1
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  void _enableWizard() async {
    setState(() => _canSwipe = true);
    try {
      await _dragCtrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } catch (_) {}
    // 跳到第二页（index=1）
    try {
      await _pageCtrl.animateToPage(
        1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final radius = const Radius.circular(24);
    final canScroll = _canSwipe && !(_isBasicPage && !_basicValid); // ✅ 关键

    final hasStartAddress =
        _startAddress != null && _startAddress!.trim().isNotEmpty;
    final hasDestinationAddress =
        _destinationAddress != null && _destinationAddress!.trim().isNotEmpty;
    final startCoords = _startLatLng != null
        ? '${_startLatLng!.latitude.toStringAsFixed(6)}, '
              '${_startLatLng!.longitude.toStringAsFixed(6)}'
        : null;
    final startTitle = hasStartAddress
        ? _startAddress!.trim()
        : (startCoords ?? loc.map_select_location_title);
    final startSubtitle = _startLatLng != null
        ? (hasStartAddress
              ? loc.location_coordinates(
                  _startLatLng!.latitude.toStringAsFixed(6),
                  _startLatLng!.longitude.toStringAsFixed(6),
                )
              : '')
        : loc.map_select_location_tip;
    final destinationCoords = _destinationLatLng != null
        ? '${_destinationLatLng!.latitude.toStringAsFixed(6)}, '
              '${_destinationLatLng!.longitude.toStringAsFixed(6)}'
        : null;
    final destinationTitle = hasDestinationAddress
        ? _destinationAddress!.trim()
        : (destinationCoords ?? loc.map_select_location_destination_label);
    final destinationSubtitle = _destinationLatLng != null
        ? (hasDestinationAddress
              ? loc.location_coordinates(
                  _destinationLatLng!.latitude.toStringAsFixed(6),
                  _destinationLatLng!.longitude.toStringAsFixed(6),
                )
              : '')
        : loc.map_select_location_destination_tip;

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: DraggableScrollableSheet(
        controller: _dragCtrl,
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.45, 0.95],
        builder: (context, scrollCtrl) {
          return Material(
            color: theme.colorScheme.surface,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Grabber
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // TabBar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: .6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.symmetric(vertical: 10),
                        tabs: [
                          Tab(text: 'Connection'),
                          Tab(text: 'Test'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ===== 4) PageView：第0页仍为启动页，其后每页对应一个 section =====
                  Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (n) {
                            n.disallowIndicator();
                            return true;
                          },
                          child: PageView(
                            controller: _pageCtrl,
                            physics: canScroll
                                ? const PageScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            children: [
                              _ConnectionStart(
                                scrollCtrl: scrollCtrl,
                                onContinue: _enableWizard,
                                departureTitle: startTitle,
                                departureSubtitle: startSubtitle,
                                destinationTitle: destinationTitle,
                                destinationSubtitle: destinationSubtitle,
                                onEditDeparture: () =>
                                    _restartSelectionFlow(skipStart: false),
                                onEditDestination: () => _restartSelectionFlow(
                                  skipStart:
                                      _destinationLatLng != null &&
                                      _startLatLng != null,
                                ),
                                departurePosition: _startLatLng,
                                departureAddressFuture: _startAddressFuture,
                                departureNearbyFuture: _startNearbyFuture,
                                destinationPosition: _destinationLatLng,
                                destinationAddressFuture:
                                    _destinationAddressFuture,
                                destinationNearbyFuture:
                                    _destinationNearbyFuture,
                              ),
                              ..._sectionsOrder.map(_buildSectionPage),
                            ],
                          ),
                        ),
                  ),
                  // ===== 5) 底部进度 + 按钮：保持原逻辑，count 改为总页数 =====
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _canSwipe
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageCtrl,
                                    count: _totalPages, // 包含启动页
                                    effect: const WormEffect(
                                      dotHeight: 8,
                                      dotWidth: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: !canScroll
                                        ? null // 第二页没填完 -> 禁用
                                        : _onCreatePressed, // 填完或其他页 -> 可创建
                                    child: const Text('创建'),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _enableWizard,
                                child: const Text('继续'),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionStart extends StatelessWidget {
  const _ConnectionStart({
    required this.scrollCtrl,
    required this.onContinue,
    required this.departureTitle,
    required this.departureSubtitle,
    required this.destinationTitle,
    required this.destinationSubtitle,
    required this.onEditDeparture,
    required this.onEditDestination,
    this.departurePosition,
    this.departureAddressFuture,
    this.departureNearbyFuture,
    this.destinationPosition,
    this.destinationAddressFuture,
    this.destinationNearbyFuture,
  });
  final ScrollController scrollCtrl;
  final VoidCallback onContinue;
  final String departureTitle;
  final String departureSubtitle;
  final String destinationTitle;
  final String destinationSubtitle;
  final VoidCallback onEditDeparture;
  final VoidCallback onEditDestination;
  final LatLng? departurePosition;
  final Future<String?>? departureAddressFuture;
  final Future<List<NearbyPlace>>? departureNearbyFuture;
  final LatLng? destinationPosition;
  final Future<String?>? destinationAddressFuture;
  final Future<List<NearbyPlace>>? destinationNearbyFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(
            children: [
              _CardTile(
                leading: const Icon(Icons.radio_button_checked),
                title: departureTitle,
                subtitle: departureSubtitle.isEmpty ? null : departureSubtitle,
                onTap: onEditDeparture,
              ),
              const SizedBox(height: 12),
              _CardTile(
                leading: const Icon(Icons.place_outlined),
                title: destinationTitle,
                subtitle: destinationSubtitle.isEmpty
                    ? null
                    : destinationSubtitle,
                onTap: onEditDestination,
              ),
              const SizedBox(height: 40),
              _LocationDetails(
                label: loc.map_select_location_start_label,
                tip: loc.map_select_location_tip,
                position: departurePosition,
                addressFuture: departureAddressFuture,
                nearbyFuture: departureNearbyFuture,
              ),
              const SizedBox(height: 24),
              _LocationDetails(
                label: loc.map_select_location_destination_label,
                tip: loc.map_select_location_destination_tip,
                position: destinationPosition,
                addressFuture: destinationAddressFuture,
                nearbyFuture: destinationNearbyFuture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationDetails extends StatelessWidget {
  const _LocationDetails({
    required this.label,
    required this.tip,
    this.position,
    this.addressFuture,
    this.nearbyFuture,
  });

  final String label;
  final String tip;
  final LatLng? position;
  final Future<String?>? addressFuture;
  final Future<List<NearbyPlace>>? nearbyFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (position == null) ...[
          Text(
            tip,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: .75),
            ),
          ),
        ] else ...[
          LocationSheetRow(
            icon: const Icon(Icons.place_outlined),
            child: Text(
              loc.location_coordinates(
                position!.latitude.toStringAsFixed(6),
                position!.longitude.toStringAsFixed(6),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          if (addressFuture != null)
            FutureBuilder<String?>(
              future: addressFuture,
              builder: (context, snapshot) {
                final icon = Icon(
                  Icons.home_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: .7),
                );
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LocationSheetRow(
                    icon: icon,
                    child: Text(loc.map_location_info_address_loading),
                  );
                }
                if (snapshot.hasError) {
                  return LocationSheetRow(
                    icon: icon,
                    child: Text(loc.map_location_info_address_unavailable),
                  );
                }
                final address = snapshot.data;
                final display = (address == null || address.trim().isEmpty)
                    ? loc.map_location_info_address_unavailable
                    : address;
                return LocationSheetRow(icon: icon, child: Text(display));
              },
            ),
          if (nearbyFuture != null) ...[
            const SizedBox(height: 16),
            NearbyPlacesPreview(future: nearbyFuture!),
          ],
        ],
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
