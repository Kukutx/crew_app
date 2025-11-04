import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
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

  void _onCreateStory() {
    // TODO: 实现创建故事逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建故事功能开发中')),
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _showTypeSelector,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedType == MomentType.instant ? '即时瞬间' : '活动瞬间',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // AI/Brain icon placeholder
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.psychology_outlined, color: Colors.white),
              onPressed: () {
                // TODO: AI功能
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Media placeholder
                GestureDetector(
                  onTap: () => _pickMedia(isVideo: false),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _selectedMedia == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_size_select_actual_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Add Photo or Video Below.',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : _isVideo
                            ? const Center(
                                child: Icon(
                                  Icons.play_circle_filled,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              )
                            : Image.file(
                                _selectedMedia!,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                const SizedBox(height: 24),
                // Location input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '位置',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          // 用户可以手动修改地址
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isLoadingLocation || _isLoadingAddress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.location_on, color: Colors.white),
                      onPressed: _isLoadingLocation || _isLoadingAddress
                          ? null
                          : _getCurrentLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Comment input
                TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Comment....',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                // Action buttons
                Row(
                  children: [
                    // Video button
                    Expanded(
                      child: _MediaTypeButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () => _pickMedia(isVideo: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Photo button
                    Expanded(
                      child: _MediaTypeButton(
                        icon: Icons.photo,
                        label: 'Photo',
                        onTap: () => _pickMedia(isVideo: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Create Story button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _onCreateStory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Create Story',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaTypeButton extends StatelessWidget {
  const _MediaTypeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

