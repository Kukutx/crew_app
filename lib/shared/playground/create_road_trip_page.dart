import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// --- Data models ----------------------------------------------------------
class CreateRoadTripInput {
  final String title;
  final DateTimeRange dateRange;
  final String startLocation; // You can switch this to a lat/lng model later
  final List<String> waypoints;
  final int maxParticipants;
  final double? pricePerPerson;
  final String? carType;
  final List<String> tags;
  final String? privacy; // "public" | "private"
  final String description;
  final File? coverImage;

  CreateRoadTripInput({
    required this.title,
    required this.dateRange,
    required this.startLocation,
    required this.waypoints,
    required this.maxParticipants,
    this.pricePerPerson,
    this.carType,
    required this.tags,
    this.privacy,
    required this.description,
    this.coverImage,
  });
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
  const CreateRoadTripPage({super.key});

  @override
  ConsumerState<CreateRoadTripPage> createState() => _CreateRoadTripPageState();
}

class _CreateRoadTripPageState extends ConsumerState<CreateRoadTripPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '4');
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();

  DateTimeRange? _dateRange;
  String? _carType;
  String? _privacy = 'public';
  File? _coverImage;

  final List<String> _waypoints = [];
  final List<String> _tags = [];

  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _startLocationCtrl.dispose();
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
      initialDateRange: _dateRange ?? DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickCover() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _coverImage = File(x.path));
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() => _waypoints.add(ctrl.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          )
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择活动日期范围')));
      return;
    }

    final input = CreateRoadTripInput(
      title: _titleCtrl.text.trim(),
      dateRange: _dateRange!,
      startLocation: _startLocationCtrl.text.trim(),
      waypoints: List.of(_waypoints),
      maxParticipants: int.parse(_maxParticipantsCtrl.text),
      pricePerPerson: _priceCtrl.text.isEmpty ? null : double.tryParse(_priceCtrl.text),
      carType: _carType,
      tags: List.of(_tags),
      privacy: _privacy,
      description: _descriptionCtrl.text.trim(),
      coverImage: _coverImage,
    );

    try {
      final id = await ref.read(eventsApiProvider).createRoadTrip(input);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建成功：$id')));
        Navigator.pop(context, id);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('创建失败：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建自驾游活动')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 标题
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: '标题', hintText: '如：五渔村海岸线一日自驾'),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
              const SizedBox(height: 12),

              // 日期范围
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日期范围'),
                subtitle: Text(_dateRange == null
                    ? '未选择'
                    : '${_dateRange!.start.toString().split(' ').first} → ${_dateRange!.end.toString().split(' ').first}'),
                trailing: const Icon(Icons.date_range),
                onTap: _pickDateRange,
              ),
              const Divider(),

              // 起点位置（后续可替换为谷歌地图/Places选择器）
              TextFormField(
                controller: _startLocationCtrl,
                decoration: const InputDecoration(
                  labelText: '起点位置',
                  hintText: '如：Milano Duomo，或使用地图选择',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入起点位置' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _addWaypointDialog,
                    icon: const Icon(Icons.add_road),
                    label: const Text('添加途经点'),
                  ),
                  const SizedBox(width: 12),
                  if (_waypoints.isNotEmpty) Text('共 ${_waypoints.length} 个')
                ],
              ),
              Wrap(
                spacing: 8,
                children: _waypoints
                    .asMap()
                    .entries
                    .map((e) => Chip(
                          label: Text('${e.key + 1}. ${e.value}'),
                          onDeleted: () => setState(() => _waypoints.removeAt(e.key)),
                        ))
                    .toList(),
              ),
              const Divider(),

              // 参与人数 & 价格
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _maxParticipantsCtrl,
                      decoration: const InputDecoration(labelText: '人数上限'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 1) return '请输入≥1的整数';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: '人均费用 (€)', hintText: '可空'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 车辆类型
              DropdownButtonFormField<String>(
                value: _carType,
                decoration: const InputDecoration(labelText: '车辆类型（可选）'),
                items: const [
                  DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                  DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                  DropdownMenuItem(value: 'Hatchback', child: Text('Hatchback')),
                  DropdownMenuItem(value: 'Van', child: Text('Van')),
                ],
                onChanged: (v) => setState(() => _carType = v),
              ),
              const SizedBox(height: 12),

              // 隐私
              DropdownButtonFormField<String>(
                value: _privacy,
                decoration: const InputDecoration(labelText: '可见性'),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('公开')),
                  DropdownMenuItem(value: 'private', child: Text('私密（仅邀请）')),
                ],
                onChanged: (v) => setState(() => _privacy = v),
              ),
              const SizedBox(height: 12),

              // 标签
              TextField(
                controller: _tagInputCtrl,
                decoration: InputDecoration(
                  labelText: '添加标签（回车确认）',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addTagFromInput,
                  ),
                ),
                onSubmitted: (_) => _addTagFromInput(),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((t) => Chip(
                          label: Text('#$t'),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ))
                    .toList(),
              ),
              const Divider(),

              // 封面图
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _coverImage == null
                    ? const CircleAvatar(child: Icon(Icons.image))
                    : CircleAvatar(backgroundImage: FileImage(_coverImage!)),
                title: const Text('封面图'),
                subtitle: Text(_coverImage?.path.split('/').last ?? '未选择'),
                trailing: FilledButton.icon(
                  onPressed: _pickCover,
                  icon: const Icon(Icons.upload),
                  label: const Text('选择图片'),
                ),
              ),
              const SizedBox(height: 12),

              // 描述
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(labelText: '活动描述', hintText: '路线亮点、注意事项、装备建议…'),
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入描述' : null,
              ),
              const SizedBox(height: 24),

              // 提交
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('创建活动'),
              ),
              const SizedBox(height: 24),

              // 备注区域（集成指引）
              _Hints(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hints extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('集成提示', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('1) 起点/途经点建议接入 Google Places/Maps：点击选择地图点位写回文本。'),
          Text('2) 登录：使用 Firebase Auth，提交时附带用户ID到 Crew.Api。'),
          Text('3) 上传：封面图可先传 Firebase Storage，拿到下载URL再发给 Crew.Api。'),
          Text('4) 权限：隐私为私密时，后端应生成邀请链接/邀请码。'),
          Text('5) 校验：后端需二次校验时间范围、人数上限、字段长度与敏感词等。'),
        ],
      ),
    );
  }
}
