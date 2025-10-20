import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/user_profile/state/user_profile_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late List<String> _tags;
  String? _countryCode;
  late Gender _gender;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _tagInputController = TextEditingController();
    _tags = [...profile.tags];
    _countryCode = profile.countryCode;
    _gender = profile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _tagInputController.dispose();
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
    );

    _showSnack(loc.preferences_save_success);
    Navigator.of(context).maybePop();
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
          _ProfilePreview(
            coverUrl: profile.cover,
            avatarUrl: profile.avatar,
            displayName: _nameController.text.trim().isEmpty
                ? loc.preferences_display_name_placeholder
                : _nameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? loc.preferences_bio_placeholder
                : _bioController.text.trim(),
            tags: _tags,
            countryCode: _countryCode ?? profile.countryCode,
            gender: _gender,
            onEditCover: _showComingSoon,
            onEditAvatar: _showComingSoon,
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_basic_info_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            maxLength: 24,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: loc.preferences_display_name_label,
              hintText: loc.preferences_display_name_placeholder,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.preferences_gender_label,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final gender in Gender.values)
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GenderBadge(gender: gender, size: 22),
                      const SizedBox(width: 8),
                      Text(_genderLabel(loc, gender)),
                    ],
                  ),
                  selected: _gender == gender,
                  onSelected: (_) {
                    setState(() {
                      _gender = gender;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _countryCode,
            decoration: InputDecoration(
              labelText: loc.preferences_country_label,
              helperText: loc.preferences_country_hint,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(loc.preferences_country_unset),
              ),
              for (final option in _buildCountryOptions(loc))
                DropdownMenuItem<String?>(
                  value: option.key,
                  child: _CountryMenuLabel(
                    flag: countryCodeToEmoji(option.key) ?? '',
                    name: option.value,
                  ),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _countryCode = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 4,
            maxLength: _maxBioLength,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: loc.preferences_bio_label,
              hintText: loc.preferences_bio_hint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.preferences_tags_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (_tags.isEmpty)
            Text(
              loc.preferences_tags_empty_helper,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () => _handleRemoveTag(tag),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagInputController,
            onSubmitted: (_) => _handleAddTag(),
            decoration: InputDecoration(
              labelText: loc.preferences_add_tag_label,
              hintText: loc.preferences_tag_input_hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _handleAddTag,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.preferences_recommended_tags_title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _suggestedTags)
                FilterChip(
                  label: Text(tag),
                  selected: _tags.contains(tag),
                  onSelected: (_) => _handleSuggestedTag(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

List<MapEntry<String, String>> _buildCountryOptions(AppLocalizations loc) => [
      MapEntry('CN', loc.country_name_china),
      MapEntry('US', loc.country_name_united_states),
      MapEntry('JP', loc.country_name_japan),
      MapEntry('KR', loc.country_name_korea),
      MapEntry('GB', loc.country_name_united_kingdom),
      MapEntry('AU', loc.country_name_australia),
    ];

class _CountryMenuLabel extends StatelessWidget {
  const _CountryMenuLabel({required this.flag, required this.name});

  final String flag;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (flag.isNotEmpty) ...[
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
        ],
        Text(name),
      ],
    );
  }
}

class _ProfilePreview extends StatelessWidget {
  const _ProfilePreview({
    required this.coverUrl,
    required this.avatarUrl,
    required this.displayName,
    required this.bio,
    required this.tags,
    required this.countryCode,
    required this.gender,
    required this.onEditCover,
    required this.onEditAvatar,
  });

  final String coverUrl;
  final String avatarUrl;
  final String displayName;
  final String bio;
  final List<String> tags;
  final String? countryCode;
  final Gender gender;
  final VoidCallback onEditCover;
  final VoidCallback onEditAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;
    final flagEmoji = countryCodeToEmoji(countryCode);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FilledButton.tonalIcon(
                onPressed: onEditCover,
                icon: const Icon(Icons.photo_outlined),
                label: Text(loc.preferences_cover_action),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Semantics(
                        button: true,
                        label: loc.preferences_avatar_action,
                        child: GestureDetector(
                          onTap: onEditAvatar,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: CachedNetworkImageProvider(avatarUrl),
                          ),
                        ),
                      ),
                      if (flagEmoji != null)
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Text(
                              flagEmoji,
                              style: const TextStyle(
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Material(
                          shape: const CircleBorder(),
                          color: theme.colorScheme.primary,
                          child: InkWell(
                            onTap: onEditAvatar,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (gender.shouldDisplay) ...[
                              const SizedBox(width: 8),
                              GenderBadge(gender: gender, size: 26),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final tag in tags)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    tag,
                                    style: textTheme.labelMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _genderLabel(AppLocalizations loc, Gender gender) {
  switch (gender) {
    case Gender.female:
      return loc.preferences_gender_female;
    case Gender.male:
      return loc.preferences_gender_male;
    case Gender.undisclosed:
      return loc.preferences_gender_other;
  }
}
