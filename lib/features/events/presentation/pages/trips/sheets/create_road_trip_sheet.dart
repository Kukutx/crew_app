import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_basic_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_gallery_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_host_disclaimer_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_preferences_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_route_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_story_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_team_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

/// 创建自驾游Sheet模式
enum CreateRoadTripMode {
  /// 完整创建流程（默认）
  fullCreation,
  /// 仅起点确认（替代 StartLocationSheet）
  startLocationOnly,
}

class CreateRoadTripSheet extends ConsumerStatefulWidget {
  const CreateRoadTripSheet({
    super.key,
    required this.scrollController,
    this.initialRoute,
    this.mode = CreateRoadTripMode.fullCreation,
    this.embeddedMode = true,
    // 以下参数用于 startLocationOnly 模式
    this.startPositionListenable,
    this.destinationListenable,
    this.onConfirm,
    this.onCancel,
    this.onCreateQuickTrip,
    this.onOpenDetailed,
  });

  final QuickRoadTripResult? initialRoute;
  final ScrollController scrollController;
  final CreateRoadTripMode mode;
  final bool embeddedMode;
  // 用于位置选择模式
  final ValueListenable<LatLng?>? startPositionListenable;
  final ValueListenable<LatLng?>? destinationListenable;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Future<void> Function(QuickRoadTripResult)? onCreateQuickTrip;
  final VoidCallback? onOpenDetailed;
  
  @override
  ConsumerState<CreateRoadTripSheet> createState() => _CreateRoadTripSheetState();
}

// 1) 定义 Section 锚点
enum TripSection { basic, route, team, prefs, gallery, story, disclaimer }

class _CreateRoadTripSheetState extends ConsumerState<CreateRoadTripSheet> {
  @override
  Widget build(BuildContext context) {
    return _CreateRoadTripContent(
      scrollCtrl: widget.scrollController,
      initialRoute: widget.initialRoute,
      embeddedMode: widget.embeddedMode,
      mode: widget.mode,
      startPositionListenable: widget.startPositionListenable,
      destinationListenable: widget.destinationListenable,
      onConfirm: widget.onConfirm,
      onCancel: widget.onCancel,
      onCreateQuickTrip: widget.onCreateQuickTrip,
      onOpenDetailed: widget.onOpenDetailed,
    );
  }
}

class _CreateRoadTripContent extends ConsumerStatefulWidget {
  const _CreateRoadTripContent({
    required this.scrollCtrl,
    required this.embeddedMode,
    required this.mode,
    this.initialRoute,
    this.startPositionListenable,
    this.destinationListenable,
    this.onConfirm,
    this.onCancel,
    this.onCreateQuickTrip,
    this.onOpenDetailed,
  });

  final ScrollController scrollCtrl; // 由外部传入
  final bool embeddedMode; // true: 嵌入 Overlay; false: 弹窗
  final CreateRoadTripMode mode;
  final QuickRoadTripResult? initialRoute;
  final ValueListenable<LatLng?>? startPositionListenable;
  final ValueListenable<LatLng?>? destinationListenable;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Future<void> Function(QuickRoadTripResult)? onCreateQuickTrip;
  final VoidCallback? onOpenDetailed;

  @override
  ConsumerState<_CreateRoadTripContent> createState() => _PlannerContentState();
}

class _PlannerContentState extends ConsumerState<_CreateRoadTripContent>
    with TickerProviderStateMixin {
  // ===== 内部状态 =====
  final _pageCtrl = PageController();
  bool _canSwipe = false; // 初始只展示启动页
  int _currentPage = 0;

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
  final List<LatLng> _forwardWps = []; // 去程途经点
  final List<LatLng> _returnWps = [];  // 返程途经点
  // 途经点地址缓存：key 为 '${lat}_${lng}'，value 为地址
  final Map<String, String> _waypointAddressCache = {};
  final Map<String, Future<String?>> _waypointAddressFutures = {};

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

  // ==== 创建状态 ====
  bool _isCreating = false;
  bool? _createSuccess;
  String? _tripId;
  String? _createErrorMessage;

  // ==== 分段顺序 ====
  static const List<TripSection> _sectionsOrder = [
    TripSection.basic,
    TripSection.route,
    TripSection.team,
    TripSection.prefs,
    TripSection.gallery,
    TripSection.story,
    TripSection.disclaimer,
  ];
  int get _totalPages => 1 + _sectionsOrder.length + 1; // +1 为完成页
  bool get _isBasicPage => _currentPage == 1; // 0 是启动页，1 是 basic
  bool get _isCompletionPage => _currentPage == _totalPages - 1; // 最后一页是完成页
  bool get _basicValid =>
      _titleCtrl.text.trim().isNotEmpty && _editorState.dateRange != null;

  // ===== 生命周期 =====
  @override
  void initState() {
    super.initState();

    // 根据模式初始化位置信息
    if (widget.mode == CreateRoadTripMode.startLocationOnly) {
      // 从 ValueListenable 读取起点位置
      if (widget.startPositionListenable != null) {
        _startLatLng = widget.startPositionListenable!.value;
        widget.startPositionListenable!.addListener(_onStartPositionChanged);
        _updateStartLocation(_startLatLng);
      }
    } else {
      // 完整创建模式：从 initialRoute 读取，同时也监听 ValueListenable 的变化
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

      // 如果提供了 ValueListenable，也监听位置变化
      if (widget.startPositionListenable != null) {
        final currentStart = widget.startPositionListenable!.value;
        if (currentStart != null && currentStart != _startLatLng) {
          _startLatLng = currentStart;
        }
        widget.startPositionListenable!.addListener(_onStartPositionChanged);
      }
      
      if (widget.destinationListenable != null) {
        final currentDestination = widget.destinationListenable!.value;
        if (currentDestination != null && currentDestination != _destinationLatLng) {
          _destinationLatLng = currentDestination;
        }
        widget.destinationListenable!.addListener(_onDestinationPositionChanged);
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
        final hasAddress = _destinationAddress != null &&
            _destinationAddress!.trim().isNotEmpty;
        _destinationAddressFuture = hasAddress
            ? Future<String?>.value(_destinationAddress)
            : _loadAddress(_destinationLatLng!, isStart: false);
        _destinationNearbyFuture = _loadNearbyPlaces(_destinationLatLng!);
      }
    }

    _pageCtrl.addListener(() {
      final p = _pageCtrl.hasClients ? _pageCtrl.page?.round() ?? 0 : 0;
      if (p != _currentPage) {
        setState(() => _currentPage = p);
      }
    });

    _titleCtrl.addListener(() => setState(() {})); // 标题变化触发校验
  }

  void _onStartPositionChanged() {
    if (!mounted) return;
    final newPosition = widget.startPositionListenable?.value;
    if (newPosition != _startLatLng) {
      _updateStartLocation(newPosition);
    }
  }

  void _onDestinationPositionChanged() {
    if (!mounted) return;
    final newPosition = widget.destinationListenable?.value;
    if (newPosition != _destinationLatLng) {
      _updateDestinationLocation(newPosition);
    }
  }

  void _updateStartLocation(LatLng? position) {
    setState(() {
      _startLatLng = position;
      if (position != null) {
        _startAddressFuture = _loadAddress(position, isStart: true);
        _startNearbyFuture = _loadNearbyPlaces(position);
      } else {
        _startAddressFuture = null;
        _startNearbyFuture = null;
        _startAddress = null;
      }
    });
  }

  void _updateDestinationLocation(LatLng? position) {
    setState(() {
      _destinationLatLng = position;
      if (position != null) {
        _destinationAddressFuture = _loadAddress(position, isStart: false);
        _destinationNearbyFuture = _loadNearbyPlaces(position);
      } else {
        _destinationAddressFuture = null;
        _destinationNearbyFuture = null;
        _destinationAddress = null;
      }
    });
  }

  @override
  void dispose() {
    widget.startPositionListenable?.removeListener(_onStartPositionChanged);
    widget.destinationListenable?.removeListener(_onDestinationPositionChanged);
    _titleCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _priceCtrl.dispose();
    _tagInputCtrl.dispose();
    _storyCtrl.dispose();
    _disclaimerCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  // ===== 异步 & 交互函数 =====
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
      setState(() => _editorState = _editorState.copyWith(dateRange: picked));
    }
  }

  Future<void> _onCreatePressed() async {
    // 根据模式处理不同的操作
    if (widget.mode == CreateRoadTripMode.startLocationOnly) {
      // 起点确认模式：调用 onConfirm
      widget.onConfirm?.call();
    } else {
      // 完整创建模式：验证并创建
      if (!_basicValid) {
        _showSnack('请填写完整的基本信息');
        return;
      }

      if (_startLatLng == null || _destinationLatLng == null) {
        _showSnack('请选择起点和终点');
        return;
      }

      if (!mounted) return;
      
      // 设置创建状态
      setState(() {
        _isCreating = true;
        _createSuccess = null;
        _tripId = null;
        _createErrorMessage = null;
      });
      
      try {
        // 文本长度验证
        final title = _titleCtrl.text.trim();
        if (title.length > 20) {
          _showSnack('标题不能超过20个字符');
          setState(() {
            _isCreating = false;
          });
          return;
        }

        // 价格验证
        double? price;
        if (_pricingType == RoadTripPricingType.paid) {
          price = double.tryParse(_priceCtrl.text.trim());
          if (price == null || price < 0 || price > 100) {
            _showSnack('请输入有效的人均费用（0-100）');
            setState(() {
              _isCreating = false;
            });
            return;
          }
        }

        // 坐标范围验证 - 起点和终点
        if (_startLatLng!.latitude < -90 ||
            _startLatLng!.latitude > 90 ||
            _startLatLng!.longitude < -180 ||
            _startLatLng!.longitude > 180 ||
            _destinationLatLng!.latitude < -90 ||
            _destinationLatLng!.latitude > 90 ||
            _destinationLatLng!.longitude < -180 ||
            _destinationLatLng!.longitude > 180) {
          _showSnack('坐标值无效，请重新选择位置');
          setState(() {
            _isCreating = false;
          });
          return;
        }

        // 坐标范围验证 - 途经点
        final allWaypoints = [..._forwardWps, ..._returnWps];
        for (final wp in allWaypoints) {
          if (wp.latitude < -90 ||
              wp.latitude > 90 ||
              wp.longitude < -180 ||
              wp.longitude > 180) {
            _showSnack('坐标值无效，请重新选择位置');
            setState(() {
              _isCreating = false;
            });
            return;
          }
        }

        final maxParticipants = int.tryParse(_maxParticipantsCtrl.text.trim()) ?? 4;
        
        final draft = RoadTripDraft(
          title: title,
          dateRange: _editorState.dateRange!,
          startLocation: _startAddress ?? 
              '${_startLatLng!.latitude.toStringAsFixed(6)}, ${_startLatLng!.longitude.toStringAsFixed(6)}',
          endLocation: _destinationAddress ?? 
              '${_destinationLatLng!.latitude.toStringAsFixed(6)}, ${_destinationLatLng!.longitude.toStringAsFixed(6)}',
          meetingPoint: _startAddress ?? 
              '${_startLatLng!.latitude.toStringAsFixed(6)}, ${_startLatLng!.longitude.toStringAsFixed(6)}',
          isRoundTrip: _routeType == RoadTripRouteType.roundTrip,
          waypoints: [
            ..._forwardWps.map((wp) => '${wp.latitude},${wp.longitude}'),
            ..._returnWps.map((wp) => '${wp.latitude},${wp.longitude}'),
          ],
          maxParticipants: maxParticipants,
          isFree: _pricingType == RoadTripPricingType.free,
          pricePerPerson: price,
          carType: _carType,
          tags: List.of(_tags),
          description: _storyCtrl.text.trim(),
          hostDisclaimer: _disclaimerCtrl.text.trim(),
          galleryImages: _editorState.galleryItems
              .where((item) => item.file != null)
              .map((item) => item.file!)
              .toList(),
          existingImageUrls: _editorState.galleryItems
              .where((item) => item.url != null)
              .map((item) => item.url!)
              .toList(),
        );

        // 调用API创建
        final id = await ref.read(eventsApiProvider).createRoadTrip(draft);
        
        if (!mounted) return;
        
        // 设置成功状态并跳转到完成页
        setState(() {
          _isCreating = false;
          _createSuccess = true;
          _tripId = id;
        });
        
        // 跳转到完成页
        setState(() => _canSwipe = true);
        await _pageCtrl.animateToPage(
          _totalPages - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        
      } catch (e) {
        if (!mounted) return;
        
        // 设置失败状态并跳转到完成页
        setState(() {
          _isCreating = false;
          _createSuccess = false;
          _createErrorMessage = e.toString();
        });
        
        // 跳转到完成页
        setState(() => _canSwipe = true);
        await _pageCtrl.animateToPage(
          _totalPages - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onDonePressed() {
    // 清理所有地图选择状态
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.resetSelection();
    selectionController.setSelectionSheetOpen(false);
    selectionController.setPendingWaypoint(null);
    selectionController.resetMapPadding();
    
    // 关闭 overlay
    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
  }

  void _onRouteTypeChanged(RoadTripRouteType t) {
    setState(() => _routeType = t);
    // 更新 MapSelectionController 中的路线类型
    ref.read(mapSelectionControllerProvider.notifier).setRouteType(t);
  }

  // 进入添加途经点模式
  void _onAddForward() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.setAddingWaypoint(true, isForward: true);
    // 如果已经有起点，定位到起点；否则保持当前视图
    if (_startLatLng != null) {
      final mapController = ref.read(mapControllerProvider);
      unawaited(mapController.moveCamera(_startLatLng!, zoom: 12));
    }
  }
  void _onRemoveForward(int i) {
    if (i >= 0 && i < _forwardWps.length) {
      final removed = _forwardWps[i];
      final key = '${removed.latitude}_${removed.longitude}';
      setState(() { 
        _forwardWps.removeAt(i);
        _waypointAddressCache.remove(key);
        _waypointAddressFutures.remove(key);
      });
      // 更新 MapSelectionController（延迟到下一帧）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(mapSelectionControllerProvider.notifier).setForwardWaypoints(_forwardWps);
        }
      });
    }
  }
  
  void _onReorderForward(int oldIndex, int newIndex) {
    setState(() { final item = _forwardWps.removeAt(oldIndex); _forwardWps.insert(newIndex, item); });
    // 更新 MapSelectionController（延迟到下一帧）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mapSelectionControllerProvider.notifier).setForwardWaypoints(_forwardWps);
      }
    });
  }

  void _onAddReturn() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.setAddingWaypoint(true, isForward: false);
    if (_destinationLatLng != null) {
      final mapController = ref.read(mapControllerProvider);
      unawaited(mapController.moveCamera(_destinationLatLng!, zoom: 12));
    }
  }
  void _onRemoveReturn(int i) {
    if (i >= 0 && i < _returnWps.length) {
      final removed = _returnWps[i];
      final key = '${removed.latitude}_${removed.longitude}';
      setState(() { 
        _returnWps.removeAt(i);
        _waypointAddressCache.remove(key);
        _waypointAddressFutures.remove(key);
      });
      // 更新 MapSelectionController（延迟到下一帧）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(mapSelectionControllerProvider.notifier).setReturnWaypoints(_returnWps);
        }
      });
    }
  }
  
  void _onReorderReturn(int oldIndex, int newIndex) {
    setState(() { final item = _returnWps.removeAt(oldIndex); _returnWps.insert(newIndex, item); });
    // 更新 MapSelectionController（延迟到下一帧）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mapSelectionControllerProvider.notifier).setReturnWaypoints(_returnWps);
      }
    });
  }

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
      if (picked.isEmpty) return;
      setState(() {
        final newItems =
            picked.map((x) => RoadTripGalleryItem.file(File(x.path))).toList();
        _editorState = _editorState.copyWith(
          galleryItems: [..._editorState.galleryItems, ...newItems],
        );
      });
    } on PlatformException {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      _showSnack(loc.road_trip_image_picker_failed);
    }
  }

  void _onRemoveImage(int i) {
    final items = _editorState.galleryItems;
    if (i < 0 || i >= items.length) return;
    setState(() {
      final updated = List<RoadTripGalleryItem>.of(items)..removeAt(i);
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _onSetCover(int i) {
    final items = _editorState.galleryItems;
    if (i <= 0 || i >= items.length) return;
    setState(() {
      final updated = List<RoadTripGalleryItem>.of(items);
      final item = updated.removeAt(i);
      updated.insert(0, item);
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _loadAddress(LatLng latLng, {required bool isStart}) {
    final manager = ref.read(locationSelectionManagerProvider);
    final future = manager.reverseGeocode(latLng);
    future.then((value) {
      if (!mounted) return;
      final trimmed = value?.trim();
      if (isStart) {
        setState(() => _startAddress = (trimmed == null || trimmed.isEmpty) ? null : trimmed);
      } else {
        setState(() => _destinationAddress = (trimmed == null || trimmed.isEmpty) ? null : trimmed);
      }
    });
    return future;
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng latLng) {
    final manager = ref.read(locationSelectionManagerProvider);
    return manager.fetchNearbyPlaces(latLng);
  }

  Future<void> _restartSelectionFlow({required bool skipStart}) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);
    
    // overlay 模式下，所有操作都在同一个 overlay 内完成
    if (widget.embeddedMode) {
      if (skipStart && _startLatLng != null) {
        // 跳过起点选择，直接进入终点选择模式
        selectionController.setSelectingDestination(true);
        if (_destinationLatLng != null) {
          unawaited(mapController.moveCamera(_destinationLatLng!, zoom: 12));
        } else {
          selectionController.setDestinationLatLng(null);
          unawaited(mapController.moveCamera(_startLatLng!, zoom: 6));
        }
      } else {
        // 重新开始起点选择
        selectionController.setSelectingDestination(false);
        selectionController.setSelectedLatLng(_startLatLng);
        if (_startLatLng != null) {
          unawaited(mapController.moveCamera(_startLatLng!, zoom: 12));
        }
      }
      
      // 确保 overlay 打开
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
    } else {
      // 弹窗模式：关闭当前sheet，然后打开 overlay
      Navigator.of(context).pop();
      
      final manager = ref.read(locationSelectionManagerProvider);
      await Future<void>.microtask(() => manager.startRouteSelectionFlow(
            context,
            initialStart: _startLatLng,
            initialDestination: _destinationLatLng,
            skipStart: skipStart && _startLatLng != null,
          ));
    }
  }

  // 处理起点卡片点击
  Future<void> _onEditDeparture() async {
    await _restartSelectionFlow(skipStart: false);
  }

  // 处理终点卡片点击
  Future<void> _onEditDestination() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    // 如果已经有终点，定位到终点位置（类似起点的行为）
    if (_destinationLatLng != null) {
      // 设置终点选择模式
      selectionController.setSelectingDestination(true);
      
      // 确保 overlay 打开（保持在 fullCreation 模式）
      if (widget.embeddedMode) {
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
      } else {
        // 弹窗模式：关闭当前sheet，然后打开 overlay
        Navigator.of(context).pop();
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
      }
      
      // 定位到终点
      await mapController.moveCamera(_destinationLatLng!, zoom: 12);
      return;
    }

    // 如果没有终点，设置终点选择模式，让用户在地图上选择
    selectionController.setSelectingDestination(true);
    
    // 确保 overlay 打开（保持在 fullCreation 模式）
    if (widget.embeddedMode) {
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
    } else {
      // 弹窗模式：关闭当前sheet，然后打开 overlay
      Navigator.of(context).pop();
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
    }
    
    // 定位地图到起点（缩放以便选择终点）
    if (_startLatLng != null) {
      unawaited(mapController.moveCamera(_startLatLng!, zoom: 6));
    }
  }

  Future<void> goToSection(TripSection s) async {
    final idx = _sectionsOrder.indexOf(s);
    if (idx < 0) return;
    setState(() => _canSwipe = true);
    try {
      await _pageCtrl.animateToPage(
        1 + idx, // 0 是启动页
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } catch (e, stackTrace) {
      // 记录页面切换错误（当PageView已销毁时这是正常情况）
      debugPrint('Page animation error: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  void _enableWizard() {
    // 先更新状态，然后在下一帧执行动画，确保 PageView 的 physics 已经更新
    setState(() => _canSwipe = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (_pageCtrl.hasClients) {
          _pageCtrl.animateToPage(
            1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
          );
        }
      } catch (e, stackTrace) {
        // 记录页面切换错误（当PageView已销毁时这是正常情况）
        debugPrint('Page animation error: $e');
        if (kDebugMode) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
    });
  }

  // ===== UI 构建 =====
  Widget _buildSectionPage(TripSection s) {
    Widget content;
    switch (s) {
      case TripSection.basic:
        content = RoadTripBasicSection(
          titleController: _titleCtrl,
          dateRange: _editorState.dateRange,
          onPickDateRange: _pickDateRange,
        );
        break;
        case TripSection.route:
        content = RoadTripRouteSection(
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
          waypointAddressMap: _waypointAddressCache,
        );
        break;
      case TripSection.team:
        content = RoadTripTeamSection(
          maxParticipantsController: _maxParticipantsCtrl,
          priceController: _priceCtrl,
          pricingType: _pricingType,
          onPricingTypeChanged: (v) => setState(() => _pricingType = v),
        );
        break;
      case TripSection.prefs:
        content = RoadTripPreferencesSection(
          carType: _carType,
          onCarTypeChanged: _onCarTypeChanged,
          tagInputController: _tagInputCtrl,
          onSubmitTag: _onSubmitTag,
          tags: _tags,
          onRemoveTag: _onRemoveTag,
        );
        break;
      case TripSection.gallery:
        content = RoadTripGallerySection(
          items: _editorState.galleryItems,
          onPickImages: _onPickImages,
          onRemoveImage: _onRemoveImage,
          onSetCover: _onSetCover,
        );
        break;
      case TripSection.story:
        content = RoadTripStorySection(descriptionController: _storyCtrl);
        break;
      case TripSection.disclaimer:
        content = RoadTripHostDisclaimerSection(disclaimerController: _disclaimerCtrl);
        break;
    }
    
    // 包装在可滚动容器中，适配 overlay sheet 的高度限制
    return SingleChildScrollView(
      controller: null, // 其他页面不使用 controller
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // 监听途经点变化（必须在 build 方法中使用 ref.listen）
    ref.listen<MapSelectionState>(mapSelectionControllerProvider, (previous, next) {
      // 处理新途经点添加
      if (next.pendingWaypoint != null && previous?.pendingWaypoint != next.pendingWaypoint) {
        // 有新途经点添加
        final isForward = previous?.isAddingForwardWaypoint ?? true;
        final newWaypoint = next.pendingWaypoint!;
        setState(() {
          if (isForward) {
            _forwardWps.add(newWaypoint);
          } else {
            _returnWps.add(newWaypoint);
          }
        });
        // 异步加载途经点地址
        final key = '${newWaypoint.latitude}_${newWaypoint.longitude}';
        if (!_waypointAddressFutures.containsKey(key)) {
          _waypointAddressFutures[key] = _loadAddress(newWaypoint, isStart: false);
          _waypointAddressFutures[key]!.then((address) {
            if (!mounted) return;
            if (address != null && address.trim().isNotEmpty) {
              setState(() {
                _waypointAddressCache[key] = address.trim();
              });
            }
          });
        }
        // 更新 MapSelectionController 中的途经点列表（延迟到下一帧，避免在监听器中直接更新状态）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final selectionController = ref.read(mapSelectionControllerProvider.notifier);
          selectionController.setForwardWaypoints(_forwardWps);
          selectionController.setReturnWaypoints(_returnWps);
          selectionController.setRouteType(_routeType);
          // 清除临时途经点
          selectionController.setPendingWaypoint(null);
        });
      }
      
      // 处理途经点位置变化（来自拖动）
      // 检查 forwardWaypoints 是否发生变化
      if (previous?.forwardWaypoints != next.forwardWaypoints) {
        final newForwardWps = next.forwardWaypoints;
        if (newForwardWps.length == _forwardWps.length) {
          // 长度相同，可能是位置更新
          bool hasChange = false;
          for (int i = 0; i < newForwardWps.length; i++) {
            if (newForwardWps[i] != _forwardWps[i]) {
              hasChange = true;
              break;
            }
          }
          if (hasChange) {
            setState(() {
              _forwardWps.clear();
              _forwardWps.addAll(newForwardWps);
              // 清除旧地址缓存，重新加载
              _waypointAddressCache.clear();
              _waypointAddressFutures.clear();
              // 为每个途经点加载新地址
              for (final wp in newForwardWps) {
                final key = '${wp.latitude}_${wp.longitude}';
                _waypointAddressFutures[key] = _loadAddress(wp, isStart: false);
                _waypointAddressFutures[key]!.then((address) {
                  if (!mounted) return;
                  if (address != null && address.trim().isNotEmpty) {
                    setState(() {
                      _waypointAddressCache[key] = address.trim();
                    });
                  }
                });
              }
            });
          }
        }
      }
      
      // 检查 returnWaypoints 是否发生变化
      if (previous?.returnWaypoints != next.returnWaypoints) {
        final newReturnWps = next.returnWaypoints;
        if (newReturnWps.length == _returnWps.length) {
          // 长度相同，可能是位置更新
          bool hasChange = false;
          for (int i = 0; i < newReturnWps.length; i++) {
            if (newReturnWps[i] != _returnWps[i]) {
              hasChange = true;
              break;
            }
          }
          if (hasChange) {
            setState(() {
              _returnWps.clear();
              _returnWps.addAll(newReturnWps);
              // 清除旧地址缓存，重新加载
              // 注意：这里只处理返程途经点的地址，如果地址缓存key包含方向信息，需要区分
              for (final wp in newReturnWps) {
                final key = '${wp.latitude}_${wp.longitude}';
                if (!_waypointAddressCache.containsKey(key)) {
                  _waypointAddressFutures[key] = _loadAddress(wp, isStart: false);
                  _waypointAddressFutures[key]!.then((address) {
                    if (!mounted) return;
                    if (address != null && address.trim().isNotEmpty) {
                      setState(() {
                        _waypointAddressCache[key] = address.trim();
                      });
                    }
                  });
                }
              }
            });
          }
        }
      }
    });

    // 根据模式显示不同的UI
    if (widget.mode == CreateRoadTripMode.startLocationOnly) {
      return _buildStartLocationOnlyUI(context, theme, loc);
    }

    // 完整创建模式：保持原有UI
    final canScroll = _canSwipe && !(_isBasicPage && !_basicValid);

    // 计算启动页展示信息（起终点坐标/地址）
    final hasStartAddress = _startAddress != null && _startAddress!.trim().isNotEmpty;
    final hasDestinationAddress =
        _destinationAddress != null && _destinationAddress!.trim().isNotEmpty;

    final startCoords = _startLatLng != null
        ? '${_startLatLng!.latitude.toStringAsFixed(6)}, ${_startLatLng!.longitude.toStringAsFixed(6)}'
        : null;
    final destinationCoords = _destinationLatLng != null
        ? '${_destinationLatLng!.latitude.toStringAsFixed(6)}, ${_destinationLatLng!.longitude.toStringAsFixed(6)}'
        : null;

    final startTitle = hasStartAddress
        ? _startAddress!.trim()
        : (startCoords ?? loc.map_select_location_title);
    final startSubtitle = _startLatLng != null
        ? ''
        : loc.map_select_location_tip;

    final destinationTitle = hasDestinationAddress
        ? _destinationAddress!.trim()
        : (destinationCoords ?? loc.map_select_location_destination_label);
    final destinationSubtitle = _destinationLatLng != null
        ? ''
        : loc.map_select_location_destination_tip;

    // 顶部把手 + TabBar + PageView + 底部操作，与原版一致
    return Material(
      color: theme.colorScheme.surface,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (n) {
                  n.disallowIndicator();
                  return true;
                },
                child: PageView(
                  controller: _pageCtrl,
                  physics: (_isCompletionPage || !canScroll)
                      ? const NeverScrollableScrollPhysics()
                      : (_currentPage >= _totalPages - 2
                          ? const NeverScrollableScrollPhysics() // 防止滑动到完成页
                          : const PageScrollPhysics()),
                  children: [
                    _RouteSelectionPage(
                      scrollCtrl: widget.scrollCtrl,
                      onContinue: _enableWizard,
                      departureTitle: startTitle,
                      departureSubtitle: startSubtitle,
                      destinationTitle: destinationTitle,
                      destinationSubtitle: destinationSubtitle,
                      onEditDeparture: _onEditDeparture,
                      onEditDestination: _onEditDestination,
                      departurePosition: _startLatLng,
                      departureAddressFuture: _startAddressFuture,
                      departureNearbyFuture: _startNearbyFuture,
                      destinationPosition: _destinationLatLng,
                      destinationAddressFuture: _destinationAddressFuture,
                      destinationNearbyFuture: _destinationNearbyFuture,
                    ),
                    ..._sectionsOrder.map(_buildSectionPage),
                    _CompletionPage(
                      isSuccess: _createSuccess,
                      tripId: _tripId,
                      errorMessage: _createErrorMessage,
                      isCreating: _isCreating,
                      onDone: _onDonePressed,
                    ),
                  ],
                ),
              ),
            ),
            // 底部进度 + 按钮
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _isCompletionPage
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (!_isCreating && _createSuccess != null)
                              ? _onDonePressed
                              : null,
                          child: _isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(loc.road_trip_create_done_button),
                        ),
                      ),
                    )
                  : _canSwipe
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: SmoothPageIndicator(
                                  controller: _pageCtrl,
                                  count: _totalPages - 1, // 不包含完成页
                                  effect: const WormEffect(dotHeight: 8, dotWidth: 8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: (!canScroll || _isCreating) 
                                      ? null 
                                      : _onCreatePressed,
                                  child: _isCreating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(loc.road_trip_create_button),
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
                              // 只有当起点和终点都选择了才能继续
                              onPressed: (_startLatLng != null && _destinationLatLng != null)
                                  ? _enableWizard
                                  : null,
                              child: Text(loc.road_trip_continue_button),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建起点确认UI（替代 StartLocationSheet）
  Widget _buildStartLocationOnlyUI(BuildContext context, ThemeData theme, AppLocalizations loc) {
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final tipStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
    );

    return Material(
      color: theme.colorScheme.surface,
      child: ListView(
        controller: widget.scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + viewPadding + viewInsets,
        ),
        children: [
          const SheetHandle(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.map_select_location_title,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.map_select_location_tip,
                      style: tipStyle,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: loc.action_cancel,
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_startLatLng != null) ...[
            ValueListenableBuilder<LatLng?>(
              valueListenable: widget.startPositionListenable!,
              builder: (context, position, _) {
                if (position == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_startAddressFuture != null)
                      FutureBuilder<String?>(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start_info',
                        ),
                        future: _startAddressFuture,
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
                          return LocationSheetRow(
                            icon: icon,
                            child: Text(display),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    if (_startNearbyFuture != null)
                      NearbyPlacesPreview(
                        key: ValueKey(
                          '${position.latitude}_${position.longitude}_start_nearby',
                        ),
                        future: _startNearbyFuture!,
                      ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: Text(loc.action_cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: widget.onConfirm,
                  child: Text(loc.map_location_info_create_event),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class _RouteSelectionPage extends StatelessWidget {
  const _RouteSelectionPage({
    this.scrollCtrl,
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
  final ScrollController? scrollCtrl;
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
    // 直接使用 scrollCtrl，如果为 null 则不使用 controller
    // 让 DraggableScrollableSheet 的滚动控制器直接连接到这个 CustomScrollView
    return CustomScrollView(
      controller: scrollCtrl,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: [
              _CardTile(
                leading: const Icon(Icons.radio_button_checked),
                title: departureTitle,
                subtitle: null,
                onTap: onEditDeparture,
              ),
              const SizedBox(height: 12),
              _CardTile(
                leading: const Icon(Icons.place_outlined),
                title: destinationTitle,
                subtitle: null,
                onTap: departurePosition != null ? onEditDestination : null,
                enabled: departurePosition != null,
              ),
              const SizedBox(height: 24),
              _UnifiedNearbyPlacesList(
                startNearbyFuture: departureNearbyFuture,
                destinationNearbyFuture: destinationNearbyFuture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UnifiedNearbyPlacesList extends StatelessWidget {
  const _UnifiedNearbyPlacesList({
    this.startNearbyFuture,
    this.destinationNearbyFuture,
  });

  final Future<List<NearbyPlace>>? startNearbyFuture;
  final Future<List<NearbyPlace>>? destinationNearbyFuture;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 如果两个future都不存在，不显示任何内容
    if (startNearbyFuture == null && destinationNearbyFuture == null) {
      return const SizedBox.shrink();
    }

    // 使用 Future.wait 等待所有future完成
    final futures = <Future<List<NearbyPlace>>>[];
    if (startNearbyFuture != null) {
      futures.add(startNearbyFuture!);
    }
    if (destinationNearbyFuture != null) {
      futures.add(destinationNearbyFuture!);
    }

    return FutureBuilder<List<List<NearbyPlace>>>(
      future: Future.wait(futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                loc.map_location_info_nearby_error,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        // 合并所有POI列表，去重（基于id）
        final allPlaces = <String, NearbyPlace>{};
        final results = snapshot.data ?? [];
        for (final placeList in results) {
          for (final place in placeList) {
            allPlaces[place.id] = place;
          }
        }

        final places = allPlaces.values.toList();

        if (places.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.map_location_info_nearby_title,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                loc.map_location_info_nearby_empty,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.map_location_info_nearby_title,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < places.length; i++) ...[
                  NearbyPlaceTile(place: places[i]),
                  if (i < places.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.enabled = true,
  });
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: opacity,
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
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
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
      ),
    );
  }
}

/// 创建完成页面
class _CompletionPage extends StatelessWidget {
  const _CompletionPage({
    required this.isSuccess,
    this.tripId,
    this.errorMessage,
    required this.isCreating,
    required this.onDone,
  });

  final bool? isSuccess;
  final String? tripId;
  final String? errorMessage;
  final bool isCreating;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // 图标
          if (isCreating)
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess == true
                    ? colorScheme.primaryContainer
                    : colorScheme.errorContainer,
              ),
              child: Icon(
                isSuccess == true ? Icons.check_circle : Icons.error_outline,
                size: 48,
                color: isSuccess == true
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onErrorContainer,
              ),
            ),
          const SizedBox(height: 32),
          // 标题
          if (!isCreating)
            Text(
              isSuccess == true
                  ? loc.road_trip_create_success_title
                  : loc.road_trip_create_failed_title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          // 消息
          if (!isCreating)
            Text(
              isSuccess == true
                  ? loc.road_trip_create_success_message
                  : (errorMessage ?? loc.road_trip_create_failed_message),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}