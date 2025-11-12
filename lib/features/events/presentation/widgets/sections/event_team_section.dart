import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/shared/widgets/cards/section_card.dart';

class EventTeamSection extends StatelessWidget {
  const EventTeamSection({
    super.key,
    required this.maxMembers,
    required this.onMaxMembersChanged,
    required this.price,
    required this.onPriceChanged,
    required this.pricingType,
    required this.onPricingTypeChanged,
    required this.tagInputController,
    required this.onSubmitTag,
    required this.tags,
    required this.onRemoveTag,
  });

  final int maxMembers;
  final ValueChanged<int> onMaxMembersChanged;
  final double? price;
  final ValueChanged<double?> onPriceChanged;
  final EventPricingType pricingType;
  final ValueChanged<EventPricingType> onPricingTypeChanged;
  final TextEditingController tagInputController;
  final VoidCallback onSubmitTag;
  final List<String> tags;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SectionCard(
      icon: Icons.groups_3_outlined,
      title: loc.road_trip_team_section_title,
      subtitle: loc.road_trip_team_section_subtitle,
      headerTrailing: SegmentedButton<EventPricingType>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: EventPricingType.free,
            label: Text(
              loc.road_trip_team_pricing_free,
              style: TextStyle(fontSize: 13.sp),
            ),
            icon: Icon(Icons.favorite_outline, size: 18.sp),
          ),
          ButtonSegment(
            value: EventPricingType.paid,
            label: Text(
              loc.road_trip_team_pricing_paid,
              style: TextStyle(fontSize: 13.sp),
            ),
            icon: Icon(Icons.payments_outlined, size: 18.sp),
          ),
        ],
        selected: {pricingType},
        onSelectionChanged: (value) => onPricingTypeChanged(value.first),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _MaxMembersInputField(
                maxMembers: maxMembers,
                onMaxMembersChanged: onMaxMembersChanged,
                label: loc.road_trip_team_max_members_label,
                hint: loc.road_trip_team_max_members_hint,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _PriceInputField(
                price: price,
                onPriceChanged: onPriceChanged,
                pricingType: pricingType,
                label: loc.road_trip_team_price_label,
                freeHint: loc.road_trip_team_price_free_hint,
                paidHint: loc.road_trip_team_price_paid_hint,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignTokens.spacingLG.h),
        TextField(
          controller: tagInputController,
          style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
          decoration: getInputDecoration(
            context,
            loc.road_trip_preferences_tag_label,
            loc.road_trip_preferences_tag_hint,
          ).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onSubmitTag,
            ),
          ),
          maxLength: 20,
          onSubmitted: (_) => onSubmitTag(),
        ),
        if (tags.isNotEmpty) ...[
          SizedBox(height: AppDesignTokens.spacingMD.h),
          Wrap(
            spacing: AppDesignTokens.spacingSM.w,
            runSpacing: AppDesignTokens.spacingSM.h,
            children: tags
              .map(
                (t) => Chip(
                  label: Text(
                    '#$t',
                    style: TextStyle(fontSize: AppDesignTokens.fontSizeSM.sp),
                  ),
                  deleteIcon: Icon(Icons.close, size: AppDesignTokens.iconSizeXS.sp),
                  onDeleted: () => onRemoveTag(t),
                  labelStyle: TextStyle(fontSize: AppDesignTokens.fontSizeSM.sp),
                ),
              )
              .toList(),
          ),
        ],
      ],
    );
  }
}

class _MaxMembersInputField extends StatefulWidget {
  const _MaxMembersInputField({
    required this.maxMembers,
    required this.onMaxMembersChanged,
    required this.label,
    required this.hint,
  });

  final int maxMembers;
  final ValueChanged<int> onMaxMembersChanged;
  final String label;
  final String hint;

  @override
  State<_MaxMembersInputField> createState() => _MaxMembersInputFieldState();
}

class _MaxMembersInputFieldState extends State<_MaxMembersInputField> {
  final TextEditingController _controller = TextEditingController();
  static const List<int> _presetValues = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.maxMembers.toString();
  }

  @override
  void didUpdateWidget(_MaxMembersInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxMembers != widget.maxMembers) {
      final currentText = _controller.text;
      final newText = widget.maxMembers.toString();
      if (currentText != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPresetValue(int value) {
    _controller.text = value.toString();
    widget.onMaxMembersChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
      decoration: getInputDecoration(
        context,
        widget.label,
        widget.hint,
      ).copyWith(
        suffixIcon: PopupMenuButton<int>(
          icon: Icon(Icons.add, size: 18.sp),
          tooltip: '预设人数',
          itemBuilder: (context) => _presetValues
              .map((value) => PopupMenuItem<int>(
                    value: value,
                    child: Text('$value'),
                  ))
              .toList(),
          onSelected: _applyPresetValue,
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isEmpty) {
          return;
        }
        final members = int.tryParse(value);
        if (members != null) {
          // 验证：不能超过7
          if (members > 7) {
            // 限制为7
            _controller.value = TextEditingValue(
              text: '7',
              selection: TextSelection.collapsed(offset: 1),
            );
            widget.onMaxMembersChanged(7);
          } else if (members < 1) {
            // 不能小于1
            _controller.value = TextEditingValue(
              text: '1',
              selection: TextSelection.collapsed(offset: 1),
            );
            widget.onMaxMembersChanged(1);
          } else {
            widget.onMaxMembersChanged(members);
          }
        }
      },
    );
  }
}

class _PriceInputField extends StatefulWidget {
  const _PriceInputField({
    required this.price,
    required this.onPriceChanged,
    required this.pricingType,
    required this.label,
    required this.freeHint,
    required this.paidHint,
  });

  final double? price;
  final ValueChanged<double?> onPriceChanged;
  final EventPricingType pricingType;
  final String label;
  final String freeHint;
  final String paidHint;

  @override
  State<_PriceInputField> createState() => _PriceInputFieldState();
}

class _PriceInputFieldState extends State<_PriceInputField> {
  final TextEditingController _priceController = TextEditingController();
  static const List<double> _presetPrices = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    if (widget.price != null) {
      _priceController.text = widget.price!.toInt().toString();
    }
  }

  @override
  void didUpdateWidget(_PriceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在收费模式下更新 controller
    if (widget.pricingType == EventPricingType.paid) {
      if (oldWidget.price != widget.price) {
        if (widget.price != null) {
          final currentText = _priceController.text;
          final newText = widget.price!.toInt().toString();
          if (currentText != newText) {
            _priceController.text = newText;
          }
        } else {
          _priceController.clear();
        }
      }
    } else {
      // 切换到免费模式时，清空 controller
      if (oldWidget.pricingType != widget.pricingType) {
        _priceController.clear();
      }
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _applyPresetPrice(double price) {
    _priceController.text = price.toInt().toString();
    widget.onPriceChanged(price);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pricingType == EventPricingType.free) {
      final loc = AppLocalizations.of(context)!;
      final colorScheme = Theme.of(context).colorScheme;
      return TextFormField(
        key: const ValueKey('free_price_input'),
        enabled: false,
        initialValue: loc.road_trip_team_pricing_free,
        style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
        decoration: getInputDecoration(
          context,
          widget.label,
          widget.freeHint,
        ).copyWith(
          // 添加空的 suffixIcon 以保持样式一致
          suffixIcon: SizedBox(width: 48.w, height: 48.h),
          // 确保禁用状态下的边框样式一致
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: AppDesignTokens.borderWidthThin,
            ),
          ),
        ),
      );
    }

    return TextFormField(
      key: const ValueKey('paid_price_input'),
      controller: _priceController,
      style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
      decoration: getInputDecoration(
        context,
        widget.label,
        widget.paidHint,
      ).copyWith(
        suffixIcon: PopupMenuButton<double>(
          icon: Icon(Icons.add, size: 18.sp),
          tooltip: '预设价格',
          itemBuilder: (context) => _presetPrices
              .map((price) => PopupMenuItem<double>(
                    value: price,
                    child: Text('€${price.toInt()}'),
                  ))
              .toList(),
          onSelected: _applyPresetPrice,
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (value.isEmpty) {
          widget.onPriceChanged(null);
          return;
        }
        final price = int.tryParse(value);
        if (price != null) {
          // 验证：不能超过100
          if (price > 100) {
            // 限制为100
            _priceController.value = TextEditingValue(
              text: '100',
              selection: TextSelection.collapsed(offset: 3),
            );
            widget.onPriceChanged(100);
          } else {
            widget.onPriceChanged(price.toDouble());
          }
        } else {
          widget.onPriceChanged(null);
        }
      },
    );
  }
}

