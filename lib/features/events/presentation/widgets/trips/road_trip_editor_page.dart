import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_gallery_section.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

export 'data/road_trip_editor_models.dart';

import 'data/road_trip_editor_models.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_basic_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/trips/trip_route_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_story_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_team_section.dart';
import 'package:crew_app/features/events/presentation/widgets/sections/event_host_disclaimer_section.dart';

// API Service 已移至 events_api_service.dart
import 'package:crew_app/features/events/state/events_api_service.dart';
import 'package:crew_app/shared/utils/event_form_validation_utils.dart';
import 'package:crew_app/features/events/presentation/widgets/mixins/event_form_mixin.dart';
import 'sheets/waypoint_note_sheet.dart';

class RoadTripEditorPage extends ConsumerStatefulWidget {
  const RoadTripEditorPage({
    super.key,
    required this.onClose,
    this.initialValue,
    this.onSubmit,
  });

  final VoidCallback onClose;
  final RoadTripDraft? initialValue;
  final Future<void> Function(RoadTripDraft input)? onSubmit;

  bool get isEditing => initialValue != null;

  @override
  ConsumerState<RoadTripEditorPage> createState() => _RoadTripEditorPageState();
}

class _RoadTripEditorPageState extends ConsumerState<RoadTripEditorPage>
    with EventFormMixin {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _endLocationCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  int _maxMembers = 4;
  double? _price;
  final _descriptionCtrl = TextEditingController();
  final _hostDisclaimerCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  RoadTripEditorState _state = const RoadTripEditorState();
  
  // 去程和返程途经点
  final List<LatLng> _forwardWps = [];
  final List<LatLng> _returnWps = [];
  
  // 途径点备注 Map，key为"lat_lng"格式
  final Map<String, String> _forwardNotes = {};
  final Map<String, String> _returnNotes = {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null) {
      _titleCtrl.text = initial.title;
      _startLocationCtrl.text = initial.startLocation;
      _endLocationCtrl.text = initial.endLocation;
      _meetingLocationCtrl.text = initial.meetingPoint;
      _maxMembers = initial.maxMembers;
      _price = initial.pricePerPerson;
      _descriptionCtrl.text = initial.description;
      _hostDisclaimerCtrl.text = initial.hostDisclaimer;

      // 解析去程途经点
      final forwardWaypoints = <LatLng>[];
      for (final segment in initial.forwardSegments) {
        final parts = segment.coordinate.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          // 坐标范围验证
          if (lat != null &&
              lng != null &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180) {
            forwardWaypoints.add(LatLng(lat, lng));
          }
        }
      }
      
      // 解析返程途经点（仅往返行程）
      final returnWaypoints = <LatLng>[];
      for (final segment in initial.returnSegments) {
        final parts = segment.coordinate.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          // 坐标范围验证
          if (lat != null &&
              lng != null &&
              lat >= -90 &&
              lat <= 90 &&
              lng >= -180 &&
              lng <= 180) {
            returnWaypoints.add(LatLng(lat, lng));
          }
        }
      }
      
      final initialState = RoadTripEditorState(
        dateRange: initial.dateRange,
        routeType: initial.isRoundTrip
            ? EventRouteType.roundTrip
            : EventRouteType.oneWay,
        pricingType: initial.isFree
            ? EventPricingType.free
            : EventPricingType.paid,
        tags: List.of(initial.tags),
        galleryItems: [
          ...initial.existingImageUrls.map(EventGalleryItem.network),
          ...initial.galleryImages.map(EventGalleryItem.file),
        ],
      );
      _state = initialState;
      
      // 加载去程和返程途经点
      _forwardWps.addAll(forwardWaypoints);
      _returnWps.addAll(returnWaypoints);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _startLocationCtrl.dispose();
    _endLocationCtrl.dispose();
    _meetingLocationCtrl.dispose();
    _descriptionCtrl.dispose();
    _hostDisclaimerCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange:
          _state.dateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) {
      setState(() {
        _state = _state.copyWith(dateRange: picked);
      });
    }
  }

  Future<void> _pickImages() async {
    final newItems = await pickImages();
    if (newItems.isEmpty) return;
    setState(() {
      _state = _state.copyWith(
        galleryItems: [..._state.galleryItems, ...newItems],
      );
    });
  }

  void _setCover(int index) {
    setState(() {
      final updatedItems = setImageAsCover(index, _state.galleryItems);
      _state = _state.copyWith(galleryItems: updatedItems);
    });
  }

  void _removeGalleryItem(int index) {
    setState(() {
      final updatedItems = removeImage(index, _state.galleryItems);
      _state = _state.copyWith(galleryItems: updatedItems);
    });
  }

  void _addTagFromInput() {
    final value = _tagInputCtrl.text.trim();
    final updatedTags = addTag(value, _state.tags);
    if (updatedTags.length > _state.tags.length) {
      setState(() {
        _state = _state.copyWith(tags: updatedTags);
      });
      _tagInputCtrl.clear();
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    
    // 使用验证工具类进行验证（注意：这里没有起点和终点验证，因为是编辑模式）
    final validationErrors = EventFormValidationUtils.validateCommonForm(
      title: title,
      dateRange: _state.dateRange,
      pricingType: _state.pricingType,
      price: _price,
    );

    // 坐标验证
    final allWaypoints = [..._forwardWps, ..._returnWps];
    final waypointError = EventFormValidationUtils.validateWaypoints(allWaypoints);
    if (waypointError != null) {
      validationErrors.add(waypointError);
    }

    if (validationErrors.isNotEmpty) {
      showErrorMessage(validationErrors.first);
      return;
    }

    // 价格已经在验证工具类中验证，这里直接使用
    final price = _state.pricingType == EventPricingType.paid ? _price : null;

    final segments = <EventWaypointSegment>[
      ..._forwardWps.asMap().entries.map(
        (entry) => EventWaypointSegment(
          coordinate: '${entry.value.latitude},${entry.value.longitude}',
          direction: EventWaypointDirection.forward,
          order: entry.key,
        ),
      ),
      if (_state.routeType == EventRouteType.roundTrip)
        ..._returnWps.asMap().entries.map(
          (entry) => EventWaypointSegment(
            coordinate: '${entry.value.latitude},${entry.value.longitude}',
            direction: EventWaypointDirection.returnTrip,
            order: entry.key,
          ),
        ),
    ];

    final draft = RoadTripDraft(
      id: widget.initialValue?.id,
      title: title,
      dateRange: _state.dateRange!,
      startLocation: _startLocationCtrl.text.trim(),
      endLocation: _endLocationCtrl.text.trim(),
      meetingPoint: _meetingLocationCtrl.text.trim(),
      isRoundTrip: _state.routeType == EventRouteType.roundTrip,
      segments: segments,
                maxMembers: _maxMembers,
      isFree: _state.pricingType == EventPricingType.free,
      pricePerPerson: price,
      tags: List.of(_state.tags),
      description: _descriptionCtrl.text.trim(),
      hostDisclaimer: _hostDisclaimerCtrl.text.trim(),
      galleryImages: _state.galleryItems
          .where((item) => item.file != null)
          .map((item) => item.file!)
          .toList(),
      existingImageUrls: _state.galleryItems
          .where((item) => item.url != null)
          .map((item) => item.url!)
          .toList(),
    );

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(draft);
        if (!mounted) return;
        Navigator.pop(context, draft);
        return;
      }

      final id = await ref.read(eventsApiServiceProvider).createRoadTrip(draft);
      if (!mounted) return;
      final actionText = widget.isEditing ? loc.action_update : loc.action_create;
      showSuccessMessage(loc.road_trip_create_success(actionText, id));
      Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        showErrorMessage(loc.road_trip_create_failed(e.toString()));
      }
    }
  }

  // 添加前往途径点（从 LocationSearchScreen 返回）
  void _onAddForward(PlaceDetails place) {
    final location = place.location;
    if (location == null) return;
    
    setState(() {
      _forwardWps.add(location);
    });
  }
  
  void _onRemoveForward(int i) => setState(() {
    if (i >= 0 && i < _forwardWps.length) _forwardWps.removeAt(i);
  });
  
  void _onReorderForward(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _forwardWps.length) return;
    if (newIndex < 0 || newIndex >= _forwardWps.length) return;
    
    setState(() {
      final item = _forwardWps.removeAt(oldIndex);
      _forwardWps.insert(newIndex, item);
    });
  }

  // 添加返回途径点（从 LocationSearchScreen 返回）
  void _onAddReturn(PlaceDetails place) {
    final location = place.location;
    if (location == null) return;
    
    setState(() {
      _returnWps.add(location);
    });
  }
  
  void _onRemoveReturn(int i) => setState(() {
    if (i >= 0 && i < _returnWps.length) _returnWps.removeAt(i);
  });
  
  void _onReorderReturn(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _returnWps.length) return;
    if (newIndex < 0 || newIndex >= _returnWps.length) return;
    
    setState(() {
      final item = _returnWps.removeAt(oldIndex);
      _returnWps.insert(newIndex, item);
    });
  }

  // 编辑去程途径点备注
  Future<void> _onEditForwardNote(int index) async {
    if (index < 0 || index >= _forwardWps.length) return;
    
    final waypoint = _forwardWps[index];
    final key = '${waypoint.latitude}_${waypoint.longitude}';
    final currentNote = _forwardNotes[key];
    
    final result = await showWaypointNoteSheet(
      context: context,
      waypoint: waypoint,
      index: index,
      currentNote: currentNote,
      title: '去程',
    );
    
    if (result == null) {
      // 删除备注
      setState(() {
        _forwardNotes.remove(key);
      });
    } else {
      // 保存备注
      setState(() {
        _forwardNotes[key] = result;
      });
    }
  }

  // 编辑返程途径点备注
  Future<void> _onEditReturnNote(int index) async {
    if (index < 0 || index >= _returnWps.length) return;
    
    final waypoint = _returnWps[index];
    final key = '${waypoint.latitude}_${waypoint.longitude}';
    final currentNote = _returnNotes[key];
    
    final result = await showWaypointNoteSheet(
      context: context,
      waypoint: waypoint,
      index: index,
      currentNote: currentNote,
      title: '返程',
    );
    
    if (result == null) {
      // 删除备注
      setState(() {
        _returnNotes.remove(key);
      });
    } else {
      // 保存备注
      setState(() {
        _returnNotes[key] = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑自驾游活动' : '创建自驾游活动'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: widget.onClose,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            children: [
              EventBasicSection(
                titleController: _titleCtrl,
                dateRange: _state.dateRange,
                onPickDateRange: _pickDateRange,
              ),

              TripRouteSection(
                routeType: _state.routeType,
                onRouteTypeChanged: (type) => setState(() {
                  _state = _state.copyWith(routeType: type);
                }),
                forwardWaypoints: _forwardWps,
                onAddForward: _onAddForward,
                onRemoveForward: _onRemoveForward,
                onReorderForward: _onReorderForward,
                onEditForwardNote: _onEditForwardNote,
                forwardNotes: _forwardNotes,

                returnWaypoints: _returnWps,
                onAddReturn: _onAddReturn,
                onRemoveReturn: _onRemoveReturn,
                onReorderReturn: _onReorderReturn,
                onEditReturnNote: _onEditReturnNote,
                returnNotes: _returnNotes,
              ),
              EventTeamSection(
                maxMembers: _maxMembers,
                onMaxMembersChanged: (value) => setState(() {
                  _maxMembers = value;
                }),
                price: _price,
                onPriceChanged: (value) => setState(() {
                  _price = value;
                }),
                pricingType: _state.pricingType,
                onPricingTypeChanged: (type) => setState(() {
                  _state = _state.copyWith(pricingType: type);
                  if (type == EventPricingType.free) {
                    _price = null;
                  }
                }),
                tagInputController: _tagInputCtrl,
                onSubmitTag: _addTagFromInput,
                tags: _state.tags,
                onRemoveTag: (tag) => setState(() {
                  _state = _state.copyWith(
                    tags: _state.tags.where((t) => t != tag).toList(),
                  );
                }),
              ),
              EventGallerySection(
                items: _state.galleryItems,
                onPickImages: _pickImages,
                onRemoveImage: _removeGalleryItem,
                onSetCover: _setCover,
              ),
              EventStorySection(descriptionController: _descriptionCtrl),
              EventHostDisclaimerSection(
                disclaimerController: _hostDisclaimerCtrl,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(widget.isEditing ? '保存修改' : '创建活动'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
