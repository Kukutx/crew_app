import 'dart:math' as math;

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
  late final PageController _pageController;

  late List<String> _mediaAssets;
  late List<String> _availableMediaAssets;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedTags = widget.post.tags.toSet();
    _mediaAssets = widget.post.mediaAssets.toList();
    _availableMediaAssets = {
      ...widget.post.mediaAssets,
      'assets/images/crew.png',
      'assets/images/Image_20250917233011_307_216.png',
      'assets/images/icons/app_icon.png',
      'assets/images/icons/logo.png',
    }.toList()
      ..sort();
    _pageController = PageController();
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaAssets = _mediaAssets;

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
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: mediaAssets.isNotEmpty
                    ? Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: mediaAssets.length,
                            itemBuilder: (context, index) {
                              final asset = mediaAssets[index];
                              return Image.asset(
                                asset,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          if (mediaAssets.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < mediaAssets.length; i++)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: 6,
                                      width: _currentImageIndex == i ? 16 : 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: colorScheme.surfaceVariant,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.photo_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            if (mediaAssets.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final asset = mediaAssets[index];
                    final isSelected = index == _currentImageIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Container(
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          asset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: mediaAssets.length,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _openImagePicker,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('添加图片'),
                ),
                if (mediaAssets.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed:
                        mediaAssets.length > 1 ? _setCurrentImageAsCover : null,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('设为封面'),
                  ),
                if (mediaAssets.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _removeCurrentImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('移除当前图片'),
                  ),
              ],
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

  Future<void> _openImagePicker() async {
    final options = _availableMediaAssets;
    final hasNewImage =
        options.any((asset) => !_mediaAssets.contains(asset));
    if (!hasNewImage) {
      _showPreviewMessage('暂无更多可选图片');
      return;
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final maxHeight = math.min(
          MediaQuery.of(context).size.height * 0.6,
          160 + options.length * 92,
        );
        return SafeArea(
          child: SizedBox(
            height: maxHeight,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '选择图片',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final asset = options[index];
                      final alreadyAdded = _mediaAssets.contains(asset);
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            asset,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(asset.split('/').last),
                        trailing: alreadyAdded
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        enabled: !alreadyAdded,
                        onTap: alreadyAdded
                            ? null
                            : () {
                                Navigator.of(context).pop(asset);
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }
    if (_mediaAssets.contains(selected)) {
      _showPreviewMessage('该图片已添加');
      return;
    }
    setState(() {
      _mediaAssets.add(selected);
      _currentImageIndex = _mediaAssets.length - 1;
    });
    await Future<void>.delayed(Duration.zero);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    _showPreviewMessage('已添加新的图片');
  }

  void _setCurrentImageAsCover() {
    if (_mediaAssets.isEmpty || _currentImageIndex == 0) {
      _showPreviewMessage('这已经是封面图片');
      return;
    }
    setState(() {
      final asset = _mediaAssets.removeAt(_currentImageIndex);
      _mediaAssets.insert(0, asset);
      _currentImageIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _showPreviewMessage('封面已更新');
  }

  void _removeCurrentImage() {
    if (_mediaAssets.isEmpty) {
      _showPreviewMessage('当前没有可移除的图片');
      return;
    }
    final removedAsset = _mediaAssets[_currentImageIndex];
    setState(() {
      _mediaAssets.removeAt(_currentImageIndex);
      if (_mediaAssets.isEmpty) {
        _currentImageIndex = 0;
      } else {
        if (_currentImageIndex >= _mediaAssets.length) {
          _currentImageIndex = _mediaAssets.length - 1;
        }
      }
    });
    if (_mediaAssets.isNotEmpty && _pageController.hasClients) {
      _pageController.animateToPage(
        _currentImageIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    _showPreviewMessage('已移除图片：${removedAsset.split('/').last}');
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
