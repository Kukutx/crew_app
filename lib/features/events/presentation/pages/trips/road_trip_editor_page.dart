import 'dart:io';

import 'package:crew_app/features/events/presentation/pages/trips/widgets/road_trip_gallery_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

export 'data/road_trip_editor_models.dart';

import 'data/road_trip_editor_models.dart';
import 'widgets/road_trip_basic_section.dart';
import 'widgets/road_trip_preferences_section.dart';
import 'widgets/road_trip_route_section.dart';
import 'widgets/road_trip_story_section.dart';
import 'widgets/road_trip_team_section.dart';
import 'widgets/road_trip_host_disclaimer_section.dart';

/// API provider stub ---------------------------------------------------------
final eventsApiProvider = Provider<EventsApi>((ref) => EventsApi());

class EventsApi {
  Future<String> createRoadTrip(RoadTripDraft input) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return 'event_123';
  }
}

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

class _RoadTripEditorPageState extends ConsumerState<RoadTripEditorPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _endLocationCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '4');
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _hostDisclaimerCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  RoadTripEditorState _state = const RoadTripEditorState();

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null) {
      _titleCtrl.text = initial.title;
      _startLocationCtrl.text = initial.startLocation;
      _endLocationCtrl.text = initial.endLocation;
      _meetingLocationCtrl.text = initial.meetingPoint;
      _maxParticipantsCtrl.text = initial.maxParticipants.toString();
      if (initial.pricePerPerson != null) {
        _priceCtrl.text = initial.pricePerPerson!.toString();
      }
      _descriptionCtrl.text = initial.description;
      _hostDisclaimerCtrl.text = initial.hostDisclaimer;

      // 解析途经点坐标字符串为 LatLng
      // 注意：waypoints 是扁平列表，不区分去程和返程，这里暂时全部放到去程
      final waypoints = <LatLng>[];
      for (final wpStr in initial.waypoints) {
        final parts = wpStr.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null) {
            waypoints.add(LatLng(lat, lng));
          }
        }
      }
      
      final initialState = RoadTripEditorState(
        dateRange: initial.dateRange,
        routeType: initial.isRoundTrip
            ? RoadTripRouteType.roundTrip
            : RoadTripRouteType.oneWay,
        pricingType: initial.isFree
            ? RoadTripPricingType.free
            : RoadTripPricingType.paid,
        carType: initial.carType,
        // waypoints 在编辑页面中通过 _forwardWps 和 _returnWps 管理
        waypoints: const <String>[],
        tags: List.of(initial.tags),
        galleryItems: [
          ...initial.existingImageUrls.map(RoadTripGalleryItem.network),
          ...initial.galleryImages.map(RoadTripGalleryItem.file),
        ],
      );
      _state = initialState;
      
      // 将解析的途经点加载到去程列表（编辑页面暂时不区分去程和返程）
      _forwardWps.addAll(waypoints);
    }
  }

  @override
  void dispose() {
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
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      final newItems = picked
          .map((x) => RoadTripGalleryItem.file(File(x.path)))
          .toList();
      _state = _state.copyWith(
        galleryItems: [..._state.galleryItems, ...newItems],
      );
    });
  }

  void _setCover(int index) {
    if (index < 0 || index >= _state.galleryItems.length) return;
    setState(() {
      final items = [..._state.galleryItems];
      final item = items.removeAt(index);
      items.insert(0, item);
      _state = _state.copyWith(galleryItems: items);
    });
  }

  void _removeGalleryItem(int index) {
    if (index < 0 || index >= _state.galleryItems.length) return;
    setState(() {
      final items = [..._state.galleryItems]..removeAt(index);
      _state = _state.copyWith(galleryItems: items);
    });
  }

  void _addTagFromInput() {
    final value = _tagInputCtrl.text.trim();
    if (value.isEmpty) return;
    if (_state.tags.contains(value)) return;
    setState(() {
      _state = _state.copyWith(tags: [..._state.tags, value]);
    });
    _tagInputCtrl.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_state.dateRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择活动日期范围')));
      return;
    }

    double? price;
    if (_state.pricingType == RoadTripPricingType.paid) {
      price = double.tryParse(_priceCtrl.text.trim());
      if (price == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请输入正确的人均费用')));
        return;
      }
    }

    final draft = RoadTripDraft(
      id: widget.initialValue?.id,
      title: _titleCtrl.text.trim(),
      dateRange: _state.dateRange!,
      startLocation: _startLocationCtrl.text.trim(),
      endLocation: _endLocationCtrl.text.trim(),
      meetingPoint: _meetingLocationCtrl.text.trim(),
      isRoundTrip: _state.routeType == RoadTripRouteType.roundTrip,
      waypoints: [
        ..._forwardWps.map((wp) => '${wp.latitude},${wp.longitude}'),
        ..._returnWps.map((wp) => '${wp.latitude},${wp.longitude}'),
      ],
      maxParticipants: int.parse(_maxParticipantsCtrl.text),
      isFree: _state.pricingType == RoadTripPricingType.free,
      pricePerPerson: price,
      carType: _state.carType,
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

      final id = await ref.read(eventsApiProvider).createRoadTrip(draft);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.isEditing ? '更新' : '创建'}成功：$id')),
      );
      Navigator.pop(context, id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败：$e')));
      }
    }
  }

  final List<LatLng> _forwardWps = []; // 去程途经点
  final List<LatLng> _returnWps = []; // 返程途经点

  // 在编辑页面中，途经点添加功能需要从地图选择
  // 这里暂时提供空实现，实际使用时需要打开地图选择界面
  void _onAddForward() {
    // TODO: 在编辑页面中打开地图选择界面来选择途经点
    // 暂时不做任何操作，因为编辑页面可能不需要地图选择功能
  }
  
  void _onRemoveForward(int i) => setState(() {
    if (i >= 0 && i < _forwardWps.length) _forwardWps.removeAt(i);
  });
  
  void _onReorderForward(int oldIndex, int newIndex) => setState(() {
    final item = _forwardWps.removeAt(oldIndex);
    _forwardWps.insert(newIndex, item);
  });

  void _onAddReturn() {
    // TODO: 在编辑页面中打开地图选择界面来选择途经点
    // 暂时不做任何操作，因为编辑页面可能不需要地图选择功能
  }
  
  void _onRemoveReturn(int i) => setState(() {
    if (i >= 0 && i < _returnWps.length) _returnWps.removeAt(i);
  });
  
  void _onReorderReturn(int oldIndex, int newIndex) => setState(() {
    final item = _returnWps.removeAt(oldIndex);
    _returnWps.insert(newIndex, item);
  });

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
              RoadTripBasicSection(
                titleController: _titleCtrl,
                dateRange: _state.dateRange,
                onPickDateRange: _pickDateRange,
              ),

              RoadTripRouteSection(
                routeType: _state.routeType,
                onRouteTypeChanged: (type) => setState(() {
                  _state = _state.copyWith(routeType: type);
                }),
                forwardWaypoints: _forwardWps,
                onAddForward: _onAddForward,
                onRemoveForward: _onRemoveForward,
                onReorderForward: _onReorderForward,

                returnWaypoints: _returnWps,
                onAddReturn: _onAddReturn,
                onRemoveReturn: _onRemoveReturn,
                onReorderReturn: _onReorderReturn,
              ),
              RoadTripTeamSection(
                maxParticipantsController: _maxParticipantsCtrl,
                priceController: _priceCtrl,
                pricingType: _state.pricingType,
                onPricingTypeChanged: (type) => setState(() {
                  _state = _state.copyWith(pricingType: type);
                  if (type == RoadTripPricingType.free) {
                    _priceCtrl.clear();
                  }
                }),
              ),
              RoadTripPreferencesSection(
                carType: _state.carType,
                onCarTypeChanged: (value) => setState(() {
                  _state = _state.copyWith(
                    carType: value,
                    clearCarType: value == null,
                  );
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
              RoadTripGallerySection(
                items: _state.galleryItems,
                onPickImages: _pickImages,
                onRemoveImage: _removeGalleryItem,
                onSetCover: _setCover,
              ),
              RoadTripStorySection(descriptionController: _descriptionCtrl),
              RoadTripHostDisclaimerSection(
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
