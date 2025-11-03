import 'package:flutter/material.dart';
import 'road_trip_section_card.dart';

class RoadTripHostDisclaimerSection extends StatelessWidget {
  const RoadTripHostDisclaimerSection({
    super.key,
    required this.disclaimerController,
  });

  final TextEditingController disclaimerController;

  @override
  Widget build(BuildContext context) {
    return RoadTripSectionCard(
      icon: Icons.shield_moon_outlined,
      title: '发起者免责声明',
      subtitle: '向伙伴说明风险、特殊要求…',
      children: [
        TextFormField(
          controller: disclaimerController,
          decoration: roadTripInputDecoration(
            context,
            '免责声明内容',
            '例如风险提示、特殊说明等',
          ),
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}
