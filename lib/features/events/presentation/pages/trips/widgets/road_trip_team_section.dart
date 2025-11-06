import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/road_trip_editor_models.dart';
import 'road_trip_section_card.dart';

class RoadTripTeamSection extends StatelessWidget {
  const RoadTripTeamSection({
    super.key,
    required this.maxParticipants,
    required this.onMaxParticipantsChanged,
    required this.price,
    required this.onPriceChanged,
    required this.pricingType,
    required this.onPricingTypeChanged,
    required this.tagInputController,
    required this.onSubmitTag,
    required this.tags,
    required this.onRemoveTag,
  });

  final int maxParticipants;
  final ValueChanged<int> onMaxParticipantsChanged;
  final double? price;
  final ValueChanged<double?> onPriceChanged;
  final RoadTripPricingType pricingType;
  final ValueChanged<RoadTripPricingType> onPricingTypeChanged;
  final TextEditingController tagInputController;
  final VoidCallback onSubmitTag;
  final List<String> tags;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.groups_3_outlined,
      title: loc.road_trip_team_section_title,
      subtitle: loc.road_trip_team_section_subtitle,
      headerTrailing: SegmentedButton<RoadTripPricingType>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: RoadTripPricingType.free,
            label: Text(
              loc.road_trip_team_pricing_free,
              style: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.favorite_outline, size: 18),
          ),
          ButtonSegment(
            value: RoadTripPricingType.paid,
            label: Text(
              loc.road_trip_team_pricing_paid,
              style: const TextStyle(fontSize: 13),
            ),
            icon: const Icon(Icons.payments_outlined, size: 18),
          ),
        ],
        selected: {pricingType},
        onSelectionChanged: (value) => onPricingTypeChanged(value.first),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _MaxParticipantsInputField(
                maxParticipants: maxParticipants,
                onMaxParticipantsChanged: onMaxParticipantsChanged,
                label: loc.road_trip_team_max_participants_label,
                hint: loc.road_trip_team_max_participants_hint,
              ),
            ),
            const SizedBox(width: 10),
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
        const SizedBox(height: 16),
        TextField(
          controller: tagInputController,
          style: const TextStyle(fontSize: 14),
          decoration: roadTripInputDecoration(
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
              .map(
                (t) => Chip(
                  label: Text(
                    '#$t',
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onRemoveTag(t),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              )
              .toList(),
          ),
        ],
      ],
    );
  }
}

class _MaxParticipantsInputField extends StatefulWidget {
  const _MaxParticipantsInputField({
    required this.maxParticipants,
    required this.onMaxParticipantsChanged,
    required this.label,
    required this.hint,
  });

  final int maxParticipants;
  final ValueChanged<int> onMaxParticipantsChanged;
  final String label;
  final String hint;

  @override
  State<_MaxParticipantsInputField> createState() => _MaxParticipantsInputFieldState();
}

class _MaxParticipantsInputFieldState extends State<_MaxParticipantsInputField> {
  final TextEditingController _controller = TextEditingController();
  static const List<int> _presetValues = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.maxParticipants.toString();
  }

  @override
  void didUpdateWidget(_MaxParticipantsInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxParticipants != widget.maxParticipants) {
      final currentText = _controller.text;
      final newText = widget.maxParticipants.toString();
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
    widget.onMaxParticipantsChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      style: const TextStyle(fontSize: 14),
      decoration: roadTripInputDecoration(
        context,
        widget.label,
        widget.hint,
      ).copyWith(
        suffixIcon: PopupMenuButton<int>(
          icon: const Icon(Icons.add, size: 18),
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
        final participants = int.tryParse(value);
        if (participants != null) {
          // 验证：不能超过7
          if (participants > 7) {
            // 限制为7
            _controller.value = TextEditingValue(
              text: '7',
              selection: TextSelection.collapsed(offset: 1),
            );
            widget.onMaxParticipantsChanged(7);
          } else if (participants < 1) {
            // 不能小于1
            _controller.value = TextEditingValue(
              text: '1',
              selection: TextSelection.collapsed(offset: 1),
            );
            widget.onMaxParticipantsChanged(1);
          } else {
            widget.onMaxParticipantsChanged(participants);
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
  final RoadTripPricingType pricingType;
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
    if (widget.pricingType == RoadTripPricingType.paid) {
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
    if (widget.pricingType == RoadTripPricingType.free) {
      final loc = AppLocalizations.of(context)!;
      final colorScheme = Theme.of(context).colorScheme;
      return TextFormField(
        key: const ValueKey('free_price_input'),
        enabled: false,
        initialValue: loc.road_trip_team_pricing_free,
        style: const TextStyle(fontSize: 14),
        decoration: roadTripInputDecoration(
          context,
          widget.label,
          widget.freeHint,
        ).copyWith(
          // 添加空的 suffixIcon 以保持样式一致
          suffixIcon: const SizedBox(width: 48, height: 48),
          // 确保禁用状态下的边框样式一致
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
      );
    }

    return TextFormField(
      key: const ValueKey('paid_price_input'),
      controller: _priceController,
      style: const TextStyle(fontSize: 14),
      decoration: roadTripInputDecoration(
        context,
        widget.label,
        widget.paidHint,
      ).copyWith(
        suffixIcon: PopupMenuButton<double>(
          icon: const Icon(Icons.add, size: 18),
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
