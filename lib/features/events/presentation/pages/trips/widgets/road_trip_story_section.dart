import 'package:flutter/material.dart';

import 'road_trip_section_card.dart';

class RoadTripStorySection extends StatelessWidget {
  const RoadTripStorySection({
    super.key,
    required this.descriptionController,
  });

  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    return RoadTripSectionCard(
      icon: Icons.description_outlined,
      title: '活动亮点',
      subtitle: '告诉伙伴们为什么要来',
      children: [
        TextFormField(
          controller: descriptionController,
          decoration: roadTripInputDecoration(
            context,
            '详细描述',
            '路线亮点、注意事项、装备建议…',
          ),
          maxLines: 6,
          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入描述' : null,
        ),
      ],
    );
  }
}
