import 'dart:typed_data';

import 'package:crew_app/features/events/data/event_draft.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class _CreateEventImage {
  _CreateEventImage({required this.file, required this.bytes});

  final XFile file;
  final Uint8List bytes;
}

Future<EventDraft?> showCreateEventBottomSheet(
  BuildContext context,
  LatLng position,
) {
  return Navigator.of(context).push<EventDraft>(
    PageRouteBuilder<EventDraft>(
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return _MapCreateEventSheetRoute(
          animation: animation,
          position: position,
        );
      },
    ),
  );
}

class _MapCreateEventSheetRoute extends StatefulWidget {
  const _MapCreateEventSheetRoute({
    required this.animation,
    required this.position,
  });

  final Animation<double> animation;
  final LatLng position;

  @override
  State<_MapCreateEventSheetRoute> createState() =>
      _MapCreateEventSheetRouteState();
}

class _MapCreateEventSheetRouteState
    extends State<_MapCreateEventSheetRoute> {
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.25,
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            snap: true,
            snapSizes: const [0.25, 0.6, 0.95],
            builder: (sheetContext, scrollController) {
              return Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 12,
                shadowColor:
                    Theme.of(context).colorScheme.shadow.withValues(alpha: .18),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                clipBehavior: Clip.antiAlias,
                child: MapCreateEventSheet(
                  position: widget.position,
                  scrollController: scrollController,
                  onCancel: () => Navigator.of(sheetContext).pop(),
                  onSubmit: (draft) => Navigator.of(sheetContext).pop(draft),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class MapCreateEventSheet extends StatefulWidget {
  const MapCreateEventSheet({
    super.key,
    required this.position,
    required this.scrollController,
    required this.onCancel,
    required this.onSubmit,
  });

  final LatLng position;
  final ScrollController scrollController;
  final VoidCallback onCancel;
  final ValueChanged<EventDraft> onSubmit;

  @override
  State<MapCreateEventSheet> createState() => _MapCreateEventSheetState();
}

class _MapCreateEventSheetState extends State<MapCreateEventSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _cityController;
  final ImagePicker _picker = ImagePicker();
  final List<_CreateEventImage> _images = [];
  int? _coverIndex;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    _initialized = true;
    final loc = AppLocalizations.of(context)!;
    _cityController.text = loc.city_loading;
    _loadCityName(loc);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadCityName(AppLocalizations loc) async {
    try {
      final list = await placemarkFromCoordinates(
        widget.position.latitude,
        widget.position.longitude,
      ).timeout(const Duration(seconds: 5));
      if (!mounted) {
        return;
      }
      if (list.isEmpty) {
        _cityController.text = loc.unknown;
        return;
      }
      final placemark = list.first;
      final cityName = (placemark.locality?.trim().isNotEmpty == true)
          ? placemark.locality!
          : (placemark.subAdministrativeArea?.trim().isNotEmpty == true)
              ? placemark.subAdministrativeArea!
              : (placemark.administrativeArea ?? loc.unknown);
      _cityController.text = cityName;
    } catch (_) {
      if (!mounted) {
        return;
      }
      _cityController.text = loc.unknown;
    }
  }

  Future<void> _handleAddImages() async {
    final remain = 5 - _images.length;
    if (remain <= 0) {
      return;
    }
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }
    for (final img in picked.take(remain)) {
      final bytes = await img.readAsBytes();
      _images.add(_CreateEventImage(file: img, bytes: bytes));
    }
    if (_images.isNotEmpty && _coverIndex == null) {
      _coverIndex = 0;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _handleRemoveImage(int index) {
    if (index < 0 || index >= _images.length) {
      return;
    }
    setState(() {
      _images.removeAt(index);
      if (_images.isEmpty) {
        _coverIndex = null;
      } else if (_coverIndex != null) {
        if (_coverIndex! == index) {
          _coverIndex = 0;
        } else if (_coverIndex! > index) {
          _coverIndex = _coverIndex! - 1;
        }
      }
    });
  }

  void _handleSelectCover(int index) {
    setState(() => _coverIndex = index);
  }

  void _handleSubmit(AppLocalizations loc) {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final draft = EventDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      locationName: _cityController.text.trim().isEmpty
          ? loc.unknown
          : _cityController.text.trim(),
    );
    widget.onSubmit(draft);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.create_event_title,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.location_coordinates(
                          widget.position.latitude.toStringAsFixed(6),
                          widget.position.longitude.toStringAsFixed(6),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  tooltip: loc.action_cancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: loc.city_field_label,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_city),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? loc.please_enter_city
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: loc.event_title_field_label,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? loc.please_enter_event_title
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: loc.event_description_field_label,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '活动图片 (最多5张)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${_images.length}/5',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: .7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_images.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _images.length; i++)
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _handleSelectCover(i),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _coverIndex == i
                                    ? theme.colorScheme.primary
                                    : Colors.grey.shade300,
                                width: _coverIndex == i ? 2 : 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.memory(
                              _images[i].bytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _handleRemoveImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        if (_coverIndex == i)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '封面',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            if (_images.length < 5)
              OutlinedButton.icon(
                onPressed: _handleAddImages,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('添加图片'),
              ),
            if (_images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _coverIndex == null
                      ? '未选择封面，默认使用第一张图片。'
                      : '已选择第${_coverIndex! + 1}张作为封面。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: .7),
                  ),
                ),
              ),
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
                    onPressed: () => _handleSubmit(loc),
                    child: Text(loc.action_create),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
