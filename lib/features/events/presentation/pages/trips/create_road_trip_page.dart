import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/network/places/places_service.dart';
import '../../../data/event.dart';
import '../../../state/events_providers.dart';
import '../../../state/places_providers.dart';

/// --- Data models ----------------------------------------------------------
class CreateRoadTripInput {
  const CreateRoadTripInput({
    required this.title,
    required this.startCity,
    required this.endCity,
    this.dateRange,
    this.waypoints = const <String>[],
    this.maxParticipants = 4,
    this.pricePerPerson,
    this.carType,
    this.tags = const <String>[],
    this.meetingPoint,
    this.description,
    this.coverImage,
  });

  final String title;
  final DateTimeRange? dateRange;
  final String startCity;
  final String endCity;
  final List<String> waypoints;
  final int maxParticipants;
  final double? pricePerPerson;
  final String? carType;
  final List<String> tags;
  final MeetingPoint? meetingPoint;
  final String? description;
  final XFile? coverImage;
}

class MeetingPoint {
  const MeetingPoint({
    required this.displayName,
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String displayName;
  final String address;
  final double lat;
  final double lng;
}

/// --- API provider (stub) --------------------------------------------------
final eventsApiProvider = Provider<EventsApi>((ref) => EventsApi());

class EventsApi {
  Future<String> createRoadTrip(CreateRoadTripInput input) async {
    // TODO: call API to create a road trip event
    await Future.delayed(const Duration(milliseconds: 600));
    return 'event_123';
  }

  Future<void> updateRoadTrip(String eventId, CreateRoadTripInput input) async {
    // TODO: call API to update an existing road trip event
    await Future.delayed(const Duration(milliseconds: 600));
  }
}

/// --- Page -----------------------------------------------------------------
class EditOrCreateRoadTripPage extends ConsumerStatefulWidget {
  const EditOrCreateRoadTripPage({this.eventId, super.key});

  final String? eventId;

  @override
  ConsumerState<EditOrCreateRoadTripPage> createState() =>
      _EditOrCreateRoadTripPageState();
}

class _EditOrCreateRoadTripPageState
    extends ConsumerState<EditOrCreateRoadTripPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _startCityCtrl;
  late final TextEditingController _endCityCtrl;
  late final TextEditingController _maxParticipantsCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _carTypeCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _tagInputCtrl;

  DateTimeRange? _dateRange;
  MeetingPoint? _meetingPoint;
  final List<String> _waypoints = <String>[];
  final List<String> _tags = <String>[];
  XFile? _coverImage;
  String? _existingCoverUrl;

  bool _isSubmitting = false;
  bool _canSubmit = false;
  String? _routeError;
  String? _startEndError;
  bool _initializedFromEvent = false;

  ProviderSubscription<AsyncValue<List<Event>>>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _startCityCtrl = TextEditingController();
    _endCityCtrl = TextEditingController();
    _maxParticipantsCtrl = TextEditingController(text: '4');
    _priceCtrl = TextEditingController();
    _carTypeCtrl = TextEditingController();
    _descriptionCtrl = TextEditingController();
    _tagInputCtrl = TextEditingController();

    for (final controller in <TextEditingController>[
      _titleCtrl,
      _startCityCtrl,
      _endCityCtrl,
      _maxParticipantsCtrl,
      _priceCtrl,
      _carTypeCtrl,
      _descriptionCtrl,
      _tagInputCtrl,
    ]) {
      controller.addListener(_updateFormState);
    }

    if (widget.eventId != null) {
      _eventsSubscription = ref.listen<AsyncValue<List<Event>>>(
        eventsProvider,
        (previous, next) {
          next.whenData((events) {
            if (_initializedFromEvent) {
              return;
            }
            final event =
                events.firstWhereOrNull((item) => item.id == widget.eventId);
            if (event != null) {
              _populateFromEvent(event);
            }
          });
        },
      );
      final existing = ref.read(eventsProvider);
      existing.whenData((events) {
        if (_initializedFromEvent) {
          return;
        }
        final event = events.firstWhereOrNull((item) => item.id == widget.eventId);
        if (event != null) {
          _populateFromEvent(event);
        }
      });
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.close();
    _titleCtrl.dispose();
    _startCityCtrl.dispose();
    _endCityCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _priceCtrl.dispose();
    _carTypeCtrl.dispose();
    _descriptionCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.eventId != null;

  Future<void> _populateFromEvent(Event event) async {
    _initializedFromEvent = true;
    _titleCtrl.text = event.title;
    _descriptionCtrl.text = event.description;
    _maxParticipantsCtrl.text =
        (event.maxParticipants ?? int.tryParse(_maxParticipantsCtrl.text) ?? 4)
            .toString();
    if (event.price != null) {
      _priceCtrl.text = event.price!.toStringAsFixed(2);
    }
    _tags
      ..clear()
      ..addAll(event.tags);
    _waypoints
      ..clear()
      ..addAll(event.waypoints);
    if (event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty) {
      _existingCoverUrl = event.coverImageUrl;
    }
    if (event.startTime != null && event.endTime != null) {
      _dateRange = DateTimeRange(
        start: event.startTime!,
        end: event.endTime!,
      );
    }
    final inferredCities = _inferCitiesFromEvent(event);
    if (inferredCities.$1 != null) {
      _startCityCtrl.text = inferredCities.$1!;
    }
    if (inferredCities.$2 != null) {
      _endCityCtrl.text = inferredCities.$2!;
    }
    if (event.latitude != 0 || event.longitude != 0) {
      final displayName = event.location.isNotEmpty
          ? event.location
          : (event.address ?? '');
      if (displayName.isNotEmpty) {
        _meetingPoint = MeetingPoint(
          displayName: displayName,
          address: event.address ?? displayName,
          lat: event.latitude,
          lng: event.longitude,
        );
      }
    }
    _updateRouteWarnings();
    _updateFormState();
    if (mounted) {
      setState(() {});
    }
  }

  (String?, String?) _inferCitiesFromEvent(Event event) {
    final location = event.location.trim();
    final address = event.address?.trim() ?? '';
    final waypoints = event.waypoints;
    String? startCity;
    String? endCity;

    if (location.contains('→')) {
      final parts = location.split('→');
      if (parts.length >= 2) {
        startCity = parts.first.trim();
        endCity = parts.last.trim();
      }
    }

    if (startCity == null || startCity.isEmpty) {
      startCity = _extractPrimaryCity(address.isNotEmpty ? address : location);
    }
    if (endCity == null || endCity.isEmpty) {
      endCity = waypoints.isNotEmpty ? waypoints.last : startCity;
    }
    if (endCity == null || endCity!.isEmpty) {
      endCity = _extractPrimaryCity(location);
    }

    return (startCity, endCity);
  }

  String? _extractPrimaryCity(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final separators = [',', '·', '•', '-', '–', '|'];
    for (final separator in separators) {
      if (trimmed.contains(separator)) {
        return trimmed.split(separator).first.trim();
      }
    }
    return trimmed;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialRange = _dateRange ??
        DateTimeRange(start: now, end: now.add(const Duration(days: 1)));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) {
      return;
    }
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _updateFormState();
    }
  }

  Future<void> _selectCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _coverImage = picked;
        _existingCoverUrl = null;
      });
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImage = null;
      _existingCoverUrl = null;
    });
  }

  Future<void> _addWaypoint() async {
    final city = await _openCityPickerSheet(
      title: '添加途经城市',
      initialQuery: '',
    );
    if (city == null || city.trim().isEmpty) {
      return;
    }
    setState(() {
      _waypoints.add(city.trim());
    });
    _updateFormState();
  }

  Future<void> _editWaypoint(int index) async {
    final current = _waypoints[index];
    final updated = await _openWaypointEditSheet(current);
    if (updated == null) {
      return;
    }
    setState(() {
      if (updated.isEmpty) {
        _waypoints.removeAt(index);
      } else {
        _waypoints[index] = updated;
      }
    });
    _updateFormState();
  }

  Future<String?> _openWaypointEditSheet(String value) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WaypointEditSheet(initialValue: value),
    );
    return result;
  }

  Future<void> _showWaypointsFullList() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WaypointListSheet(
        waypoints: _waypoints,
        onDelete: (index) {
          setState(() {
            _waypoints.removeAt(index);
          });
          _updateFormState();
        },
        onEdit: (index) => _editWaypoint(index),
      ),
    );
  }

  Future<void> _selectMeetingPoint() async {
    final selected = await Navigator.of(context).push<MeetingPoint>(
      MaterialPageRoute(
        builder: (_) => MeetingPointPickerPage(initialPoint: _meetingPoint),
      ),
    );
    if (selected != null) {
      setState(() {
        _meetingPoint = selected;
      });
      _updateFormState();
    }
  }

  void _clearMeetingPoint() {
    setState(() {
      _meetingPoint = null;
    });
    _updateFormState();
  }

  void _addTagFromInput() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isEmpty) {
      return;
    }
    if (_tags.contains(tag)) {
      _tagInputCtrl.clear();
      return;
    }
    setState(() {
      _tags.add(tag);
    });
    _tagInputCtrl.clear();
    _updateFormState();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _updateFormState();
  }

  Future<String?> _openCityPickerSheet({
    required String title,
    required String initialQuery,
  }) async {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CitySearchSheet(
        title: title,
        initialQuery: initialQuery,
      ),
    );
  }

  void _updateRouteWarnings() {
    final start = _startCityCtrl.text.trim();
    final end = _endCityCtrl.text.trim();
    String? startEndError;
    if (start.isNotEmpty && end.isNotEmpty &&
        start.toLowerCase() == end.toLowerCase()) {
      startEndError = '起点和终点不能相同';
    }
    if (startEndError != _startEndError) {
      _startEndError = startEndError;
    }

    String? routeError;
    final invalidWaypoint = _waypoints.firstWhereOrNull((item) {
      final trimmed = item.trim().toLowerCase();
      return trimmed == start.toLowerCase() || trimmed == end.toLowerCase();
    });
    if (invalidWaypoint != null) {
      routeError = '途经点不能包含起点或终点';
    }
    if (routeError != _routeError) {
      _routeError = routeError;
    }
  }

  void _updateFormState() {
    _updateRouteWarnings();
    final start = _startCityCtrl.text.trim();
    final end = _endCityCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final maxParticipants = int.tryParse(_maxParticipantsCtrl.text.trim());
    final canSubmit =
        title.isNotEmpty &&
            _dateRange != null &&
            start.isNotEmpty &&
            end.isNotEmpty &&
            _startEndError == null &&
            _routeError == null &&
            (maxParticipants ?? 0) > 0;
    if (canSubmit != _canSubmit && mounted) {
      setState(() {
        _canSubmit = canSubmit;
      });
    } else if (!mounted) {
      _canSubmit = canSubmit;
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    final form = _formKey.currentState;
    if (form == null) {
      return;
    }
    final isValid = form.validate();
    _updateRouteWarnings();
    if (!isValid ||
        _dateRange == null ||
        _startEndError != null ||
        _routeError != null) {
      setState(() {});
      return;
    }

    final input = CreateRoadTripInput(
      title: _titleCtrl.text.trim(),
      dateRange: _dateRange,
      startCity: _startCityCtrl.text.trim(),
      endCity: _endCityCtrl.text.trim(),
      waypoints: List<String>.from(_waypoints),
      maxParticipants: int.parse(_maxParticipantsCtrl.text.trim()),
      pricePerPerson: _priceCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_priceCtrl.text.trim()),
      carType: _carTypeCtrl.text.trim().isEmpty
          ? null
          : _carTypeCtrl.text.trim(),
      tags: List<String>.from(_tags),
      meetingPoint: _meetingPoint,
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      coverImage: _coverImage,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (_isEditing) {
        final id = widget.eventId!;
        await ref.read(eventsApiProvider).updateRoadTrip(id, input);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('修改已保存')),
        );
        Navigator.of(context).pop(id);
      } else {
        final id = await ref.read(eventsApiProvider).createRoadTrip(input);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建成功：$id')),
        );
        Navigator.of(context).pop(id);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败：$error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑自驾游活动' : '创建自驾游活动'),
      ),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? '更新行程规划' : '发布新的自驾游',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '填写行程的关键信息，组织成员一起出发。',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SectionCard(
                      icon: Icons.info_outline,
                      title: '基本信息',
                      child: Column(
                        children: [
                          FilledTextField(
                            controller: _titleCtrl,
                            labelText: '活动标题',
                            hintText: '例如：阿尔卑斯山雪景自驾',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入活动标题';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _DateRangeField(
                            dateRange: _dateRange,
                            onTap: _pickDateRange,
                            errorText: _dateRange == null ? '请选择日期范围' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.route,
                      title: '城市路线',
                      trailing: IconButton(
                        icon: const Icon(Icons.unfold_more),
                        tooltip: '管理全部途经点',
                        onPressed:
                            _waypoints.isEmpty ? null : _showWaypointsFullList,
                      ),
                      child: Column(
                        children: [
                          CitySelectorField(
                            controller: _startCityCtrl,
                            labelText: '起点城市',
                            hintText: '选择行程起点城市',
                            errorText: _startEndError,
                            onPickCity: () => _openCityPickerSheet(
                              title: '选择起点城市',
                              initialQuery: _startCityCtrl.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CitySelectorField(
                            controller: _endCityCtrl,
                            labelText: '终点城市',
                            hintText: '选择行程终点城市',
                            errorText: _startEndError,
                            onPickCity: () => _openCityPickerSheet(
                              title: '选择终点城市',
                              initialQuery: _endCityCtrl.text,
                            ),
                          ),
                          const SizedBox(height: 16),
                          WaypointTagList(
                            waypoints: _waypoints,
                            errorText: _routeError,
                            onAdd: _addWaypoint,
                            onDelete: (index) {
                              setState(() {
                                _waypoints.removeAt(index);
                              });
                              _updateFormState();
                            },
                            onEdit: _editWaypoint,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.place_outlined,
                      title: '集合地点',
                      trailing: _meetingPoint == null
                          ? null
                          : IconButton(
                              onPressed: _clearMeetingPoint,
                              icon: const Icon(Icons.clear),
                              tooltip: '清除集合地点',
                            ),
                      child: MeetingPointTile(
                        meetingPoint: _meetingPoint,
                        onTap: _selectMeetingPoint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.people_alt_outlined,
                      title: '参与与费用',
                      child: Column(
                        children: [
                          FilledTextField(
                            controller: _maxParticipantsCtrl,
                            labelText: '人数上限',
                            hintText: '请输入可参与人数',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              final number = int.tryParse(text);
                              if (number == null || number <= 0) {
                                return '请输入有效的人数';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FilledTextField(
                            controller: _priceCtrl,
                            labelText: '人均费用 (€)',
                            hintText: '选填',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return null;
                              }
                              final price = double.tryParse(text);
                              if (price == null || price < 0) {
                                return '请输入有效的费用';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FilledTextField(
                            controller: _carTypeCtrl,
                            labelText: '车辆类型',
                            hintText: '例如：SUV / MPV（选填）',
                          ),
                          const SizedBox(height: 16),
                          TagInputField(
                            tags: _tags,
                            controller: _tagInputCtrl,
                            onAdd: _addTagFromInput,
                            onRemove: _removeTag,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.photo_library_outlined,
                      title: '媒体与描述',
                      child: Column(
                        children: [
                          CoverImagePicker(
                            coverImage: _coverImage,
                            existingImageUrl: _existingCoverUrl,
                            onPick: _selectCoverImage,
                            onRemove: _removeCoverImage,
                          ),
                          const SizedBox(height: 16),
                          FilledTextField(
                            controller: _descriptionCtrl,
                            labelText: '活动描述',
                            hintText: '补充更多活动细节（选填）',
                            maxLines: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: FilledButton.icon(
            onPressed: _canSubmit && !_isSubmitting ? _submit : null,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.rocket_launch),
            label: Text(_isEditing ? '保存修改' : '发布活动'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- Widgets --------------------------------------------------------------
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      elevation: 1,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class FilledTextField extends StatelessWidget {
  const FilledTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _DateRangeField extends StatelessWidget {
  const _DateRangeField({
    required this.dateRange,
    required this.onTap,
    this.errorText,
  });

  final DateTimeRange? dateRange;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    String displayText;
    if (dateRange == null) {
      displayText = '选择日期范围';
    } else {
      final start = MaterialLocalizations.of(context)
          .formatMediumDate(dateRange!.start);
      final end =
          MaterialLocalizations.of(context).formatMediumDate(dateRange!.end);
      displayText = '$start - $end';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayText,
                    style: textTheme.bodyLarge?.copyWith(
                      color: dateRange == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class CitySelectorField extends StatelessWidget {
  const CitySelectorField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onPickCity,
    this.hintText,
    this.errorText,
  });

  final TextEditingController controller;
  final String labelText;
  final Future<String?> Function() onPickCity;
  final String? hintText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final result = await onPickCity();
            if (result != null && result.isNotEmpty) {
              controller.text = result;
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请选择城市';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: labelText,
                hintText: hintText,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: const Icon(Icons.location_city_outlined),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class WaypointTagList extends StatelessWidget {
  const WaypointTagList({
    super.key,
    required this.waypoints,
    required this.onAdd,
    required this.onDelete,
    required this.onEdit,
    this.errorText,
  });

  final List<String> waypoints;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEdit;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...List<Widget>.generate(waypoints.length, (index) {
                final waypoint = waypoints[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        _shortenWaypointLabel(waypoint),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onPressed: () => onEdit(index),
                    onDeleted: () => onDelete(index),
                  ),
                );
              }),
              AssistChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('添加'),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
        ],
      ],
    );
  }

  String _shortenWaypointLabel(String input) {
    final trimmed = input.trim();
    if (trimmed.length <= 16) {
      return trimmed;
    }
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.isEmpty) {
      return trimmed.substring(0, min(14, trimmed.length)) + '…';
    }
    if (words.length == 1) {
      return words.first.substring(0, min(14, words.first.length)) + '…';
    }
    return '${words.first}…';
  }
}

class TagInputField extends StatelessWidget {
  const TagInputField({
    super.key,
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: '标签',
            hintText: '输入后回车添加，例如：风景 / 露营',
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAdd,
            ),
          ),
          onEditingComplete: onAdd,
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => onRemove(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class MeetingPointTile extends StatelessWidget {
  const MeetingPointTile({
    super.key,
    required this.meetingPoint,
    required this.onTap,
  });

  final MeetingPoint? meetingPoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: colorScheme.surfaceVariant,
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        child: const Icon(Icons.map_outlined),
      ),
      title: Text(
        '集合地点',
        style: textTheme.titleMedium,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: meetingPoint == null
            ? Text(
                '未选择',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meetingPoint!.displayName,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meetingPoint!.address,
                    style: textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class CoverImagePicker extends StatelessWidget {
  const CoverImagePicker({
    super.key,
    required this.coverImage,
    required this.existingImageUrl,
    required this.onPick,
    required this.onRemove,
  });

  final XFile? coverImage;
  final String? existingImageUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final imageWidget = coverImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(coverImage!.path),
              fit: BoxFit.cover,
            ),
          )
        : existingImageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  existingImageUrl!,
                  fit: BoxFit.cover,
                ),
              )
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: imageWidget ??
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, color: colorScheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        '暂未选择封面图',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(coverImage == null && existingImageUrl == null
                  ? '选择图片'
                  : '更换图片'),
            ),
            const SizedBox(width: 12),
            if (coverImage != null || existingImageUrl != null)
              OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除'),
              ),
          ],
        ),
      ],
    );
  }
}

class CitySearchSheet extends ConsumerStatefulWidget {
  const CitySearchSheet({
    super.key,
    required this.title,
    required this.initialQuery,
  });

  final String title;
  final String initialQuery;

  @override
  ConsumerState<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends ConsumerState<CitySearchSheet> {
  late final TextEditingController _searchCtrl;
  Timer? _debounce;
  List<CityPrediction> _predictions = const <CityPrediction>[];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _searchCtrl.addListener(_onSearchChanged);
    if (widget.initialQuery.trim().isNotEmpty) {
      _loadPredictions(widget.initialQuery.trim());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadPredictions(query);
    });
  }

  Future<void> _loadPredictions(String query) async {
    if (!mounted) {
      return;
    }
    if (query.isEmpty) {
      setState(() {
        _predictions = const <CityPrediction>[];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(placesServiceProvider);
      final results = await service.autocompleteCities(query);
      if (!mounted) {
        return;
      }
      setState(() {
        _predictions = results;
        _isLoading = false;
      });
    } on PlacesApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.message;
        _predictions = const <CityPrediction>[];
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = '搜索失败，请稍后再试';
        _predictions = const <CityPrediction>[];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '输入城市名称',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!_isLoading && _error != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_error!, textAlign: TextAlign.center),
            ),
          if (!_isLoading && _error == null)
            SizedBox(
              height: 320,
              child: _predictions.isEmpty
                  ? const Center(child: Text('暂无匹配城市'))
                  : ListView.separated(
                      itemCount: _predictions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text(prediction.primaryText),
                          subtitle: prediction.secondaryText != null
                              ? Text(prediction.secondaryText!)
                              : null,
                          onTap: () {
                            Navigator.of(context).pop(prediction.primaryText);
                          },
                        );
                      },
                    ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: FilledButton(
              onPressed: _searchCtrl.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_searchCtrl.text.trim()),
              child: Text('使用“${_searchCtrl.text.trim()}”'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointEditSheet extends StatefulWidget {
  const _WaypointEditSheet({required this.initialValue});

  final String initialValue;

  @override
  State<_WaypointEditSheet> createState() => _WaypointEditSheetState();
}

class _WaypointEditSheetState extends State<_WaypointEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '编辑途经城市',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: '城市名',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('移除'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_controller.text.trim());
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaypointListSheet extends StatelessWidget {
  const _WaypointListSheet({
    required this.waypoints,
    required this.onDelete,
    required this.onEdit,
  });

  final List<String> waypoints;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '全部途经城市',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (waypoints.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('尚未添加途经城市')),
            )
          else
            SizedBox(
              height: 320,
              child: ListView.separated(
                itemCount: waypoints.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final waypoint = waypoints[index];
                  return ListTile(
                    title: Text(waypoint),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          onPressed: () => onEdit(index),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            onDelete(index);
                            Navigator.of(context).maybePop();
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class MeetingPointPickerPage extends ConsumerStatefulWidget {
  const MeetingPointPickerPage({super.key, this.initialPoint});

  final MeetingPoint? initialPoint;

  @override
  ConsumerState<MeetingPointPickerPage> createState() =>
      _MeetingPointPickerPageState();
}

class _MeetingPointPickerPageState
    extends ConsumerState<MeetingPointPickerPage> {
  LatLng? _selected;
  String? _address;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPoint != null) {
      _selected = LatLng(widget.initialPoint!.lat, widget.initialPoint!.lng);
      _address = widget.initialPoint!.address;
    }
  }

  Future<void> _onLongPress(LatLng position) async {
    setState(() {
      _selected = position;
      _isLoadingAddress = true;
      _address = null;
    });
    final address = await _reverseGeocode(position);
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoadingAddress = false;
      _address = address;
    });
    await _showConfirmationSheet(position, address);
  }

  Future<void> _showConfirmationSheet(
    LatLng position,
    String? address,
  ) async {
    if (!mounted) {
      return;
    }
    final displayController = TextEditingController(
      text: widget.initialPoint?.displayName ??
          _suggestDisplayName(address) ??
          '集合地点',
    );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: viewInsets + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '使用此地点作为集合点？',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: displayController,
                decoration: InputDecoration(
                  labelText: '展示名称',
                  hintText: '例如：Berlin Hbf',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (address != null)
                Text(
                  address,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                )
              else if (_isLoadingAddress)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(),
                )
              else
                const Text('未能获取详细地址，可继续使用坐标'),
              const SizedBox(height: 16),
              Text(
                '纬度：${position.latitude.toStringAsFixed(6)}\n经度：${position.longitude.toStringAsFixed(6)}',
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final display = displayController.text.trim().isEmpty
                      ? '集合地点'
                      : displayController.text.trim();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(
                    MeetingPoint(
                      displayName: display,
                      address: address ?? display,
                      lat: position.latitude,
                      lng: position.longitude,
                    ),
                  );
                },
                child: const Text('使用此地点'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _reverseGeocode(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) {
        return null;
      }
      final place = placemarks.first;
      final parts = <String?>[
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ];
      return parts
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join(', ');
    } catch (_) {
      return null;
    }
  }

  String? _suggestDisplayName(String? address) {
    if (address == null || address.isEmpty) {
      return null;
    }
    final parts = address.split(',');
    if (parts.isEmpty) {
      return null;
    }
    return parts.first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final initialPosition = _selected ?? const LatLng(52.52, 13.405);

    return Scaffold(
      appBar: AppBar(title: const Text('选择集合地点')),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(target: initialPosition, zoom: 13),
        onMapCreated: (_) {},
        onLongPress: _onLongPress,
        markers: _selected == null
            ? <Marker>{}
            : {
                Marker(
                  markerId: const MarkerId('meeting_point'),
                  position: _selected!,
                ),
              },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selected == null
                    ? '长按地图选择集合地点'
                    : (_address ?? '正在获取地址…'),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selected == null
                    ? null
                    : () async {
                        final position = _selected!;
                        await _showConfirmationSheet(position, _address);
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('使用当前选点'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

