import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/location_selection_sheets.dart';
import 'package:crew_app/features/events/presentation/pages/trips/data/road_trip_editor_models.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CreateRoadTripSheet extends ConsumerStatefulWidget {
  const CreateRoadTripSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<CreateRoadTripSheet> createState() => _CreateRoadTripSheetState();
}

class _CreateRoadTripSheetState extends ConsumerState<CreateRoadTripSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _inactiveQuickController = ScrollController();
  final _inactiveDetailsController = ScrollController();

  final _titleController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _meetingController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '4');
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hostDisclaimerController = TextEditingController();
  final _tagInputController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  ProviderSubscription<LatLng?>? _startSubscription;
  ProviderSubscription<LatLng?>? _destinationSubscription;

  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  String? _startAddress;
  String? _destinationAddress;

  bool _loadingStartAddress = false;
  bool _loadingDestinationAddress = false;

  Future<List<NearbyPlace>>? _nearbyPlacesFuture;
  String? _selectedNearbyPlaceId;
  bool _settingDestinationFromPlace = false;

  RoadTripEditorState _editorState = const RoadTripEditorState();

  int _currentPage = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final selection = ref.read(mapSelectionControllerProvider);
    final start = selection.selectedLatLng;
    if (start != null) {
      _applyStartLatLng(start);
    }
    final destination = selection.destinationLatLng;
    if (destination != null) {
      _destinationLatLng = destination;
      unawaited(_fetchDestinationAddress(destination));
    }

    _titleController.addListener(_notifySummaryChanged);
    _startController.addListener(_notifySummaryChanged);
    _endController.addListener(_notifySummaryChanged);

    _startSubscription = ref.listen<LatLng?>(
      mapSelectionControllerProvider.select((state) => state.selectedLatLng),
      (previous, next) {
        if (!mounted) return;
        if (next == null) {
          setState(() {
            _startLatLng = null;
            _startAddress = null;
            _startController.clear();
          });
          return;
        }
        _applyStartLatLng(next);
      },
      fireImmediately: false,
    );

    _destinationSubscription = ref.listen<LatLng?>(
      mapSelectionControllerProvider.select((state) => state.destinationLatLng),
      (previous, next) {
        if (!mounted || next == null) {
          if (mounted) {
            setState(() {
              _destinationLatLng = null;
              _destinationAddress = null;
              _selectedNearbyPlaceId = null;
              _endController.clear();
            });
          }
          return;
        }
        if (_settingDestinationFromPlace) {
          return;
        }
        _applyDestinationLatLng(next, fromMap: true);
      },
      fireImmediately: false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _inactiveQuickController.dispose();
    _inactiveDetailsController.dispose();
    _titleController.dispose();
    _startController.dispose();
    _endController.dispose();
    _meetingController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _hostDisclaimerController.dispose();
    _tagInputController.dispose();
    _titleController.removeListener(_notifySummaryChanged);
    _startController.removeListener(_notifySummaryChanged);
    _endController.removeListener(_notifySummaryChanged);
    _startSubscription?.close();
    _destinationSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final header = _currentPage == 0
        ? _SheetHeader(
            title: '快速创建自驾游活动',
            subtitle: '长按地图设置起点，选择附近 POI 作为终点。',
          )
        : _SheetHeader(
            title: '完善旅程信息',
            subtitle: '补全时间、路线与偏好，让伙伴更好了解。',
          );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: header,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 2,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  spacing: 10,
                  radius: 6,
                  dotColor: theme.colorScheme.outlineVariant,
                  activeDotColor: theme.colorScheme.primary,
                ),
                onDotClicked: (index) => _animateToPage(index),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const PageScrollPhysics(),
              onPageChanged: _handlePageChanged,
              children: [
                _buildQuickStep(context, widget.scrollController, _currentPage == 0),
                _buildDetailStep(context, widget.scrollController, _currentPage == 1),
              ],
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildQuickStep(
    BuildContext context,
    ScrollController provided,
    bool isActive,
  ) {
    final controller = isActive ? provided : _inactiveQuickController;
    final bottom = MediaQuery.of(context).viewPadding.bottom + 120;
    final theme = Theme.of(context);

    return ListView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottom),
      children: [
        const SizedBox(height: 4),
        _QuickInfoBanner(address: _startAddress, position: _startLatLng),
        const SizedBox(height: 24),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: '活动标题',
            hintText: '给旅程取个名字',
            prefixIcon: Icon(Icons.auto_stories_outlined),
            border: OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
          validator: (value) => (value == null || value.trim().isEmpty) ? '请输入活动标题' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _startController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: '起点',
            hintText: '长按地图选择起点',
            prefixIcon: const Icon(Icons.flag_outlined),
            border: const OutlineInputBorder(),
            suffixIcon: _loadingStartAddress
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          validator: (_) => _startLatLng == null ? '请选择起点' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _endController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: '终点',
            hintText: '从列表中选择附近地点',
            prefixIcon: const Icon(Icons.flag),
            border: const OutlineInputBorder(),
            suffixIcon: _destinationLatLng != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: '清除终点',
                    onPressed: _clearDestination,
                  )
                : (_loadingDestinationAddress
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null),
          ),
          validator: (_) => _destinationLatLng == null ? '请选择终点' : null,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              '附近地点',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '重新加载',
              onPressed: _startLatLng == null
                  ? null
                  : () => _loadNearbyPlaces(_startLatLng!),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildNearbyPlaces(context),
      ],
    );
  }

  Widget _buildNearbyPlaces(BuildContext context) {
    final theme = Theme.of(context);
    final future = _nearbyPlacesFuture;
    if (_startLatLng == null) {
      return _EmptyHint(text: '长按地图后，这里会显示附近的推荐地点。');
    }
    if (future == null) {
      _loadNearbyPlaces(_startLatLng!);
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<List<NearbyPlace>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _EmptyHint(text: '加载附近地点失败，请稍后再试。');
        }
        final places = snapshot.data?.where((p) => p.location != null).toList() ?? const [];
        if (places.isEmpty) {
          return _EmptyHint(text: '附近暂时没有可选地点，可以拖动地图重新选择。');
        }
        return Column(
          children: [
            for (final place in places) ...[
              _NearbyPlaceTile(
                place: place,
                selected: place.id == _selectedNearbyPlaceId,
                onTap: () => _handlePlaceSelected(place),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDetailStep(
    BuildContext context,
    ScrollController provided,
    bool isActive,
  ) {
    final controller = isActive ? provided : _inactiveDetailsController;
    final bottom = MediaQuery.of(context).viewPadding.bottom + 180;

    return ListView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      children: [
        const SizedBox(height: 4),
        _SummaryCard(
          title: _titleController.text,
          start: _startController.text,
          destination: _endController.text,
        ),
        const SizedBox(height: 16),
        RoadTripBasicSection(
          titleController: _titleController,
          dateRange: _editorState.dateRange,
          onPickDateRange: _pickDateRange,
        ),
        const SizedBox(height: 16),
        RoadTripRouteSection(
          startController: _startController,
          endController: _endController,
          meetingController: _meetingController,
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
          maxParticipantsController: _maxParticipantsController,
          priceController: _priceController,
          pricingType: _editorState.pricingType,
          onPricingTypeChanged: (type) => setState(() {
            _editorState = _editorState.copyWith(pricingType: type);
            if (type == RoadTripPricingType.free) {
              _priceController.clear();
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
          tagInputController: _tagInputController,
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
        RoadTripStorySection(descriptionController: _descriptionController),
        const SizedBox(height: 16),
        RoadTripHostDisclaimerSection(
          disclaimerController: _hostDisclaimerController,
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom + 16;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _currentPage == 0
            ? FilledButton(
                key: const ValueKey('continue'),
                onPressed: _isSubmitting ? null : _handleContinue,
                child: const Text('继续'),
              )
            : Column(
                key: const ValueKey('create'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _openFullEditor,
                      style: TextButton.styleFrom(
                        textStyle: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('继续'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _handleCreate,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.directions_car_filled_outlined),
                    label: Text(_isSubmitting ? '创建中…' : '创建'),
                  ),
                ],
              ),
      ),
    );
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _notifySummaryChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _animateToPage(int index) {
    if (index == _currentPage) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleContinue() {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _startLatLng == null || _destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完善起点、终点与标题信息')),
      );
      return;
    }
    _animateToPage(1);
  }

  Future<void> _handleCreate() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_startLatLng == null || _destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择起点与终点')), 
      );
      return;
    }
    if (_editorState.dateRange == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择活动日期范围')));
      return;
    }
    if (_editorState.pricingType == RoadTripPricingType.paid &&
        double.tryParse(_priceController.text.trim()).isNullOrNan) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入正确的人均费用')));
      return;
    }

    setState(() => _isSubmitting = true);
    final manager = ref.read(locationSelectionManagerProvider);
    try {
      var startAddress = _startAddress;
      var destinationAddress = _destinationAddress;
      if (startAddress == null || startAddress.trim().isEmpty) {
        startAddress = await manager.geocodeAddress(_startLatLng!);
      }
      if (destinationAddress == null || destinationAddress.trim().isEmpty) {
        destinationAddress = await manager.geocodeAddress(_destinationLatLng!);
      }
      final result = QuickRoadTripResult(
        title: _titleController.text.trim(),
        start: _startLatLng!,
        destination: _destinationLatLng!,
        startAddress: startAddress,
        destinationAddress: destinationAddress,
        openDetailed: false,
      );
      await manager.createRoadTrip(result);
      if (!mounted) return;
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
      await manager.clearSelectedLocation(dismissSheet: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('自驾游活动已创建')), 
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('创建失败：$error')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openFullEditor() async {
    final now = DateTime.now();
    final range = _editorState.dateRange ??
        DateTimeRange(start: now, end: now.add(const Duration(days: 1)));
    final draft = RoadTripDraft(
      title: _titleController.text.trim().isEmpty
          ? '未命名自驾游'
          : _titleController.text.trim(),
      dateRange: range,
      startLocation: _startController.text.trim(),
      endLocation: _endController.text.trim(),
      meetingPoint: _meetingController.text.trim().isEmpty
          ? '集合地点待定'
          : _meetingController.text.trim(),
      isRoundTrip: _editorState.routeType == RoadTripRouteType.roundTrip,
      waypoints: List.of(_editorState.waypoints),
      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 4,
      isFree: _editorState.pricingType == RoadTripPricingType.free,
      pricePerPerson: _editorState.pricingType == RoadTripPricingType.paid
          ? double.tryParse(_priceController.text.trim())
          : null,
      carType: _editorState.carType,
      tags: List.of(_editorState.tags),
      description: _descriptionController.text.trim(),
      hostDisclaimer: _hostDisclaimerController.text.trim(),
      galleryImages: _editorState.galleryItems
          .where((item) => item.file != null)
          .map((item) => item.file!)
          .toList(),
      existingImageUrls: _editorState.galleryItems
          .where((item) => item.url != null)
          .map((item) => item.url!)
          .toList(),
    );

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RoadTripEditorPage(
          onClose: () => Navigator.of(context).pop(),
          initialValue: draft,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _applyStartLatLng(LatLng latlng) {
    setState(() {
      _startLatLng = latlng;
    });
    _loadNearbyPlaces(latlng);
    unawaited(_fetchStartAddress(latlng));
  }

  void _applyDestinationLatLng(LatLng latlng, {bool fromMap = false}) {
    setState(() {
      _destinationLatLng = latlng;
      if (fromMap) {
        _selectedNearbyPlaceId = null;
      }
    });
    if (fromMap) {
      unawaited(_fetchDestinationAddress(latlng));
    }
  }

  void _loadNearbyPlaces(LatLng latlng) {
    final future = ref.read(mapSelectionControllerProvider.notifier).getNearbyPlaces(latlng);
    setState(() => _nearbyPlacesFuture = future);
  }

  Future<void> _fetchStartAddress(LatLng latlng) async {
    setState(() => _loadingStartAddress = true);
    final manager = ref.read(locationSelectionManagerProvider);
    try {
      final address = await manager.geocodeAddress(latlng);
      if (!mounted) return;
      setState(() {
        _loadingStartAddress = false;
        _startAddress = address;
        _startController.text =
            (address == null || address.trim().isEmpty) ? _formatLatLng(latlng) : address.trim();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingStartAddress = false;
        _startAddress = null;
        _startController.text = _formatLatLng(latlng);
      });
    }
  }

  Future<void> _fetchDestinationAddress(LatLng latlng) async {
    setState(() => _loadingDestinationAddress = true);
    final manager = ref.read(locationSelectionManagerProvider);
    try {
      final address = await manager.geocodeAddress(latlng);
      if (!mounted) return;
      setState(() {
        _loadingDestinationAddress = false;
        _destinationAddress = address;
        if (_selectedNearbyPlaceId == null) {
          _endController.text =
              (address == null || address.trim().isEmpty) ? _formatLatLng(latlng) : address.trim();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingDestinationAddress = false;
        _destinationAddress = null;
        if (_selectedNearbyPlaceId == null) {
          _endController.text = _formatLatLng(latlng);
        }
      });
    }
  }

  void _handlePlaceSelected(NearbyPlace place) {
    final location = place.location;
    if (location == null) return;
    _settingDestinationFromPlace = true;
    HapticFeedback.selectionClick();
    ref.read(mapSelectionControllerProvider.notifier).setDestinationLatLng(location);
    final address = (place.formattedAddress != null && place.formattedAddress!.trim().isNotEmpty)
        ? place.formattedAddress!.trim()
        : place.displayName;
    setState(() {
      _destinationLatLng = location;
      _destinationAddress = address;
      _selectedNearbyPlaceId = place.id;
      _endController.text = place.displayName;
    });
    Future.microtask(() => _settingDestinationFromPlace = false);
  }

  void _clearDestination() {
    ref.read(mapSelectionControllerProvider.notifier).setDestinationLatLng(null);
    setState(() {
      _destinationLatLng = null;
      _destinationAddress = null;
      _selectedNearbyPlaceId = null;
      _endController.clear();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: _editorState.dateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) {
      setState(() {
        _editorState = _editorState.copyWith(dateRange: picked);
      });
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      final newItems = picked
          .map((file) => RoadTripGalleryItem.file(File(file.path)))
          .toList(growable: false);
      _editorState = _editorState.copyWith(
        galleryItems: [..._editorState.galleryItems, ...newItems],
      );
    });
  }

  void _setCover(int index) {
    if (index < 0 || index >= _editorState.galleryItems.length) return;
    setState(() {
      final items = [..._editorState.galleryItems];
      final item = items.removeAt(index);
      items.insert(0, item);
      _editorState = _editorState.copyWith(galleryItems: items);
    });
  }

  void _removeGalleryItem(int index) {
    if (index < 0 || index >= _editorState.galleryItems.length) return;
    setState(() {
      final items = [..._editorState.galleryItems]..removeAt(index);
      _editorState = _editorState.copyWith(galleryItems: items);
    });
  }

  void _showAddWaypointDialog() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加途经点'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '例如：Pisa Tower'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  _editorState = _editorState.copyWith(
                    waypoints: [..._editorState.waypoints, ctrl.text.trim()],
                  );
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _addTagFromInput() {
    final value = _tagInputController.text.trim();
    if (value.isEmpty) return;
    if (_editorState.tags.contains(value)) {
      _tagInputController.clear();
      return;
    }
    setState(() {
      _editorState = _editorState.copyWith(tags: [..._editorState.tags, value]);
    });
    _tagInputController.clear();
  }

  String _formatLatLng(LatLng latlng) =>
      '${latlng.latitude.toStringAsFixed(5)}, ${latlng.longitude.toStringAsFixed(5)}';
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuickInfoBanner extends StatelessWidget {
  const _QuickInfoBanner({required this.address, required this.position});

  final String? address;
  final LatLng? position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary.withValues(alpha: 0.1);
    final text = address ??
        (position == null
            ? '在地图上长按选择起点，快速生成路线草稿。'
            : '已选位置：${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyPlaceTile extends StatelessWidget {
  const _NearbyPlaceTile({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final NearbyPlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = place.formattedAddress;
    final color = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.12)
        : theme.colorScheme.surfaceContainerHighest;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_circle_outline : Icons.place_outlined,
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (address != null && address.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address.trim(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.start,
    required this.destination,
  });

  final String title;
  final String start;
  final String destination;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isEmpty ? '未命名自驾游' : title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.play_arrow_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    start.isEmpty ? '起点待定' : start,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination.isEmpty ? '终点待定' : destination,
                    style: theme.textTheme.bodyMedium,
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

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

extension _NullableNumber on double? {
  bool get isNullOrNan => this == null || this!.isNaN;
}
