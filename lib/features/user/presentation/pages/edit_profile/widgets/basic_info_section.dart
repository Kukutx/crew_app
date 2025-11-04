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
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: loc.preferences_display_name_label,
              hintText: loc.preferences_display_name_placeholder,
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.preferences_gender_label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
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
                      Text(
                        _genderLabel(loc, option),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                  selected: gender == option,
                  onSelected: (_) => onGenderChanged(option),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
          if (gender == Gender.custom) ...[
            const SizedBox(height: 16),
            TextField(
              controller: customGenderController,
              onChanged: (value) {
                onCustomGenderChanged(value);
                onFieldChanged();
              },
              maxLength: 24,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                labelText: loc.preferences_gender_custom_field_label,
                hintText: loc.preferences_gender_custom_field_hint,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  letterSpacing: 0,
                ),
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: countryCode,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: loc.preferences_country_label,
              helperText: loc.preferences_country_hint,
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
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
          const SizedBox(height: 16),
          TextField(
            controller: birthdayController,
            readOnly: true,
            showCursor: false,
            onTap: onBirthdayTap,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: '生日',
              hintText: '选择你的生日',
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasBirthday)
                    IconButton(
                      tooltip: '清除',
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: onClearBirthday,
                    ),
                  IconButton(
                    tooltip: '选择生日',
                    icon: const Icon(Icons.cake_outlined, size: 20),
                    onPressed: onBirthdayTap,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: schoolController,
            maxLength: 30,
            onChanged: (_) => onFieldChanged(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: '学校',
              hintText: '填写就读或毕业学校',
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: locationController,
            maxLength: 30,
            onChanged: (_) => onFieldChanged(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: '常驻地区',
              hintText: '例如 广东 · 深圳',
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: bioController,
            maxLines: 4,
            maxLength: maxBioLength,
            onChanged: (_) => onFieldChanged(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: loc.preferences_bio_label,
              hintText: loc.preferences_bio_hint,
              alignLabelWithHint: true,
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
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
