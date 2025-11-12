import 'package:crew_app/features/user/data/user.dart';
import 'package:crew_app/shared/utils/country_helper.dart';
import 'package:crew_app/features/user/presentation/widgets/gender_badge.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/state/location_api_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'section_card.dart';

class BasicInfoSection extends ConsumerWidget {
  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.gender,
    required this.onGenderChanged,
    required this.customGenderController,
    required this.onCustomGenderChanged,
    required this.countryCode,
    required this.onCountryChanged,
    required this.selectedCity,
    required this.onCityChanged,
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
  final String? selectedCity;
  final ValueChanged<String?> onCityChanged;
  final TextEditingController bioController;
  final VoidCallback onFieldChanged;
  final int maxBioLength;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    // 使用新的 Location API Provider
    final countriesAsync = ref.watch(countriesProvider);
    final citiesAsync = ref.watch(citiesByCountryCodeProvider(countryCode));

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
          // 国家选择下拉框
          countriesAsync.when(
            data: (countries) => DropdownButtonFormField<String?>(
              initialValue : countryCode,
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
                for (final country in countries)
                  DropdownMenuItem<String?>(
                    value: country.code,
                    child: _CountryMenuLabel(
                      flag: CountryHelper.countryCodeToEmoji(country.code) ?? '',
                      name: country.nameZh ?? country.name,
                    ),
                  ),
              ],
              onChanged: (value) {
                onCountryChanged(value);
                // 国家改变时，清空城市选择
                if (value != countryCode) {
                  onCityChanged(null);
                }
              },
            ),
            loading: () => const SizedBox(
              height: 56,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => DropdownButtonFormField<String?>(
              initialValue : countryCode,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                labelText: loc.preferences_country_label,
                helperText: '加载国家列表失败',
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
                // 降级到硬编码列表
                for (final option in _buildCountryOptions(loc))
                  DropdownMenuItem<String?>(
                    value: option.key,
                    child: _CountryMenuLabel(
                      flag: CountryHelper.countryCodeToEmoji(option.key) ?? '',
                      name: option.value,
                    ),
                  ),
              ],
              onChanged: (value) {
                onCountryChanged(value);
                if (value != countryCode) {
                  onCityChanged(null);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          // 城市选择下拉框
          citiesAsync.when(
            data: (cities) {
              final cityNames = cities.map((c) => c.getDisplayName()).toList();
              final validCityValue = _getValidCityValueFromList(selectedCity, cityNames);
              
              return DropdownButtonFormField<String?>(
                initialValue : validCityValue,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                decoration: InputDecoration(
                  labelText: '城市',
                  helperText: countryCode == null 
                      ? '请先选择国家' 
                      : cities.isEmpty 
                          ? '暂无城市数据' 
                          : null,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      countryCode == null ? '请先选择国家' : '未选择',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final city in cities)
                    DropdownMenuItem<String?>(
                      value: city.getDisplayName(),
                      child: Text(city.getDisplayName()),
                    ),
                ],
                onChanged: countryCode == null ? null : (value) {
                  onCityChanged(value);
                  onFieldChanged();
                },
              );
            },
            loading: () => const SizedBox(
              height: 56,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => DropdownButtonFormField<String?>(
              initialValue : selectedCity,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                labelText: '城市',
                helperText: countryCode == null 
                    ? '请先选择国家' 
                    : '加载城市列表失败',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  letterSpacing: 0,
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    countryCode == null ? '请先选择国家' : '未选择',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              onChanged: null,
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

/// 从城市名称列表中获取有效的城市值
String? _getValidCityValueFromList(String? selectedCity, List<String> cityNames) {
  if (selectedCity == null) {
    return null;
  }
  // 检查 selectedCity 是否在 cityNames 列表中（支持模糊匹配）
  for (final cityName in cityNames) {
    if (cityName == selectedCity || 
        cityName.toLowerCase() == selectedCity.toLowerCase()) {
      return cityName;
    }
  }
  // 如果不在列表中，返回 null（避免 DropdownButton 错误）
  return null;
}

List<MapEntry<String, String>> _buildCountryOptions(AppLocalizations loc) => [
      MapEntry('CN', loc.country_name_china),
      MapEntry('US', loc.country_name_united_states),
      MapEntry('JP', loc.country_name_japan),
      MapEntry('KR', loc.country_name_korea),
      MapEntry('GB', loc.country_name_united_kingdom),
      MapEntry('AU', loc.country_name_australia),
    ];
