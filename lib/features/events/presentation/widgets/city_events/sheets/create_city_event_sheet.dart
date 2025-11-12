import 'dart:async';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_provider.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:crew_app/shared/widgets/sheets/completion_sheet/completion_sheet.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_basic_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_gallery_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_host_disclaimer_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_story_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_team_section.dart';
import 'package:crew_app/features/events/presentation/widgets/common/screens/location_search_screen.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';
import 'package:crew_app/shared/widgets/indicators/page_indicator.dart';
import 'package:crew_app/features/events/presentation/widgets/common/factories/location_selection_page_factory.dart';
import 'package:crew_app/features/events/presentation/widgets/common/config/event_creation_config.dart';
import 'package:crew_app/features/events/presentation/widgets/city_events/data/city_event_editor_models.dart';
import 'package:crew_app/features/events/presentation/widgets/mixins/event_form_mixin.dart';
import 'package:crew_app/features/events/state/events_api_service.dart';
import 'package:crew_app/shared/utils/event_form_validation_utils.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

// 定义 Section 锚点
enum CityEventSection { meetingPoint, basic, team, gallery, story, disclaimer }

class CreateCityEventSheet extends ConsumerStatefulWidget {
  const CreateCityEventSheet({
    super.key,
    required this.scrollController,
    this.embeddedMode = true,
    this.meetingPointPositionListenable,
    this.onCancel,
  });

  final ScrollController scrollController;
  final bool embeddedMode;
  final ValueListenable<LatLng?>? meetingPointPositionListenable;
  final VoidCallback? onCancel;

  @override
  ConsumerState<CreateCityEventSheet> createState() => _CreateCityEventSheetState();
}

class _CreateCityEventSheetState extends ConsumerState<CreateCityEventSheet>
    with TickerProviderStateMixin, EventFormMixin {
  final PageController _pageCtrl = PageController();
  bool _canSwipe = false; // 是否显示其他 section（点击 meetingPoint 的继续后为 true）
  int _currentPage = 0; // 当前页面

  CityEventEditorState _editorState = const CityEventEditorState();

  // ==== 基本信息 ====
  final _titleCtrl = TextEditingController();

  // ==== 集合点 ====
  LatLng? _meetingPointLatLng;
  String? _meetingPointAddress;
  Future<String?>? _meetingPointAddressFuture;
  Future<List<NearbyPlace>>? _meetingPointNearbyFuture;

  // ==== 团队/费用 ====
  int _maxMembers = 4;
  double? _price;
  EventPricingType _pricingType = EventPricingType.free;

  // ==== 偏好 ====
  final _tagInputCtrl = TextEditingController();
  final List<String> _tags = [];

  // ==== 图集 ====
  // ImagePicker 已由 Mixin 提供

  // ==== 文案 ====
  final _storyCtrl = TextEditingController();
  final _disclaimerCtrl = TextEditingController();

  // ==== 创建状态 ====
  bool _isCreating = false;

  // ==== 分段顺序 ====
  static const List<CityEventSection> _sectionsOrder = [
    CityEventSection.basic,
    CityEventSection.team,
    CityEventSection.gallery,
    CityEventSection.story,
    CityEventSection.disclaimer,
  ];

  // 初始只有集合点页和 basic 页（2个页面）
  // 点击集合点页的继续后，包含集合点页、basic、team、gallery、story、disclaimer（6个页面）
  int get _totalPages => _canSwipe ? 1 + _sectionsOrder.length : 2;
  bool get _isBasicPage => _currentPage == 1; // 第二个页面是 basic
  bool get _isMeetingPointPage => _currentPage == 0; // 第一个页面是集合点页
  bool get _basicValid =>
      _titleCtrl.text.trim().isNotEmpty && _editorState.dateRange != null;
  bool get _meetingPointValid => _meetingPointLatLng != null;
  bool _hasClickedMeetingPointContinue = false;

  @override
  void initState() {
    super.initState();
    // 初始化活跃状态：默认在第一个页面
    _activeScrollablePageIndex = 0;

    // 从 ValueListenable 读取集合点位置
    if (widget.meetingPointPositionListenable != null) {
      _meetingPointLatLng = widget.meetingPointPositionListenable!.value;
      widget.meetingPointPositionListenable!.addListener(_onMeetingPointPositionChanged);
      _updateMeetingPointLocation(_meetingPointLatLng);
    }

    _titleCtrl.addListener(() => setState(() {})); // 标题变化触发校验
  }

  void _onMeetingPointPositionChanged() {
    if (!mounted) return;
    final newPosition = widget.meetingPointPositionListenable?.value;
    if (newPosition != _meetingPointLatLng) {
      _updateMeetingPointLocation(newPosition);
    }
  }

  void _updateMeetingPointLocation(LatLng? position) {
    setState(() {
      _meetingPointLatLng = position;
      if (position != null) {
        _meetingPointAddressFuture = _loadAddress(position);
        _meetingPointNearbyFuture = _loadNearbyPlaces(position);
      } else {
        _meetingPointAddressFuture = null;
        _meetingPointNearbyFuture = null;
        _meetingPointAddress = null;
      }
    });
  }

  int? _activeScrollablePageIndex;

  @override
  void dispose() {
    widget.meetingPointPositionListenable?.removeListener(_onMeetingPointPositionChanged);
    _pageCtrl.dispose();
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
    if (!mounted) return;

    // 设置创建状态
    setState(() {
      _isCreating = true;
    });

    try {
      final title = _titleCtrl.text.trim();

      // 使用验证工具类进行验证
      final validationErrors = EventFormValidationUtils.validateCityEventForm(
        title: title,
        dateRange: _editorState.dateRange,
        meetingPointLatLng: _meetingPointLatLng,
        pricingType: _pricingType,
        price: _price,
      );

      if (validationErrors.isNotEmpty) {
        showSnackBar(validationErrors.first);
        setState(() {
          _isCreating = false;
        });
        return;
      }

      // 价格已经在验证工具类中验证，这里直接使用
      final price = _pricingType == EventPricingType.paid ? _price : null;

      final draft = CityEventDraft(
        title: title,
        dateRange: _editorState.dateRange!,
        meetingPoint: _meetingPointAddress ??
            '${_meetingPointLatLng!.latitude.toStringAsFixed(6)}, ${_meetingPointLatLng!.longitude.toStringAsFixed(6)}',
        maxMembers: _maxMembers,
        isFree: _pricingType == EventPricingType.free,
        pricePerPerson: price,
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
      await ref.read(eventsApiServiceProvider).createCityEvent(draft);

      if (!mounted) return;

      // 设置成功状态并显示完成页 sheet
      setState(() {
        _isCreating = false;
      });

      // 清理所有地图选择状态并关闭 sheet
      cleanupAfterCreation();

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
      });

      // 清理所有地图选择状态并关闭 sheet
      cleanupAfterCreation();

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

  void _onSubmitTag() {
    final value = _tagInputCtrl.text.trim();
    if (value.isEmpty) return;
    final updatedTags = addTag(value, _tags);
    if (updatedTags.length > _tags.length) {
      setState(() {
        _tags.clear();
        _tags.addAll(updatedTags);
      });
      _tagInputCtrl.clear();
    }
  }

  void _onRemoveTag(String t) {
    final updatedTags = removeTag(t, _tags);
    setState(() {
      _tags.clear();
      _tags.addAll(updatedTags);
    });
  }

  Future<void> _onPickImages() async {
    final newItems = await pickImages();
    if (newItems.isEmpty) return;
    setState(() {
      _editorState = _editorState.copyWith(
        galleryItems: [..._editorState.galleryItems, ...newItems],
      );
    });
  }

  void _onRemoveImage(int i) {
    final updated = removeImage(i, _editorState.galleryItems);
    setState(() {
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  void _onSetCover(int i) {
    final updated = setImageAsCover(i, _editorState.galleryItems);
    setState(() {
      _editorState = _editorState.copyWith(galleryItems: updated);
    });
  }

  Future<String?> _loadAddress(LatLng latLng) {
    final future = loadFormattedAddress(latLng);
    future.then((value) {
      if (!mounted) return;
      setState(() => _meetingPointAddress = value);
    });
    return future;
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng latLng) {
    return loadNearbyPlaces(latLng);
  }

  Future<void> _restartSelectionFlow() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    // overlay 模式下，所有操作都在同一个 overlay 内完成
    if (widget.embeddedMode) {
      // 重新开始集合点选择
      selectionController.setSelectingDestination(false);
      selectionController.setSelectedLatLng(_meetingPointLatLng);
      if (_meetingPointLatLng != null) {
        unawaited(mapController.moveCamera(_meetingPointLatLng!, zoom: 12));
      }

      // 确保 overlay 打开
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createCityEvent;
    }
  }

  // 处理集合点卡片点击
  Future<void> _onEditMeetingPoint() async {
    await _restartSelectionFlow();
  }

  // 处理集合点 icon 点击 - 打开地址搜索页面
  Future<void> _onSearchMeetingPoint() async {
    final loc = AppLocalizations.of(context)!;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          title: loc.map_select_meeting_point_title,
          initialQuery: _meetingPointAddress,
          initialLocation: _meetingPointLatLng,
          isEditMode: true, // 编辑模式，直接调用回调
          onLocationSelected: (place) {
            final location = place.location;
            if (location == null) return;

            // 更新集合点位置和地址
            setState(() {
              _meetingPointLatLng = location;
              _meetingPointAddress = place.formattedAddress ?? place.displayName;
              _meetingPointAddressFuture = Future.value(_meetingPointAddress);
              _meetingPointNearbyFuture = _loadNearbyPlaces(location);
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

  // 清空集合点
  void _onClearMeetingPoint() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    
    setState(() {
      _meetingPointLatLng = null;
      _meetingPointAddress = null;
      _meetingPointAddressFuture = null;
      _meetingPointNearbyFuture = null;
    });
    
    // 更新选择状态（会自动清除呼吸效果）
    selectionController.setSelectedLatLng(null);
  }

  void _enableWizard() {
    // 从集合点页点击继续，跳转到 basic 页
    setState(() {
      _hasClickedMeetingPointContinue = true;
    });

    try {
      if (!_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
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
    // 从 basic 页点击继续，显示其他 section，并跳转到下一页
    setState(() {
      _canSwipe = true;
    });
    // 延迟到下一帧，确保 PageView 已经构建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (!_pageCtrl.hasClients) return;
        // 跳转到下一页（team 页，索引 2）
        _pageCtrl.animateToPage(
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
  Widget _buildSectionPage(CityEventSection s, {bool isCurrentPage = false}) {
    Widget content;
    switch (s) {
      case CityEventSection.basic:
        content = EventBasicSection(
          titleController: _titleCtrl,
          dateRange: _editorState.dateRange,
          onPickDateRange: _pickDateRange,
        );
        break;
      case CityEventSection.team:
        content = EventTeamSection(
          maxMembers: _maxMembers,
          onMaxMembersChanged: (value) => setState(() {
            _maxMembers = value;
          }),
          price: _price,
          onPriceChanged: (value) => setState(() {
            _price = value;
          }),
          pricingType: _pricingType,
          onPricingTypeChanged: (v) => setState(() {
            _pricingType = v;
            if (v == EventPricingType.free) {
              _price = null;
            }
          }),
          tagInputController: _tagInputCtrl,
          onSubmitTag: _onSubmitTag,
          tags: _tags,
          onRemoveTag: _onRemoveTag,
        );
        break;
      case CityEventSection.gallery:
        content = EventGallerySection(
          items: _editorState.galleryItems,
          onPickImages: _onPickImages,
          onRemoveImage: _onRemoveImage,
          onSetCover: _onSetCover,
        );
        break;
      case CityEventSection.story:
        content = EventStorySection(descriptionController: _storyCtrl);
        break;
      case CityEventSection.disclaimer:
        content = EventHostDisclaimerSection(disclaimerController: _disclaimerCtrl);
        break;
      case CityEventSection.meetingPoint:
        // meetingPoint section 在单独的页面中
        content = const SizedBox.shrink();
        break;
    }

    // 包装在可滚动容器中，适配 overlay sheet 的高度限制
    return SingleChildScrollView(
      controller: isCurrentPage ? widget.scrollController : null,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    // 计算集合点页展示信息
    final hasMeetingPointAddress =
        _meetingPointAddress != null && _meetingPointAddress!.trim().isNotEmpty;

    final meetingPointCoords = _meetingPointLatLng != null
        ? '${_meetingPointLatLng!.latitude.toStringAsFixed(6)}, ${_meetingPointLatLng!.longitude.toStringAsFixed(6)}'
        : null;

    final meetingPointTitle = hasMeetingPointAddress
        ? _meetingPointAddress!.trim().truncateStart(maxLength: 50)
        : (meetingPointCoords ?? loc.map_select_location_title);
    final meetingPointSubtitle = _meetingPointLatLng != null
        ? ''
        : loc.map_select_location_tip;

    // 构建 PageView 的 children
    final pageChildren = List<Widget>.generate(
      _totalPages,
      (index) {
        final shouldUseScrollController = _activeScrollablePageIndex == index;

        if (index == 0) {
          // 第一个页面：集合点页
          return LocationSelectionPageFactory.build(
            mode: LocationSelectionMode.singlePoint,
            data: LocationSelectionPageData(
              titleKey: 'meeting_point',
              subtitleKey: 'meeting_point_subtitle',
              firstLocation: LocationData(
                title: meetingPointTitle,
                subtitle: meetingPointSubtitle,
                onTap: _onEditMeetingPoint,
                onSearch: _onSearchMeetingPoint,
                position: _meetingPointLatLng,
                addressFuture: _meetingPointAddressFuture,
                nearbyFuture: _meetingPointNearbyFuture,
                onClear: _onClearMeetingPoint,
              ),
            ),
            scrollCtrl: shouldUseScrollController ? widget.scrollController : null,
            onContinue: _enableWizard,
          );
        } else if (index == 1) {
          // 第二个页面：basic 页
          return _buildSectionPage(CityEventSection.basic, isCurrentPage: shouldUseScrollController);
        } else {
          // 其他 section（只有在 _canSwipe 为 true 时才存在）
          final sectionIndex = index - 1; // 减去集合点页和 basic 页
          final section = _sectionsOrder[sectionIndex];
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
          Expanded(
            child: _canSwipe
                ? NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (n) {
                      n.disallowIndicator();
                      return true;
                    },
                    child: PageView(
                      controller: _pageCtrl,
                      physics: !canScroll
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                          _activeScrollablePageIndex = index;
                        });
                      },
                      children: pageChildren,
                    ),
                  )
                : NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (n) {
                      n.disallowIndicator();
                      return true;
                    },
                    child: PageView(
                      controller: _pageCtrl,
                      physics: !canScroll
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: pageChildren,
                    ),
                  ),
          ),
          // 底部按钮
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 页面指示器
                if (_hasClickedMeetingPointContinue && !_canSwipe)
                  Center(
                    child: PageIndicator(
                      controller: _pageCtrl,
                      currentPage: _currentPage,
                      totalPages: 2,
                      onPageTap: (index) {
                        if (!_pageCtrl.hasClients) return;
                        _pageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                if (_canSwipe)
                  Center(
                    child: PageIndicator(
                      controller: _pageCtrl,
                      currentPage: _currentPage,
                      totalPages: _totalPages,
                      onPageTap: (index) {
                        if (!_pageCtrl.hasClients) return;
                        _pageCtrl.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                if ((_hasClickedMeetingPointContinue && !_canSwipe) || _canSwipe)
                  SizedBox(height: 8.h),
                // 按钮区域
                if (_canSwipe)
                  // 显示其他 section 后：只有创建按钮
                  FilledButton(
                    onPressed: (_meetingPointValid && _basicValid && !_isCreating)
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
                else if (_hasClickedMeetingPointContinue)
                  // 点击集合点页继续后：在basic页显示创建和继续两个按钮
                  _isBasicPage
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: (_meetingPointValid && _basicValid && !_isCreating)
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
                      : // 在集合点页：只显示继续按钮（跳转到basic页）
                        FilledButton(
                            onPressed: _meetingPointValid ? _enableWizard : null,
                            style: FilledButton.styleFrom(
                              minimumSize: Size(double.infinity, 44.h),
                            ),
                            child: Text(loc.road_trip_continue_button),
                          )
                else
                  // 初始状态：只在集合点页显示继续按钮
                  _isMeetingPointPage
                      ? FilledButton(
                          onPressed: _meetingPointValid ? _enableWizard : null,
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
}

