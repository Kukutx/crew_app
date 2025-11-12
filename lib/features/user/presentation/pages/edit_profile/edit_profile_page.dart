import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/providers/api_provider_helper.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/state/user_profile_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/state/country_city_providers.dart';
import 'package:crew_app/shared/utils/media_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/avatar_preview_overlay.dart';
import 'widgets/basic_info_section.dart';
import 'widgets/profile_preview_section.dart';
import 'widgets/tag_section.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  static const _maxBioLength = 120;
  static const _maxTagCount = 6;
  static const List<String> _suggestedTags = [
    '露营玩家',
    '摄影控',
    '旅拍达人',
    '户外探索',
    '城市漫游',
    '活动策划',
    '美食打卡',
    '运动能量',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _tagInputController;
  late final TextEditingController _customGenderController;
  late List<String> _tags;
  String? _countryCode;
  String? _selectedCity;
  late Gender _gender;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _tagInputController = TextEditingController();
    _customGenderController =
        TextEditingController(text: profile.customGender ?? '');
    _tags = [...profile.tags];
    _countryCode = profile.countryCode;
    _selectedCity = profile.city;
    _gender = profile.gender;
    _selectedAvatar = profile.avatar;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _tagInputController.dispose();
    _customGenderController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSave() async {
    final loc = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final customGenderText = _customGenderController.text.trim();
    final customGender =
        _gender == Gender.custom && customGenderText.isNotEmpty
            ? customGenderText
            : null;

    if (name.isEmpty) {
      _showSnack(loc.preferences_name_empty_error);
      return;
    }

    // 显示加载状态
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            const Text('保存中...'),
          ],
        ),
        duration: const Duration(seconds: 30), // 设置较长的超时时间
      ),
    );

    try {
      // 调用 API 更新用户资料
      await ApiProviderHelper.callApi(
        ref,
        (api) => api.updateUserProfile(
          displayName: name,
          bio: bio.isEmpty ? null : bio,
          avatarUrl: _selectedAvatar,
          gender: _gender.name, // 转换为字符串：female, male, custom, undisclosed
          customGender: customGender,
          city: _selectedCity,
          countryCode: _countryCode,
          tags: _tags,
        ),
      );

      // 更新本地状态
      final notifier = ref.read(userProfileProvider.notifier);
      notifier.state = notifier.state.copyWith(
        name: name,
        bio: bio.isEmpty ? notifier.state.bio : bio,
        tags: _tags,
        countryCode: _countryCode,
        gender: _gender,
        customGender: customGender,
        avatar: _selectedAvatar,
        city: _selectedCity,
      );

      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(loc.preferences_save_success)));
      
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('保存失败：${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
    }
  }

  void _handleAddTag() {
    final loc = AppLocalizations.of(context)!;
    final tag = _tagInputController.text.trim();
    if (tag.isEmpty) {
      return;
    }

    if (_tags.contains(tag)) {
      _showSnack(loc.preferences_tag_duplicate);
      return;
    }

    if (_tags.length >= _maxTagCount) {
      _showSnack(loc.preferences_tag_limit_reached(_maxTagCount));
      return;
    }

    setState(() {
      _tags = [..._tags, tag];
      _tagInputController.clear();
    });
  }

  void _handleRemoveTag(String tag) {
    setState(() {
      _tags = _tags.where((it) => it != tag).toList();
    });
  }

  void _handleSuggestedTag(String tag) {
    if (_tags.contains(tag)) {
      _handleRemoveTag(tag);
      return;
    }

    _tagInputController.text = tag;
    _handleAddTag();
  }

  void _showComingSoon() {
    final loc = AppLocalizations.of(context)!;
    _showSnack(loc.preferences_feature_unavailable);
  }

  Future<void> _handleEditAvatar() async {
    final loc = AppLocalizations.of(context)!;
    if (!mounted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: .75),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return AvatarPreviewOverlay(
          imageUrl: _selectedAvatar,
          changeLabel: loc.preferences_avatar_action,
          onCancel: () => Navigator.of(dialogContext).maybePop(),
          onChange: () async {
            // 使用头像配置（自动裁剪为圆形）
            final file = await MediaPickerHelper.pickImage(
              config: MediaPickerConfig.avatar,
            );
            
            if (file != null) {
              // TODO: 上传头像到服务器
              debugPrint('Selected avatar: ${file.path}');
              // 这里可以调用上传 API
            }
            
            if (!mounted) return;
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).maybePop();
            }
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.preferences_title),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text(MaterialLocalizations.of(context).saveButtonLabel),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          ProfilePreviewSection(
            coverUrl: profile.cover,
            avatarUrl: _selectedAvatar,
            displayName: _nameController.text.trim().isEmpty
                ? loc.preferences_display_name_placeholder
                : _nameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? loc.preferences_bio_placeholder
                : _bioController.text.trim(),
            tags: _tags,
            countryCode: _countryCode ?? profile.countryCode,
            gender: _gender,
            customGender: _gender == Gender.custom
                ? (_customGenderController.text.trim().isEmpty
                    ? null
                    : _customGenderController.text.trim())
                : null,
            city: _selectedCity,
            onEditCover: _showComingSoon,
            onEditAvatar: _handleEditAvatar,
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_basic_info_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          BasicInfoSection(
            nameController: _nameController,
            gender: _gender,
            onGenderChanged: (gender) => setState(() {
              _gender = gender;
            }),
            customGenderController: _customGenderController,
            onCustomGenderChanged: (_) => setState(() {}),
            countryCode: _countryCode,
            onCountryChanged: (value) {
              setState(() {
                _countryCode = value;
                // 国家改变时，检查当前城市是否在新国家的城市列表中
                if (value != null && _selectedCity != null) {
                  // 使用 ref.read 获取城市列表（不触发 watch）
                  final cities = ref.read(citiesByCountryProvider(value));
                  // 如果当前城市不在新国家的城市列表中，清空城市选择
                  if (!cities.contains(_selectedCity)) {
                    _selectedCity = null;
                  }
                } else {
                  // 如果国家为空，清空城市选择
                  _selectedCity = null;
                }
              });
            },
            selectedCity: _selectedCity,
            onCityChanged: (value) => setState(() {
              _selectedCity = value;
            }),
            bioController: _bioController,
            onFieldChanged: () => setState(() {}),
            maxBioLength: _maxBioLength,
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_tags_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 16),
          TagSection(
            tags: _tags,
            tagInputController: _tagInputController,
            onAddTag: _handleAddTag,
            onRemoveTag: _handleRemoveTag,
            onSuggestedTag: _handleSuggestedTag,
            suggestedTags: _suggestedTags,
          ),
        ],
      ),
    );
  }
}
