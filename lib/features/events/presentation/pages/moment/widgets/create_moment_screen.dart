import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';

enum MomentType {
  instant,
  event,
}

class CreateMomentScreen extends ConsumerStatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  ConsumerState<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends ConsumerState<CreateMomentScreen> {
  final _commentController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();
  
  MomentType _selectedType = MomentType.instant;
  File? _selectedMedia;
  bool _isVideo = false;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;

  @override
  void dispose() {
    _commentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _isLoadingAddress = true;
    });

    try {
      // 获取当前位置
      final locationCtrl = ref.read(userLocationProvider.notifier);
      final location = await locationCtrl.refreshNow();
      
      if (location == null || !mounted) {
        setState(() {
          _isLoadingLocation = false;
          _isLoadingAddress = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法获取当前位置')),
          );
        }
        return;
      }

      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });

      // 获取地址
      final manager = ref.read(locationSelectionManagerProvider);
      final address = await manager.reverseGeocode(location);
      
      if (mounted) {
        setState(() {
          _locationController.text = address ?? '';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _isLoadingAddress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取位置失败: $e')),
        );
      }
    }
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    try {
      if (isVideo) {
        final picked = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
        if (picked != null && mounted) {
          setState(() {
            _selectedMedia = File(picked.path);
            _isVideo = true;
          });
        }
      } else {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (picked != null && mounted) {
          setState(() {
            _selectedMedia = File(picked.path);
            _isVideo = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择媒体失败: $e')),
        );
      }
    }
  }

  void _showTypeSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flash_on),
              title: const Text('即时瞬间'),
              onTap: () {
                setState(() => _selectedType = MomentType.instant);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('活动瞬间'),
              onTap: () {
                setState(() => _selectedType = MomentType.event);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onCreateMoment() {
    // TODO: 实现创建瞬间逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建瞬间功能开发中')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF2D2D2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TextButton(
          onPressed: _showTypeSelector,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedType == MomentType.instant ? '即时瞬间' : '活动瞬间',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Media placeholder - 现代化的卡片设计
                      GestureDetector(
                        onTap: () {
                          // 显示选择媒体对话框
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.videocam, color: Colors.white),
                                      title: const Text('Video', style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickMedia(isVideo: true);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo, color: Colors.white),
                                      title: const Text('Photo', style: TextStyle(color: Colors.white)),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickMedia(isVideo: false);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _selectedMedia == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.photoVideo,
                                      size: 100,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Add Photo or Video Below.',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : _isVideo
                                  ? const Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.file(
                                        _selectedMedia!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Location input - 现代化的输入框
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: '位置',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                onChanged: (value) {
                                  // 用户可以手动修改地址
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: _isLoadingLocation || _isLoadingAddress
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.location_on_outlined,
                                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      ),
                                      onPressed: _getCurrentLocation,
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Comment input - 现代化的多行输入框
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Comment....',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          maxLines: 5,
                          minLines: 4,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Create Moment button - 固定在底部
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onCreateMoment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Moment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

