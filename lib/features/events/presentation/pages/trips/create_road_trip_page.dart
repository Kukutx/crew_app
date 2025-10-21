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
  final String? privacy; // "public" | "private"
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
    this.privacy,
    required this.description,
    this.galleryImages = const <File>[],
    this.existingImageUrls = const <String>[],
  });

  File? get coverImage =>
      galleryImages.isEmpty ? null : galleryImages[0];
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
class CreateRoadTripPage extends ConsumerStatefulWidget {
  const CreateRoadTripPage({
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
  ConsumerState<CreateRoadTripPage> createState() => _CreateRoadTripPageState();
}

class _CreateRoadTripPageState extends ConsumerState<CreateRoadTripPage> {
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
  String? _privacy = 'public';
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
      _privacy = initial.privacy ?? 'public';
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
          initial.existingImageUrls
              .map((url) => _GalleryItem.network(url)),
        );
      }
      if (initial.galleryImages.isNotEmpty) {
        _galleryItems.addAll(
          initial.galleryImages.map(_GalleryItem.file),
        );
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
    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入正确的人均费用')),
        );
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
      privacy: _privacy,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.isEditing ? '更新' : '创建'}成功：$id')));
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
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF111322),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isEditing ? '编辑自驾游活动' : '创建自驾游活动'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: widget.onClose,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F1BEE), Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                Text(
                  widget.isEditing ? '更新旅程，焕新体验' : '让灵感变成下一次旅程',
                  style: titleStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  '完成关卡式表单，召集伙伴一起上路！',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
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
                      style: const TextStyle(color: Colors.white),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入标题' : null,
                    ),
                    const SizedBox(height: 16),
                    _GradientTile(
                      icon: Icons.calendar_month,
                      title: '活动日期',
                      value: _dateRange == null
                          ? '点击选择日期范围'
                          : '${_formatDate(_dateRange!.start)} → ${_formatDate(_dateRange!.end)}',
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
                      decoration:
                          _inputDecoration('起点', '如：Milan Duomo 或地标'),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '请输入起点'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _endLocationCtrl,
                      decoration:
                          _inputDecoration('终点', '如：La Spezia 或景点'),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '请输入终点'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _meetingLocationCtrl,
                      decoration: _inputDecoration('集合地点', '如：停车场、地铁口'),
                      style: const TextStyle(color: Colors.white),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '请输入集合地点'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '路线类型',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TripRouteType>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                        ),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.add_road_outlined,
                              color: Colors.white, size: 18),
                          label: const Text('添加途经点'),
                          backgroundColor: Colors.white.withOpacity(0.08),
                          labelStyle: const TextStyle(color: Colors.white),
                          onPressed: _addWaypointDialog,
                        ),
                        ..._waypoints.asMap().entries.map(
                              (e) => InputChip(
                                label: Text('${e.key + 1}. ${e.value}'),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                backgroundColor:
                                    Colors.white.withOpacity(0.08),
                                onDeleted: () => setState(
                                  () => _waypoints.removeAt(e.key),
                                ),
                                deleteIconColor: Colors.white70,
                              ),
                            ),
                      ],
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
                            style: const TextStyle(color: Colors.white),
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
                            style: const TextStyle(color: Colors.white),
                            keyboardType:
                                const TextInputType.numberWithOptions(
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
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                        ),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
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
                  subtitle: '车辆、隐私与标签',
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1E1F3B),
                      value: _carType,
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      decoration: _inputDecoration('车辆类型（可选）', null),
                      items: [
                        DropdownMenuItem(
                          value: 'Sedan',
                          child: Text('Sedan',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'SUV',
                          child: Text('SUV',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'Hatchback',
                          child: Text('Hatchback',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'Van',
                          child: Text('Van',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _carType = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF1E1F3B),
                      value: _privacy,
                      style: const TextStyle(color: Colors.white),
                      iconEnabledColor: Colors.white,
                      decoration: _inputDecoration('可见性', null),
                      items: [
                        DropdownMenuItem(
                          value: 'public',
                          child: Text('公开',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'private',
                          child: Text('私密（仅邀请）',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _privacy = v),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tagInputCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('添加标签', '回车或点击 + 添加')
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.white70),
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
                              labelStyle:
                                  const TextStyle(color: Colors.white),
                              backgroundColor:
                                  Colors.white.withOpacity(0.08),
                              deleteIconColor: Colors.white70,
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
                      label: Text(
                        _galleryItems.isEmpty ? '选择图片' : '追加图片',
                      ),
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
                      style: const TextStyle(color: Colors.white),
                      maxLines: 6,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '请输入描述'
                          : null,
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
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white54, width: 1.2),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF80FFEA), Color(0xFF8A4FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF0B0D1B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

class _GradientTile extends StatelessWidget {
  const _GradientTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0x33258CF9), Color(0x336A11CB)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
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
    if (items.isEmpty) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          color: Colors.white.withOpacity(0.04),
        ),
        child: const Center(
          child: Text(
            '还没有选择图片，点击下方按钮添加',
            style: TextStyle(color: Colors.white54),
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
    return GestureDetector(
      onTap: onSetCover,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              color: Colors.white.withOpacity(0.08),
              child: item.isFile
                  ? Image.file(
                      item.file!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      item.url!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: index == 0
                    ? Colors.amberAccent
                    : Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                index == 0 ? '封面' : '第 ${index + 1} 张',
                style: TextStyle(
                  color: index == 0 ? Colors.black : Colors.white,
                  fontSize: 11,
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
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
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
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '设为封面',
                  style: TextStyle(color: Colors.white, fontSize: 11),
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
