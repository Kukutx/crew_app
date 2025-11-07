import 'dart:async';
import 'dart:io';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:crew_app/shared/widgets/sheets/completion_sheet/completion_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_basic_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_gallery_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_host_disclaimer_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_route_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_story_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_team_section.dart';
import 'package:crew_app/features/events/presentation/pages/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/events/presentation/pages/trips/pages/location_search_page.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/trips/utils/road_trip_form_validation_utils.dart';
import 'package:crew_app/features/events/presentation/pages/trips/utils/road_trip_address_loader.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/route_selection_page.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/clickable_page_indicator.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    // 用于暴露状态给外部（events_map_page.dart）
    this.onCanSwipeChanged,
    this.onTabIndexChanged,
    // 用于外部控制 TabController
    this.tabChangeNotifier,
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
  // 用于暴露状态给外部
  final ValueChanged<bool>? onCanSwipeChanged;
  final ValueChanged<int>? onTabIndexChanged;
  // 用于外部控制 TabController
  final ValueNotifier<int>? tabChangeNotifier;
  
  @override
  ConsumerState<CreateRoadTripSheet> createState() => _CreateRoadTripSheetState();
}

// 1) 定义 Section 锚点
enum TripSection { basic, route, team, gallery, story, disclaimer }

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
      onCanSwipeChanged: widget.onCanSwipeChanged,
      onTabIndexChanged: widget.onTabIndexChanged,
      tabChangeNotifier: widget.tabChangeNotifier,
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
    this.onCanSwipeChanged,
    this.onTabIndexChanged,
    this.tabChangeNotifier,
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
  // 用于暴露状态给外部
  final ValueChanged<bool>? onCanSwipeChanged;
  final ValueChanged<int>? onTabIndexChanged;
  // 用于外部控制 TabController
  final ValueNotifier<int>? tabChangeNotifier;

  @override
  ConsumerState<_CreateRoadTripContent> createState() => _PlannerContentState();
}

class _PlannerContentState extends ConsumerState<_CreateRoadTripContent>
    with TickerProviderStateMixin {
  // ===== 内部状态 =====
  late final TabController _tabController; // 路线/途径点 TabController
  final PageController _routePageCtrl = PageController(); // 路线 tab 内的 PageView
  bool _canSwipe = false; // 是否显示 ToggleTabBar 和其他 section（点击 basic 的继续后为 true）
  int _currentRoutePage = 0; // 路线 tab 内的当前页面
  // 用于跟踪哪些页面应该使用 scrollController
  // 使用 Set 来记录当前应该使用 scrollController 的页面索引和 tab 索引
  int? _activeScrollablePageIndex; // 路线 tab 中当前活跃的页面索引（null 表示路线 tab 不活跃）
  int? _activeScrollableTabIndex; // 当前活跃的 tab 索引

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
  int _maxParticipants = 4;
  double? _price;
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
  // 以下字段保留用于可能的扩展或调试
  // ignore: unused_field
  bool? _createSuccess;
  // ignore: unused_field
  String? _tripId;
  // ignore: unused_field
  String? _createErrorMessage;

  // ==== 分段顺序 ====
  // 路线 tab 中的 section 顺序（不包含 route）
  static const List<TripSection> _routeSectionsOrder = [
    TripSection.basic,
    TripSection.team,
    TripSection.gallery,
    TripSection.story,
    TripSection.disclaimer,
  ];
  // 初始只有起始页和 basic 页（2个页面）
  // 点击 basic 的继续后，包含起始页、basic、team、gallery、story、disclaimer（6个页面）
  int get _totalRoutePages => _canSwipe ? 1 + _routeSectionsOrder.length : 2;
  bool get _isBasicPage => _currentRoutePage == 1; // 第二个页面是 basic
  bool get _isStartPage => _currentRoutePage == 0; // 第一个页面是起始页
  bool get _basicValid =>
      _titleCtrl.text.trim().isNotEmpty && _editorState.dateRange != null;
  bool get _startValid =>
      _startLatLng != null && _destinationLatLng != null; // 起始页是否有效
  // 是否已点击起始页的继续按钮
  bool _hasClickedStartContinue = false;

  // ===== 生命周期 =====
  @override
  void initState() {
    super.initState();
    // 初始化 TabController（路线/途径点）
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // 初始化活跃状态：默认在路线 tab 的第一个页面
    _activeScrollableTabIndex = 0;
    _activeScrollablePageIndex = 0;

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

    _titleCtrl.addListener(() => setState(() {})); // 标题变化触发校验
    
    // 监听外部 tab 切换请求
    if (widget.tabChangeNotifier != null) {
      widget.tabChangeNotifier!.addListener(_onTabChangeRequested);
    }
    
    // 初始化路线类型为往返，并同步到 MapSelectionController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mapSelectionControllerProvider.notifier).setRouteType(_routeType);
      }
    });
  }
  
  void _onTabChangeRequested() {
    if (!mounted || widget.tabChangeNotifier == null) return;
    final requestedIndex = widget.tabChangeNotifier!.value;
    if (!_tabController.indexIsChanging && _tabController.index != requestedIndex) {
      _tabController.animateTo(requestedIndex);
    }
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

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // 更新活跃的 tab 索引，确保只有当前活跃的 tab 使用 scrollController
      setState(() {
        _activeScrollableTabIndex = _tabController.index;
        // 如果切换到路线 tab，更新活跃页面索引
        if (_tabController.index == 0) {
          _activeScrollablePageIndex = _currentRoutePage;
        } else {
          // 如果切换到途径点 tab，清空页面索引（因为途径点 tab 不使用页面索引）
          _activeScrollablePageIndex = null;
        }
      });
      
      // 当切换回路线tab时，同步分页指示点
      if (_tabController.index == 0 && _routePageCtrl.hasClients) {
        // 使用 addPostFrameCallback 确保在 PageView 构建后同步
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            // 从 PageController 获取当前页面（四舍五入到最近的整数）
            final pageValue = _routePageCtrl.page;
            if (pageValue != null) {
              final currentPage = pageValue.round().clamp(0, _totalRoutePages - 1);
              if (currentPage != _currentRoutePage) {
                setState(() {
                  _currentRoutePage = currentPage;
                  _activeScrollablePageIndex = currentPage;
                });
              }
            }
          } catch (e) {
            // 如果获取失败，保持当前值不变
            debugPrint('Failed to sync current route page: $e');
          }
        });
      }
      // 通知外部 TabController 的 index 变化
      widget.onTabIndexChanged?.call(_tabController.index);
    }
  }
  
  @override
  void dispose() {
    widget.tabChangeNotifier?.removeListener(_onTabChangeRequested);
    widget.startPositionListenable?.removeListener(_onStartPositionChanged);
    widget.destinationListenable?.removeListener(_onDestinationPositionChanged);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _routePageCtrl.dispose();
    _titleCtrl.dispose();
    _tagInputCtrl.dispose();
    _storyCtrl.dispose();
    _disclaimerCtrl.dispose();
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
        final title = _titleCtrl.text.trim();
        
        // 使用验证工具类进行验证
        final validationErrors = RoadTripFormValidationUtils.validateForm(
          title: title,
          dateRange: _editorState.dateRange,
          startLatLng: _startLatLng,
          destinationLatLng: _destinationLatLng,
          forwardWaypoints: _forwardWps,
          returnWaypoints: _returnWps,
          pricingType: _pricingType,
          price: _price,
        );

        if (validationErrors.isNotEmpty) {
          _showSnack(validationErrors.first);
          setState(() {
            _isCreating = false;
          });
          return;
        }

        // 价格已经在验证工具类中验证，这里直接使用
        final price = _pricingType == RoadTripPricingType.paid ? _price : null;

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
          maxParticipants: _maxParticipants,
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
        
        // 设置成功状态并显示完成页 sheet
        setState(() {
          _isCreating = false;
          _createSuccess = true;
          _tripId = id;
        });
        
        // 清理所有地图选择状态（在关闭 sheet 之前执行，确保 ref 有效）
        final selectionController = ref.read(mapSelectionControllerProvider.notifier);
        selectionController.resetSelection();
        selectionController.setSelectionSheetOpen(false);
        selectionController.setPendingWaypoint(null);
        selectionController.resetMapPadding();
        
        // 关闭当前 sheet
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
        
        // 显示完成页 sheet
        if (mounted) {
          await showCompletionSheet(
            context,
            isSuccess: true,
          );
        }
        
      } catch (e) {
        if (!mounted) return;
        
        // 设置失败状态并显示完成页 sheet
        setState(() {
          _isCreating = false;
          _createSuccess = false;
          _createErrorMessage = e.toString();
        });
        
        // 清理所有地图选择状态（在关闭 sheet 之前执行，确保 ref 有效）
        final selectionController = ref.read(mapSelectionControllerProvider.notifier);
        selectionController.resetSelection();
        selectionController.setSelectionSheetOpen(false);
        selectionController.setPendingWaypoint(null);
        selectionController.resetMapPadding();
        
        // 关闭当前 sheet
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
        
        // 显示完成页 sheet
        if (mounted) {
          await showCompletionSheet(
            context,
            isSuccess: false,
            errorMessage: e.toString(),
          );
        }
      }
    }
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

  RoadTripAddressLoader get _addressLoader => RoadTripAddressLoader(ref);

  Future<String?> _loadAddress(LatLng latLng, {required bool isStart}) {
    final future = _addressLoader.loadFormattedAddress(latLng);
    future.then((value) {
      if (!mounted) return;
      if (isStart) {
        setState(() => _startAddress = value);
      } else {
        setState(() => _destinationAddress = value);
      }
    });
    return future;
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng latLng) {
    return _addressLoader.loadNearbyPlaces(latLng);
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

  // 处理起点 icon 点击 - 打开地址搜索页面
  Future<void> _onSearchStartLocation() async {
    final loc = AppLocalizations.of(context)!;
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSearchPage(
          title: loc.map_select_location_title,
          initialQuery: _startAddress,
          initialLocation: _startLatLng,
          onLocationSelected: (place) {
            final location = place.location;
            if (location == null) return;
            
            // 更新起点位置和地址
            setState(() {
              _startLatLng = location;
              _startAddress = place.formattedAddress ?? place.displayName;
              _startAddressFuture = Future.value(_startAddress);
              _startNearbyFuture = _loadNearbyPlaces(location);
            });
            
            // 更新选择状态
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setSelectedLatLng(location);
            
            // 移动地图到新位置
            final mapController = ref.read(mapControllerProvider);
            unawaited(mapController.moveCamera(location, zoom: 14));
          },
        ),
      ),
    );
  }

  // 处理终点 icon 点击 - 打开地址搜索页面
  Future<void> _onSearchDestination() async {
    final loc = AppLocalizations.of(context)!;
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSearchPage(
          title: loc.map_select_location_destination_label,
          initialQuery: _destinationAddress,
          initialLocation: _destinationLatLng ?? _startLatLng,
          onLocationSelected: (place) {
            final location = place.location;
            if (location == null) return;
            
            // 更新终点位置和地址
            setState(() {
              _destinationLatLng = location;
              _destinationAddress = place.formattedAddress ?? place.displayName;
              _destinationAddressFuture = Future.value(_destinationAddress);
              _destinationNearbyFuture = _loadNearbyPlaces(location);
            });
            
            // 更新选择状态
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDestinationLatLng(location);
            
            // 移动地图以显示起点和终点
            final mapController = ref.read(mapControllerProvider);
            if (_startLatLng != null) {
              unawaited(mapController.fitBounds(
                [_startLatLng!, location],
                padding: 100,
              ));
            } else {
              unawaited(mapController.moveCamera(location, zoom: 14));
            }
          },
        ),
      ),
    );
  }

  Future<void> goToSection(TripSection s) async {
    // 如果 section 是 route，切换到途径点 tab
    if (s == TripSection.route) {
      if (!_canSwipe) {
        setState(() => _canSwipe = true);
      }
      if (_tabController.index != 1) {
        _tabController.animateTo(1);
      }
      return;
    }
    
    // basic 页：索引 1
    if (s == TripSection.basic) {
      try {
        if (!_routePageCtrl.hasClients) return;
        await _routePageCtrl.animateToPage(
          1, // basic 页是第二个页面
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } catch (e, stackTrace) {
        debugPrint('Page animation error: $e');
        if (kDebugMode) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
      return;
    }
    
    // 其他 section（team, gallery, story, disclaimer）在路线 tab 中
    // 这些 section 只有在 _canSwipe 为 true 后才显示
    final idx = _routeSectionsOrder.indexOf(s);
    if (idx < 0) return;
    
    // 如果还没有显示这些 section，先显示它们
    if (!_canSwipe) {
      setState(() => _canSwipe = true);
    }
    
    // 确保在路线 tab
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
    
    // 切换到对应的页面（索引 = idx，因为第一个页面是起始页，第二个是 basic）
    try {
      if (!_routePageCtrl.hasClients) return;
      await _routePageCtrl.animateToPage(
        idx, // basic 是索引 1，team 是索引 2，以此类推
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } catch (e, stackTrace) {
      debugPrint('Page animation error: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  void _enableWizard() {
    // 从起始页点击继续，跳转到 basic 页（这是开放条件的开始）
    setState(() {
      _hasClickedStartContinue = true; // 标记已点击起始页的继续按钮
    });
    
    try {
      if (!_routePageCtrl.hasClients) return;
      _routePageCtrl.animateToPage(
        1, // 跳转到 basic 页
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e, stackTrace) {
      debugPrint('Page animation error: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  void _continueFromBasic() {
    // 从 basic 页点击继续，显示 ToggleTabBar 和其他 section，并跳转到下一页
    setState(() {
      _canSwipe = true;
    });
    // 通知外部 _canSwipe 变化
    widget.onCanSwipeChanged?.call(true);
    // 延迟到下一帧，确保 PageView 已经构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (!_routePageCtrl.hasClients) return;
        // 跳转到下一页（team 页，索引 2）
        _routePageCtrl.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e, stackTrace) {
        debugPrint('Page animation error: $e');
        if (kDebugMode) {
          debugPrint('Stack trace: $stackTrace');
        }
      }
    });
  }

  // ===== UI 构建 =====
  Widget _buildSectionPage(TripSection s, {bool isCurrentPage = false}) {
    Widget content;
    switch (s) {
      case TripSection.basic:
        content = RoadTripBasicSection(
          titleController: _titleCtrl,
          dateRange: _editorState.dateRange,
          onPickDateRange: _pickDateRange,
        );
        break;
      case TripSection.team:
        content = RoadTripTeamSection(
          maxParticipants: _maxParticipants,
          onMaxParticipantsChanged: (value) => setState(() {
            _maxParticipants = value;
          }),
          price: _price,
          onPriceChanged: (value) => setState(() {
            _price = value;
          }),
          pricingType: _pricingType,
          onPricingTypeChanged: (v) => setState(() {
            _pricingType = v;
            if (v == RoadTripPricingType.free) {
              _price = null;
            }
          }),
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
      case TripSection.route:
        // route section 不再在这里使用，已移到途径点 tab
        content = const SizedBox.shrink();
        break;
    }
    
    // 包装在可滚动容器中，适配 overlay sheet 的高度限制
    // 只在当前页面使用 scrollCtrl，避免 ScrollController 被多个可滚动组件共享
    return SingleChildScrollView(
      controller: isCurrentPage ? widget.scrollCtrl : null,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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

    // 完整创建模式
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
        ? _startAddress!.trim().truncateStart(maxLength: 50)
        : (startCoords ?? loc.map_select_location_title);
    final startSubtitle = _startLatLng != null
        ? ''
        : loc.map_select_location_tip;

    final destinationTitle = hasDestinationAddress
        ? _destinationAddress!.trim().truncateStart(maxLength: 50)
        : (destinationCoords ?? loc.map_select_location_destination_label);
    final destinationSubtitle = _destinationLatLng != null
        ? ''
        : loc.map_select_location_destination_tip;

    // 构建 PageView 的 children
    // 注意：需要为每个页面动态判断是否为当前页面，避免 ScrollController 被多个可滚动组件共享
    final routePageChildren = List<Widget>.generate(
      _totalRoutePages,
      (index) {
        // 判断是否应该使用 scrollController：
        // 1. 必须是路线 tab 活跃（_activeScrollableTabIndex == 0）
        // 2. 必须是当前活跃的页面（_activeScrollablePageIndex == index）
        final shouldUseScrollController = _activeScrollableTabIndex == 0 && _activeScrollablePageIndex == index;
        
        if (index == 0) {
          // 第一个页面：起始页
          return RouteSelectionPage(
            scrollCtrl: shouldUseScrollController ? widget.scrollCtrl : null,
            onContinue: _enableWizard,
            departureTitle: startTitle,
            departureSubtitle: startSubtitle,
            destinationTitle: destinationTitle,
            destinationSubtitle: destinationSubtitle,
            onEditDeparture: _onEditDeparture,
            onEditDestination: _onEditDestination,
            onSearchDeparture: _onSearchStartLocation,
            onSearchDestination: _onSearchDestination,
            departurePosition: _startLatLng,
            departureAddressFuture: _startAddressFuture,
            departureNearbyFuture: _startNearbyFuture,
            destinationPosition: _destinationLatLng,
            destinationAddressFuture: _destinationAddressFuture,
            destinationNearbyFuture: _destinationNearbyFuture,
          );
        } else if (index == 1) {
          // 第二个页面：basic 页
          return _buildSectionPage(TripSection.basic, isCurrentPage: shouldUseScrollController);
        } else {
          // 其他 section（只有在 _canSwipe 为 true 时才存在）
          final sectionIndex = index - 1; // 减去起始页和 basic 页
          final section = _routeSectionsOrder[sectionIndex];
          return _buildSectionPage(section, isCurrentPage: shouldUseScrollController);
        }
      },
    );

    // 判断是否可以滑动（basic 页未填写完整时禁止滑动）
    final canScroll = !(_isBasicPage && !_basicValid);

    return Material(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // ToggleTabBar 已移到 events_map_page.dart 中，这里不再显示
          Expanded(
            child: _canSwipe
                ? TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(), // 禁止左右滑动，只能点击切换
                    children: [
                      // 路线 tab：使用 PageView 显示起始页和其他 section
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (n) {
                          n.disallowIndicator();
                          return true;
                        },
                        child: PageView(
                          controller: _routePageCtrl,
                          physics: !canScroll
                              ? const NeverScrollableScrollPhysics()
                              : const PageScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentRoutePage = index;
                              // 只有在路线 tab 活跃时，才更新活跃页面索引
                              if (_activeScrollableTabIndex == 0) {
                                _activeScrollablePageIndex = index;
                              }
                            });
                          },
                          children: routePageChildren,
                        ),
                      ),
                      // 途径点 tab：显示 RoadTripRouteSection
                      // 只在当前 tab 活跃时使用 scrollController，避免 ScrollController 被多个可滚动组件共享
                      SingleChildScrollView(
                        controller: _activeScrollableTabIndex == 1 ? widget.scrollCtrl : null,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                        child: RoadTripRouteSection(
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
                        ),
                      ),
                    ],
                  )
                : // 初始状态：只显示起始页和 basic 页的 PageView
                  NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (n) {
                        n.disallowIndicator();
                        return true;
                      },
                      child: PageView(
                        controller: _routePageCtrl,
                        physics: !canScroll
                            ? const NeverScrollableScrollPhysics()
                            : const PageScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() => _currentRoutePage = index);
                        },
                        children: routePageChildren,
                      ),
                    ),
          ),
          // 底部按钮
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 页面指示器（在点击起始页继续后显示，显示起始页和basic页的指示点）
                if (_hasClickedStartContinue && !_canSwipe && _tabController.index == 0)
                  Center(
                    child: ClickablePageIndicator(
                      controller: _routePageCtrl,
                      currentPage: _currentRoutePage,
                      totalPages: 2, // 只有起始页和basic页
                      onPageTap: (index) {
                        if (!_routePageCtrl.hasClients) return;
                        _routePageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                // 页面指示器（显示ToggleTabBar后显示所有页面的指示点）
                if (_canSwipe && _tabController.index == 0)
                  Center(
                    child: ClickablePageIndicator(
                      controller: _routePageCtrl,
                      currentPage: _currentRoutePage,
                      totalPages: _totalRoutePages,
                      onPageTap: (index) {
                        if (!_routePageCtrl.hasClients) return;
                        _routePageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                if ((_hasClickedStartContinue && !_canSwipe) || (_canSwipe && _tabController.index == 0))
                  SizedBox(height: 8.h),
                // 按钮区域
                if (_canSwipe)
                  // 显示 ToggleTabBar 后：只有创建按钮
                  FilledButton(
                    onPressed: (_startValid && _basicValid && !_isCreating)
                        ? _onCreatePressed
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                    ),
                    child: _isCreating
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(loc.road_trip_create_button),
                  )
                else if (_hasClickedStartContinue)
                  // 点击起始页继续后：在basic页显示创建和继续两个按钮
                  _isBasicPage
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: (_startValid && _basicValid && !_isCreating)
                                    ? _onCreatePressed
                                    : null,
                                child: _isCreating
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(loc.road_trip_create_button),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: FilledButton(
                                onPressed: _basicValid ? _continueFromBasic : null,
                                child: Text(loc.road_trip_continue_button),
                              ),
                            ),
                          ],
                        )
                      : // 在起始页：只显示继续按钮（跳转到basic页）
                        FilledButton(
                            onPressed: _startValid ? _enableWizard : null,
                            style: FilledButton.styleFrom(
                              minimumSize: Size(double.infinity, 44.h),
                            ),
                            child: Text(loc.road_trip_continue_button),
                          )
                else
                  // 初始状态：只在起始页显示继续按钮
                  _isStartPage
                      ? FilledButton(
                          onPressed: _startValid ? _enableWizard : null,
                          style: FilledButton.styleFrom(
                            minimumSize: Size(double.infinity, 44.h),
                          ),
                          child: Text(loc.road_trip_continue_button),
                        )
                      : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
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
          24.w,
          16.h,
          24.w,
          24.h + viewPadding + viewInsets,
        ),
        children: [
          const SheetHandle(),
          SizedBox(height: 12.h),
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
                    SizedBox(height: 8.h),
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
          SizedBox(height: 20.h),
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
                              : address.truncateStart(maxLength: 30);
                          return LocationSheetRow(
                            icon: icon,
                            child: Text(display),
                          );
                        },
                      ),
                    SizedBox(height: 16.h),
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
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: Text(loc.action_cancel),
                ),
              ),
              SizedBox(width: 12.w),
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
