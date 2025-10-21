import 'package:flutter/material.dart';

import '../../widgets/plaza_post_card.dart';

class EditMomentPage extends StatefulWidget {
  const EditMomentPage({super.key, required this.post});

  final PlazaPost post;

  static MaterialPageRoute<bool> route({required PlazaPost post}) {
    return MaterialPageRoute<bool>(
      builder: (_) => EditMomentPage(post: post),
    );
  }

  @override
  State<EditMomentPage> createState() => _EditMomentPageState();
}

class _EditMomentPageState extends State<EditMomentPage> {
  late final TextEditingController _contentController;
  late final TextEditingController _locationController;
  late final List<String> _tagSuggestions;
  late final Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedTags = widget.post.tags.toSet();
    _tagSuggestions = {
      ...widget.post.tags,
      '周末',
      '好友局',
      '音乐',
      '运动',
      '户外',
      '咖啡',
      '夜跑',
      '城市漫游',
    }.toList()
      ..sort();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaAssets = widget.post.mediaAssets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑瞬间'),
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            if (mediaAssets.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.asset(
                    mediaAssets.first,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.surfaceVariant,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showPreviewMessage('更换封面'),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('更换封面'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '瞬间描述',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              minLines: 4,
              maxLines: 6,
              maxLength: 240,
              decoration: InputDecoration(
                hintText: '记录这次活动的灵感或亮点...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '地点',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: '例如：城北城市绿地',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '标签',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _tagSuggestions
                  .map(
                    (tag) => FilterChip(
                      label: Text(tag),
                      selected: _selectedTags.contains(tag),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存修改'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _showPreviewMessage('请先填写瞬间描述');
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _showPreviewMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }
}
