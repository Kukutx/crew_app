import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_basic_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_gallery_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_host_disclaimer_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_preferences_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_route_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_story_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_team_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CreateRoadTripSheet extends ConsumerStatefulWidget {
  const CreateRoadTripSheet({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  ConsumerState<CreateRoadTripSheet> createState() => _CreateRoadTripSheetState();
}

class _CreateRoadTripSheetState extends ConsumerState<CreateRoadTripSheet> {
  final _pageController = PageController();
  final _detailsFormKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _endLocationCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '4');
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _hostDisclaimerCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  RoadTripEditorState _editorState = const RoadTripEditorState();

  final ImagePicker _picker = ImagePicker();

  Future<List<NearbyPlace>>? _nearbyPlacesFuture;
  LatLng? _nearbySource;
  LatLng? _prefilledStartFrom;
  LatLng? _prefilledEndFrom;

  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _setupInitialSelection();
    ref.listen<MapSelectionState>(
      mapSelectionControllerProvider,
      (previous, next) {
        _handleSelectionUpdate(previous, next);
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleCtrl.dispose();
    _startLocationCtrl.dispose();
    _endLocationCtrl.dispose();
    _meetingLocationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _hostDisclaimerCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _setupInitialSelection() {
    final selection = ref.read(mapSelectionControllerProvider);
    final start = selection.selectedLatLng;
    final destination = selection.destinationLatLng;

    if (start != null) {
      _prefilledStartFrom = start;
      _nearbySource = start;
      _nearbyPlacesFuture =
          ref.read(mapSelectionControllerProvider.notifier).getNearbyPlaces(start);
      _prefillAddress(start, controller: _startLocationCtrl);
    }

    if (destination != null) {
      _prefilledEndFrom = destination;
      _prefillAddress(destination, controller: _endLocationCtrl);
    }
  }

  void _handleSelectionUpdate(MapSelectionState? previous, MapSelectionState next) {
    final previousStart = previous?.selectedLatLng;
    final nextStart = next.selectedLatLng;
    if (!_sameLatLng(previousStart, nextStart)) {
      if (nextStart != null) {
        _nearbySource = nextStart;
        _nearbyPlacesFuture =
            ref.read(mapSelectionControllerProvider.notifier).getNearbyPlaces(nextStart);
        if (_startLocationCtrl.text.trim().isEmpty || _prefilledStartFrom == null || !_sameLatLng(_prefilledStartFrom, nextStart)) {
          _prefilledStartFrom = nextStart;
          _prefillAddress(nextStart, controller: _startLocationCtrl);
        }
      }
    }

    final previousDestination = previous?.destinationLatLng;
    final nextDestination = next.destinationLatLng;
    if (!_sameLatLng(previousDestination, nextDestination)) {
      if (nextDestination != null && (_endLocationCtrl.text.trim().isEmpty || _prefilledEndFrom == null || !_sameLatLng(_prefilledEndFrom, nextDestination))) {
        _prefilledEndFrom = nextDestination;
        _prefillAddress(nextDestination, controller: _endLocationCtrl);
      }
    }
  }

  Future<void> _prefillAddress(
    LatLng position, {
    required TextEditingController controller,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }
      final first = placemarks.isEmpty ? null : placemarks.first;
      final formatted = _formatPlacemark(first);
      if (formatted != null && controller.text.trim().isEmpty) {
        controller.text = formatted;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (controller.text.trim().isEmpty) {
        controller.text =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scrollable = CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildLocationStep(theme),
                    _buildDetailsStep(theme),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20 + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: 2,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            expansionFactor: 4,
                            spacing: 8,
                            dotColor: theme.colorScheme.outline.withValues(alpha: 0.4),
                            activeDotColor: theme.colorScheme.primary,
                          ),
                          onDotClicked: (index) {
                            if (index == _currentPage) {
                              return;
                            }
                            if (index == 1) {
                              _onContinue();
                              return;
                            }
                            _goToPage(0);
                          },
                        ),
                        const Spacer(),
                        if (_currentPage == 1)
                          TextButton(
                            onPressed: () => _goToPage(0),
                            child: const Text('上一步'),
                          ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _currentPage == 0
                              ? _onContinue
                              : (_isSubmitting ? null : _onCreate),
                          icon: _currentPage == 0
                              ? const Icon(Icons.arrow_forward_rounded)
                              : _isSubmitting
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.directions_car_filled_outlined),
                          label: Text(_currentPage == 0 ? '继续' : '创建'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return scrollable;
  }

  Widget _buildLocationStep(ThemeData theme) {
    final selection = ref.watch(mapSelectionControllerProvider);
    final start = selection.selectedLatLng;
    final destination = selection.destinationLatLng;

    if (start != null && (_nearbySource == null || !_sameLatLng(_nearbySource, start))) {
      _nearbySource = start;
      _nearbyPlacesFuture =
          ref.read(mapSelectionControllerProvider.notifier).getNearbyPlaces(start);
    }

    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + safeBottom),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '创建自驾游活动',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '长按地图放置起点标记，或从附近地点中选择理想的集合点和终点。',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildLocationField(
            context,
            label: '起点',
            controller: _startLocationCtrl,
            icon: Icons.flag_circle_outlined,
            coordinate: start,
          ),
          const SizedBox(height: 16),
          _buildLocationField(
            context,
            label: '终点',
            controller: _endLocationCtrl,
            icon: Icons.location_on_outlined,
            coordinate: destination,
          ),
          const SizedBox(height: 28),
          Text(
            '附近地点',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (_nearbyPlacesFuture == null)
            _buildEmptyNearbyHint(theme)
          else
            FutureBuilder<List<NearbyPlace>>(
              future: _nearbyPlacesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 72,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return _buildErrorNearbyHint(theme);
                }
                final places = snapshot.data;
                if (places == null || places.isEmpty) {
                  return _buildEmptyNearbyHint(theme);
                }
                return Column(
                  children: [
                    for (final place in places) ...[
                      _NearbyPlaceActionCard(
                        place: place,
                        onSetStart: () => _applyPlace(place, isStart: true),
                        onSetDestination: () => _applyPlace(place, isStart: false),
                      ),
                      const SizedBox(height: 12),
                    ]
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyNearbyHint(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        '在地图上长按选择位置后，会自动显示附近的兴趣点，方便你快速设置起点和终点。',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  Widget _buildErrorNearbyHint(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.errorContainer,
      ),
      child: Text(
        '暂时无法获取附近地点，请稍后重试或手动填写起终点。',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildLocationField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    LatLng? coordinate,
  }) {
    final theme = Theme.of(context);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: '输入地址或地标，例如：城市广场集合点',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        if (coordinate != null) ...[
          const SizedBox(height: 6),
          Text(
            '坐标：${coordinate.latitude.toStringAsFixed(5)}, ${coordinate.longitude.toStringAsFixed(5)}',
            style: subtitleStyle,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '完善活动信息',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '补充旅程详情、团队信息与旅程偏好，帮助伙伴快速了解这次出行。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            RoadTripBasicSection(
              titleController: _titleCtrl,
              dateRange: _editorState.dateRange,
              onPickDateRange: _pickDateRange,
            ),
            const SizedBox(height: 16),
            RoadTripRouteSection(
              startController: _startLocationCtrl,
              endController: _endLocationCtrl,
              meetingController: _meetingLocationCtrl,
              routeType: _editorState.routeType,
              onRouteTypeChanged: (type) => setState(() {
                _editorState = _editorState.copyWith(routeType: type);
              }),
              onAddWaypoint: _showAddWaypointDialog,
              onRemoveWaypoint: (index) => setState(() {
                final updated = [..._editorState.waypoints]..removeAt(index);
                _editorState = _editorState.copyWith(waypoints: updated);
              }),
              waypoints: _editorState.waypoints,
            ),
            const SizedBox(height: 16),
            RoadTripTeamSection(
              maxParticipantsController: _maxParticipantsCtrl,
              priceController: _priceCtrl,
              pricingType: _editorState.pricingType,
              onPricingTypeChanged: (type) => setState(() {
                _editorState = _editorState.copyWith(pricingType: type);
                if (type == RoadTripPricingType.free) {
                  _priceCtrl.clear();
                }
              }),
            ),
            const SizedBox(height: 16),
            RoadTripPreferencesSection(
              carType: _editorState.carType,
              onCarTypeChanged: (value) => setState(() {
                _editorState = _editorState.copyWith(
                  carType: value,
                  clearCarType: value == null,
                );
              }),
              tagInputController: _tagInputCtrl,
              onSubmitTag: _addTagFromInput,
              tags: _editorState.tags,
              onRemoveTag: (tag) => setState(() {
                _editorState = _editorState.copyWith(
                  tags: _editorState.tags.where((t) => t != tag).toList(),
                );
              }),
            ),
            const SizedBox(height: 16),
            RoadTripGallerySection(
              items: _editorState.galleryItems,
              onPickImages: _pickImages,
              onRemoveImage: _removeGalleryItem,
              onSetCover: _setCover,
            ),
            const SizedBox(height: 16),
            RoadTripStorySection(descriptionController: _descriptionCtrl),
            const SizedBox(height: 16),
            RoadTripHostDisclaimerSection(
              disclaimerController: _hostDisclaimerCtrl,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange:
          _editorState.dateRange ?? DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) {
      setState(() {
        _editorState = _editorState.copyWith(dateRange: picked);
      });
    }
  }

  void _showAddWaypointDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('添加途经点'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '例如：湖畔观景台或服务区'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final value = ctrl.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _editorState = _editorState.copyWith(
                    waypoints: [..._editorState.waypoints, value],
                  );
                });
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _addTagFromInput() {
    final value = _tagInputCtrl.text.trim();
    if (value.isEmpty) {
      return;
    }
    if (_editorState.tags.contains(value)) {
      _tagInputCtrl.clear();
      return;
    }
    setState(() {
      _editorState = _editorState.copyWith(tags: [..._editorState.tags, value]);
    });
    _tagInputCtrl.clear();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) {
        return;
      }
      setState(() {
        final newItems = picked.map((x) => RoadTripGalleryItem.file(File(x.path))).toList();
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

  void _setCover(int index) {
    if (index < 0 || index >= _editorState.galleryItems.length) {
      return;
    }
    setState(() {
      final items = [..._editorState.galleryItems];
      final item = items.removeAt(index);
      items.insert(0, item);
      _editorState = _editorState.copyWith(galleryItems: items);
    });
  }

  void _removeGalleryItem(int index) {
    if (index < 0 || index >= _editorState.galleryItems.length) {
      return;
    }
    setState(() {
      final updated = [..._editorState.galleryItems]..removeAt(index);
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _applyPlace(NearbyPlace place, {required bool isStart}) {
    final location = place.location;
    final displayName = place.formattedAddress?.trim().isNotEmpty == true
        ? place.formattedAddress!
        : place.displayName;
    if (isStart) {
      _startLocationCtrl.text = displayName;
      _prefilledStartFrom = location;
      if (location != null) {
        ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(location);
        HapticFeedback.selectionClick();
      }
    } else {
      _endLocationCtrl.text = displayName;
      _prefilledEndFrom = location;
      if (location != null) {
        ref.read(mapSelectionControllerProvider.notifier).setDestinationLatLng(location);
        HapticFeedback.selectionClick();
      }
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onContinue() {
    if (_startLocationCtrl.text.trim().isEmpty) {
      _showSnack('请先设置起点信息');
      return;
    }
    if (_endLocationCtrl.text.trim().isEmpty) {
      _showSnack('请设置终点信息');
      return;
    }
    FocusScope.of(context).unfocus();
    _goToPage(1);
  }

  Future<void> _onCreate() async {
    if (_isSubmitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (!_detailsFormKey.currentState!.validate()) {
      _showSnack('请完善表单中的必填信息');
      return;
    }
    if (_editorState.dateRange == null) {
      _showSnack('请选择活动日期范围');
      return;
    }

    final maxParticipants = int.tryParse(_maxParticipantsCtrl.text.trim());
    if (maxParticipants == null || maxParticipants <= 0) {
      _showSnack('请输入有效的参与人数');
      return;
    }

    final isFree = _editorState.pricingType == RoadTripPricingType.free;
    double? pricePerPerson;
    if (!isFree) {
      pricePerPerson = double.tryParse(_priceCtrl.text.trim());
      if (pricePerPerson == null || pricePerPerson <= 0) {
        _showSnack('请输入合理的价格');
        return;
      }
    }

    final galleryImages = _editorState.galleryItems
        .where((item) => item.isFile)
        .map((item) => item.file!)
        .toList(growable: false);
    final galleryUrls = _editorState.galleryItems
        .where((item) => !item.isFile)
        .map((item) => item.url)
        .whereType<String>()
        .toList(growable: false);

    final draft = RoadTripDraft(
      title: _titleCtrl.text.trim(),
      dateRange: _editorState.dateRange!,
      startLocation: _startLocationCtrl.text.trim(),
      endLocation: _endLocationCtrl.text.trim(),
      meetingPoint: _meetingLocationCtrl.text.trim(),
      isRoundTrip: _editorState.routeType == RoadTripRouteType.roundTrip,
      waypoints: _editorState.waypoints,
      maxParticipants: maxParticipants,
      isFree: isFree,
      pricePerPerson: pricePerPerson,
      carType: _editorState.carType,
      tags: _editorState.tags,
      description: _descriptionCtrl.text.trim(),
      hostDisclaimer: _hostDisclaimerCtrl.text.trim(),
      galleryImages: galleryImages,
      existingImageUrls: galleryUrls,
    );

    setState(() => _isSubmitting = true);
    try {
      await ref.read(eventsApiProvider).createRoadTrip(draft);
      if (!mounted) {
        return;
      }
      _showSnack('自驾游活动创建成功');
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
      ref.read(mapSelectionControllerProvider.notifier).resetSelection();
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack('创建失败：$error');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _sameLatLng(LatLng? a, LatLng? b) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    return (a.latitude - b.latitude).abs() < 1e-6 &&
        (a.longitude - b.longitude).abs() < 1e-6;
  }

  String? _formatPlacemark(Placemark? placemark) {
    if (placemark == null) {
      return null;
    }
    final parts = <String?>[
      placemark.name,
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ];
    final buffer = <String>[];
    final seen = <String>{};
    for (final part in parts) {
      if (part == null) {
        continue;
      }
      final trimmed = part.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) {
        continue;
      }
      buffer.add(trimmed);
    }
    if (buffer.isEmpty) {
      return null;
    }
    return buffer.join(', ');
  }
}

class _NearbyPlaceActionCard extends StatelessWidget {
  const _NearbyPlaceActionCard({
    required this.place,
    required this.onSetStart,
    required this.onSetDestination,
  });

  final NearbyPlace place;
  final VoidCallback onSetStart;
  final VoidCallback onSetDestination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.displayName,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (place.formattedAddress != null &&
                          place.formattedAddress!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          place.formattedAddress!,
                          style: subtitleStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetStart,
                    icon: const Icon(Icons.flag),
                    label: const Text('设为起点'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSetDestination,
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('设为终点'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
