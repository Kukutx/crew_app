import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'section_card.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.gender,
    required this.onGenderChanged,
    required this.customGenderController,
    required this.onCustomGenderChanged,
    required this.countryCode,
    required this.onCountryChanged,
    required this.birthdayController,
    required this.onBirthdayTap,
    required this.onClearBirthday,
    required this.hasBirthday,
    required this.schoolController,
    required this.locationController,
    required this.bioController,
    required this.onFieldChanged,
    required this.maxBioLength,
  });

  final TextEditingController nameController;
  final Gender gender;
  final ValueChanged<Gender> onGenderChanged;
  final TextEditingController customGenderController;
  final ValueChanged<String> onCustomGenderChanged;
  final String? countryCode;
  final ValueChanged<String?> onCountryChanged;
  final TextEditingController birthdayController;
  final VoidCallback onBirthdayTap;
  final VoidCallback onClearBirthday;
  final bool hasBirthday;
  final TextEditingController schoolController;
  final TextEditingController locationController;
  final TextEditingController bioController;
  final VoidCallback onFieldChanged;
  final int maxBioLength;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            maxLength: 24,
            onChanged: (_) => onFieldChanged(),
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
              for (final option in Gender.values)
                ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GenderBadge(gender: option, size: 22),
                      const SizedBox(width: 8),
                      Text(_genderLabel(loc, option)),
                    ],
                  ),
                  selected: gender == option,
                  onSelected: (_) => onGenderChanged(option),
                ),
            ],
          ),
          if (gender == Gender.custom) ...[
            const SizedBox(height: 12),
            TextField(
              controller: customGenderController,
              onChanged: (value) {
                onCustomGenderChanged(value);
                onFieldChanged();
              },
              maxLength: 24,
              decoration: InputDecoration(
                labelText: loc.preferences_gender_custom_field_label,
                hintText: loc.preferences_gender_custom_field_hint,
              ),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: countryCode,
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
            onChanged: onCountryChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: birthdayController,
            readOnly: true,
            showCursor: false,
            onTap: onBirthdayTap,
            decoration: InputDecoration(
              labelText: '生日',
              hintText: '选择你的生日',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasBirthday)
                    IconButton(
                      tooltip: '清除',
                      icon: const Icon(Icons.close),
                      onPressed: onClearBirthday,
                    ),
                  IconButton(
                    tooltip: '选择生日',
                    icon: const Icon(Icons.cake_outlined),
                    onPressed: onBirthdayTap,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: schoolController,
            maxLength: 30,
            onChanged: (_) => onFieldChanged(),
            decoration: const InputDecoration(
              labelText: '学校',
              hintText: '填写就读或毕业学校',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: locationController,
            maxLength: 30,
            onChanged: (_) => onFieldChanged(),
            decoration: const InputDecoration(
              labelText: '常驻地区',
              hintText: '例如 广东 · 深圳',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bioController,
            maxLines: 4,
            maxLength: maxBioLength,
            onChanged: (_) => onFieldChanged(),
            decoration: InputDecoration(
              labelText: loc.preferences_bio_label,
              hintText: loc.preferences_bio_hint,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

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

String _genderLabel(AppLocalizations loc, Gender gender) {
  switch (gender) {
    case Gender.female:
      return loc.preferences_gender_female;
    case Gender.male:
      return loc.preferences_gender_male;
    case Gender.custom:
      return loc.preferences_gender_custom;
    case Gender.undisclosed:
      return loc.preferences_gender_other;
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
