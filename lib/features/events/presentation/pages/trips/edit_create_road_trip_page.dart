import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// --- Data models ----------------------------------------------------------
class CreateRoadTripInput {
  final String? id;
  final String title;
  final DateTimeRange dateRange;
  final String startLocation; // You can switch this to a lat/lng model later
  final String endLocation;
  final String meetingPoint;
  final bool isRoundTrip;
  final List<String> waypoints;
  final int maxParticipants;
  final bool isFree;
  final double? pricePerPerson;
  final String? carType;
  final List<String> tags;
  final String description;
  final List<File> galleryImages;
  final List<String> existingImageUrls;

  CreateRoadTripInput({
    this.id,
    required this.title,
    required this.dateRange,
    required this.startLocation,
    required this.endLocation,
    required this.meetingPoint,
    required this.isRoundTrip,
    required this.waypoints,
    required this.maxParticipants,
    required this.isFree,
    this.pricePerPerson,
    this.carType,
    required this.tags,
    required this.description,
    this.galleryImages = const <File>[],
    this.existingImageUrls = const <String>[],
  });

  File? get coverImage => galleryImages.isEmpty ? null : galleryImages[0];
}

/// --- API provider (stub) --------------------------------------------------
final eventsApiProvider = Provider<EventsApi>((ref) => EventsApi());

class EventsApi {
  Future<String> createRoadTrip(CreateRoadTripInput input) async {
    // TODO: 调用 Crew.Api (ASP.NET 9) 的创建活动接口
    // 例如: POST /api/roadtrips with JSON body + multipart for image
    await Future.delayed(const Duration(milliseconds: 600));
    return "event_123"; // 返回后端生成的ID
  }
}

/// --- Page -----------------------------------------------------------------
class EditOrCreateRoadTripPage extends ConsumerStatefulWidget {
  const EditOrCreateRoadTripPage({
    super.key,
    required this.onClose,
    this.initialValue,
    this.onSubmit,
  });
  final VoidCallback onClose;
  final CreateRoadTripInput? initialValue;
  final Future<void> Function(CreateRoadTripInput input)? onSubmit;

  bool get isEditing => initialValue != null;

  @override
  ConsumerState<EditOrCreateRoadTripPage> createState() => _EditOrCreateRoadTripPageState();
}

class _EditOrCreateRoadTripPageState extends ConsumerState<EditOrCreateRoadTripPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _endLocationCtrl = TextEditingController();
  final _meetingLocationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '4');
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  DateTimeRange? _dateRange;
  String? _carType;
  late TripRouteType _routeType;
  late PricingType _pricingType;

  final List<String> _waypoints = [];
  final List<String> _tags = [];
  final List<_GalleryItem> _galleryItems = [];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _routeType = TripRouteType.roundTrip;
    _pricingType = PricingType.free;

    final initial = widget.initialValue;
    if (initial != null) {
      _titleCtrl.text = initial.title;
      _dateRange = initial.dateRange;
      _startLocationCtrl.text = initial.startLocation;
      _endLocationCtrl.text = initial.endLocation;
      _meetingLocationCtrl.text = initial.meetingPoint;
      _maxParticipantsCtrl.text = initial.maxParticipants.toString();
      if (initial.pricePerPerson != null) {
        _priceCtrl.text = initial.pricePerPerson!.toString();
      }
      _descriptionCtrl.text = initial.description;
      _carType = initial.carType;
      _routeType = initial.isRoundTrip
          ? TripRouteType.roundTrip
          : TripRouteType.oneWay;
      _pricingType = initial.isFree ? PricingType.free : PricingType.paid;
      _tags
        ..clear()
        ..addAll(initial.tags);
      _waypoints
        ..clear()
        ..addAll(initial.waypoints);
      if (initial.existingImageUrls.isNotEmpty) {
        _galleryItems.addAll(
          initial.existingImageUrls.map((url) => _GalleryItem.network(url)),
        );
      }
      if (initial.galleryImages.isNotEmpty) {
        _galleryItems.addAll(initial.galleryImages.map(_GalleryItem.file));
      }
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
          _dateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    setState(() {
      final newItems = picked.map((x) => _GalleryItem.file(File(x.path)));
      _galleryItems.addAll(newItems);
    });
  }

  void _setCover(int index) {
    if (index < 0 || index >= _galleryItems.length) return;
    setState(() {
      final item = _galleryItems.removeAt(index);
      _galleryItems.insert(0, item);
    });
  }

  void _removeGalleryItem(int index) {
    if (index < 0 || index >= _galleryItems.length) return;
    setState(() {
      _galleryItems.removeAt(index);
    });
  }

  void _addWaypointDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('添加途经点'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: '例如：Pisa Tower 或者具体地址'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _waypoints.add(ctrl.text.trim()));
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
    final t = _tagInputCtrl.text.trim();
    if (t.isEmpty) return;
    if (_tags.contains(t)) return;
    setState(() => _tags.add(t));
    _tagInputCtrl.clear();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择活动日期范围')));
      return;
    }

    if (_pricingType == PricingType.paid) {
      final price = double.tryParse(_priceCtrl.text.trim());
      if (price == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请输入正确的人均费用')));
        return;
      }
    }

    final input = CreateRoadTripInput(
      id: widget.initialValue?.id,
      title: _titleCtrl.text.trim(),
      dateRange: _dateRange!,
      startLocation: _startLocationCtrl.text.trim(),
      endLocation: _endLocationCtrl.text.trim(),
      meetingPoint: _meetingLocationCtrl.text.trim(),
      isRoundTrip: _routeType == TripRouteType.roundTrip,
      waypoints: List.of(_waypoints),
      maxParticipants: int.parse(_maxParticipantsCtrl.text),
      isFree: _pricingType == PricingType.free,
      pricePerPerson: _pricingType == PricingType.free
          ? null
          : double.tryParse(_priceCtrl.text.trim()),
      carType: _carType,
      tags: List.of(_tags),
      description: _descriptionCtrl.text.trim(),
      galleryImages: _galleryItems
          .where((item) => item.file != null)
          .map((item) => item.file!)
          .toList(),
      existingImageUrls: _galleryItems
          .where((item) => item.url != null)
          .map((item) => item.url!)
          .toList(),
    );

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(input);
        if (!mounted) return;
        Navigator.pop(context, input);
        return;
      }

      final id = await ref.read(eventsApiProvider).createRoadTrip(input);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );

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
              Text(
                widget.isEditing ? '更新旅程，焕新体验' : '让灵感变成下一次旅程',
                style: titleStyle,
              ),
              const SizedBox(height: 12),
              Text(
                '完成关卡式表单，召集伙伴一起上路！',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                icon: Icons.rocket_launch_outlined,
                title: '基础信息',
                subtitle: '命名旅程并锁定时间',
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: _inputDecoration('旅程标题', '如：五渔村海岸线一日自驾'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入标题' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.calendar_month,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('活动日期'),
                    subtitle: Text(
                      _dateRange == null
                          ? '点击选择日期范围'
                          : '${_formatDate(_dateRange!.start)} → ${_formatDate(_dateRange!.end)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickDateRange,
                  ),
                ],
              ),
              _buildSectionCard(
                icon: Icons.route_outlined,
                title: '路线设定',
                subtitle: '规划起终点与集合点',
                children: [
                  TextFormField(
                    controller: _startLocationCtrl,
                    decoration: _inputDecoration('起点', '如：Milan Duomo 或地标'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入起点' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _endLocationCtrl,
                    decoration: _inputDecoration('终点', '如：La Spezia 或景点'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入终点' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _meetingLocationCtrl,
                    decoration: _inputDecoration('集合地点', '如：停车场、地铁口'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入集合地点' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '路线类型',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<TripRouteType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TripRouteType.roundTrip,
                        label: Text('往返路线'),
                        icon: Icon(Icons.autorenew),
                      ),
                      ButtonSegment(
                        value: TripRouteType.oneWay,
                        label: Text('单程路线'),
                        icon: Icon(Icons.route_outlined),
                      ),
                    ],
                    selected: {_routeType},
                    onSelectionChanged: (value) {
                      setState(() => _routeType = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _addWaypointDialog,
                        icon: const Icon(Icons.add_road),
                        label: const Text('添加途经点'),
                      ),
                      const SizedBox(width: 12),
                      if (_waypoints.isNotEmpty)
                        Text(
                          '共 ${_waypoints.length} 个',
                          style: theme.textTheme.bodyMedium,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _waypoints
                        .asMap()
                        .entries
                        .map(
                          (e) => Chip(
                            label: Text('${e.key + 1}. ${e.value}'),
                            onDeleted: () =>
                                setState(() => _waypoints.removeAt(e.key)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              _buildSectionCard(
                icon: Icons.groups_3_outlined,
                title: '团队配置',
                subtitle: '人数限制与费用模式',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _maxParticipantsCtrl,
                          decoration: _inputDecoration('人数上限', '例如 4'),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final n = int.tryParse(v ?? '');
                            if (n == null || n < 1) {
                              return '请输入≥1的整数';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _priceCtrl,
                          decoration: _inputDecoration(
                            '人均费用 (€)',
                            _pricingType == PricingType.free
                                ? '免费活动'
                                : '例如 29.5',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          enabled: _pricingType == PricingType.paid,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<PricingType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: PricingType.free,
                        label: Text('免费'),
                        icon: Icon(Icons.favorite_outline),
                      ),
                      ButtonSegment(
                        value: PricingType.paid,
                        label: Text('收费'),
                        icon: Icon(Icons.payments_outlined),
                      ),
                    ],
                    selected: {_pricingType},
                    onSelectionChanged: (value) {
                      setState(() {
                        _pricingType = value.first;
                        if (_pricingType == PricingType.free) {
                          _priceCtrl.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
              _buildSectionCard(
                icon: Icons.tune,
                title: '个性设置',
                subtitle: '车辆与标签',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _carType,
                    decoration: _inputDecoration('车辆类型（可选）', null),
                    items: const [
                      DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                      DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                      DropdownMenuItem(
                        value: 'Hatchback',
                        child: Text('Hatchback'),
                      ),
                      DropdownMenuItem(value: 'Van', child: Text('Van')),
                    ],
                    onChanged: (v) => setState(() => _carType = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagInputCtrl,
                    decoration: _inputDecoration('添加标签', '回车或点击 + 添加').copyWith(
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _addTagFromInput,
                      ),
                    ),
                    onSubmitted: (_) => _addTagFromInput(),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _tags
                        .map(
                          (t) => Chip(
                            label: Text('#$t'),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => setState(() => _tags.remove(t)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              _buildSectionCard(
                icon: Icons.photo_library_outlined,
                title: '旅程影像',
                subtitle: '可选择多张，首张默认为封面',
                children: [
                  _GalleryGrid(
                    items: _galleryItems,
                    onRemove: _removeGalleryItem,
                    onSetCover: _setCover,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.collections_outlined),
                    label: Text(_galleryItems.isEmpty ? '选择图片' : '追加图片'),
                  ),
                ],
              ),
              _buildSectionCard(
                icon: Icons.description_outlined,
                title: '活动亮点',
                subtitle: '告诉伙伴们为什么要来',
                children: [
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: _inputDecoration('详细描述', '路线亮点、注意事项、装备建议…'),
                    maxLines: 6,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入描述' : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(widget.isEditing ? '保存活动' : '创建活动'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _GalleryItem {
  const _GalleryItem.file(this.file) : url = null;
  const _GalleryItem.network(this.url) : file = null;

  final File? file;
  final String? url;

  bool get isFile => file != null;
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({
    required this.items,
    required this.onRemove,
    required this.onSetCover,
  });

  final List<_GalleryItem> items;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onSetCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (items.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: .2)),
          color: colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Text(
            '还没有选择图片，点击下方按钮添加',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _GalleryTile(
          index: index,
          item: item,
          onRemove: () => onRemove(index),
          onSetCover: () => onSetCover(index),
        );
      },
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onSetCover,
  });

  final int index;
  final _GalleryItem item;
  final VoidCallback onRemove;
  final VoidCallback onSetCover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onSetCover,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: colorScheme.surfaceContainerHighest,
              child: item.isFile
                  ? Image.file(item.file!, fit: BoxFit.cover)
                  : Image.network(item.url!, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: index == 0
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceTint.withValues(alpha:  0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                index == 0 ? '封面' : '第 ${index + 1} 张',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: index == 0
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceTint.withValues(alpha:  0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  color: colorScheme.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
          if (index != 0)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceTint.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '设为封面',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum TripRouteType { oneWay, roundTrip }

enum PricingType { free, paid }
