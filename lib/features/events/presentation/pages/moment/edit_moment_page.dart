import 'dart:typed_data';

import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/moment_post_card.dart';

class EditMomentPage extends StatefulWidget {
  const EditMomentPage({super.key, required this.post});

  final MomentPost post;

  static MaterialPageRoute<bool> route({required MomentPost post}) {
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

  late List<_MomentImage> _mediaAssets;
  int _currentImageIndex = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
    _locationController = TextEditingController(text: widget.post.location);
    _selectedTags = widget.post.tags.toSet();
    _mediaAssets = widget.post.mediaAssets
        .map((asset) => _MomentImage.asset(asset))
        .toList();
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
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
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
                              return asset.build(
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          if (mediaAssets.length > 1)
                            Positioned(
                              bottom: 12.h,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < mediaAssets.length; i++)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                                      height: 6.h,
                                      width: _currentImageIndex == i ? 16.w : 6.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(3.r),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.photo_outlined,
                          size: 48.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            if (mediaAssets.isNotEmpty) ...[
              SizedBox(height: 12.h),
              SizedBox(
                height: 78.h,
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
                        width: 72.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: asset.build(
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemCount: mediaAssets.length,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
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
            SizedBox(height: 12.h),
            Text(
              '瞬间描述',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              minLines: 4,
              maxLines: 6,
              maxLength: 240,
              decoration: InputDecoration(
                hintText: '记录这次活动的灵感或亮点...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '地点',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: '例如：城北城市绿地',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '标签',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
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
            SizedBox(height: 28.h),
            FilledButton(
              onPressed: _handleSubmit,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
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
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) {
      _showPreviewMessage('未选择任何图片');
      return;
    }

    final newImages = <_MomentImage>[];
    for (final file in pickedFiles) {
      final bytes = await file.readAsBytes();
      newImages.add(
        _MomentImage.memory(
          bytes: bytes,
          name: file.name,
        ),
      );
    }

    if (newImages.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _mediaAssets.addAll(newImages);
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

    _showPreviewMessage('已添加${newImages.length}张图片');
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
    _showPreviewMessage('已移除图片：${removedAsset.displayName}');
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

class _MomentImage {
  const _MomentImage._({this.assetPath, this.bytes, required this.name});

  factory _MomentImage.asset(String assetPath) {
    return _MomentImage._(
      assetPath: assetPath,
      name: assetPath.split('/').last,
    );
  }

  factory _MomentImage.memory({required Uint8List bytes, required String name}) {
    return _MomentImage._(
      bytes: bytes,
      name: name,
    );
  }

  final String? assetPath;
  final Uint8List? bytes;
  final String name;

  String get displayName => name;

  Widget build({BoxFit fit = BoxFit.cover}) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        fit: fit,
      );
    }
    return Image.memory(
      bytes!,
      fit: fit,
    );
  }
}

