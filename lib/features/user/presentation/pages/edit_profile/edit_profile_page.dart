import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/state/user_profile_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  late final TextEditingController _birthdayController;
  late final TextEditingController _schoolController;
  late final TextEditingController _locationController;
  late List<String> _tags;
  String? _countryCode;
  late Gender _gender;
  late String _selectedAvatar;
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _tagInputController = TextEditingController();
    _birthdayController =
        TextEditingController(text: _formatBirthday(profile.birthday));
    _schoolController = TextEditingController(text: profile.school ?? '');
    _locationController = TextEditingController(text: profile.location ?? '');
    _tags = [...profile.tags];
    _countryCode = profile.countryCode;
    _gender = profile.gender;
    _selectedAvatar = profile.avatar;
    _birthday = profile.birthday;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _tagInputController.dispose();
    _birthdayController.dispose();
    _schoolController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSave() {
    final loc = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final school = _schoolController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty) {
      _showSnack(loc.preferences_name_empty_error);
      return;
    }

    final notifier = ref.read(userProfileProvider.notifier);
    notifier.state = notifier.state.copyWith(
      name: name,
      bio: bio.isEmpty ? notifier.state.bio : bio,
      tags: _tags,
      countryCode: _countryCode,
      gender: _gender,
      avatar: _selectedAvatar,
      birthday: _birthday,
      school: school.isEmpty ? null : school,
      location: location.isEmpty ? null : location,
    );

    _showSnack(loc.preferences_save_success);
    Navigator.of(context).maybePop();
  }

  String _formatBirthday(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('yyyy年MM月dd日').format(date);
  }

  Future<void> _pickBirthday() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initialDate = _birthday ?? DateTime(now.year - 20, now.month, now.day);
    final firstDate = DateTime(now.year - 100);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: '选择生日',
      cancelText: '取消',
      confirmText: '确定',
    );

    if (picked != null) {
      setState(() {
        _birthday = picked;
        _birthdayController.text = _formatBirthday(picked);
      });
    }
  }

  void _clearBirthday() {
    setState(() {
      _birthday = null;
      _birthdayController.clear();
    });
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
            final picker = ImagePicker();
            await picker.pickImage(source: ImageSource.gallery);
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
            birthday: _birthday,
            school: _schoolController.text.trim().isEmpty
                ? null
                : _schoolController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            onEditCover: _showComingSoon,
            onEditAvatar: _handleEditAvatar,
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_basic_info_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          BasicInfoSection(
            nameController: _nameController,
            gender: _gender,
            onGenderChanged: (gender) => setState(() {
              _gender = gender;
            }),
            countryCode: _countryCode,
            onCountryChanged: (value) => setState(() {
              _countryCode = value;
            }),
            birthdayController: _birthdayController,
            onBirthdayTap: _pickBirthday,
            onClearBirthday: _clearBirthday,
            hasBirthday: _birthday != null,
            schoolController: _schoolController,
            locationController: _locationController,
            bioController: _bioController,
            onFieldChanged: () => setState(() {}),
            maxBioLength: _maxBioLength,
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_tags_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
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
