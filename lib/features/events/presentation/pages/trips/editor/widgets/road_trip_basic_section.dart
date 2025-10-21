import 'package:flutter/material.dart';

import 'road_trip_form_decorations.dart';
import 'road_trip_section_card.dart';

class RoadTripBasicSection extends StatelessWidget {
  const RoadTripBasicSection({
    super.key,
    required this.titleController,
    required this.dateRange,
    required this.onPickDateRange,
  });

  final TextEditingController titleController;
  final DateTimeRange? dateRange;
  final VoidCallback onPickDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RoadTripSectionCard(
      icon: Icons.rocket_launch_outlined,
      title: '基础信息',
      subtitle: '命名旅程并锁定时间',
      children: [
        TextFormField(
          controller: titleController,
          decoration:
              roadTripInputDecoration(context, '旅程标题', '如：五渔村海岸线一日自驾'),
          validator: (v) => (v == null || v.trim().isEmpty) ? '请输入标题' : null,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.calendar_month,
            color: theme.colorScheme.primary,
          ),
          title: const Text('活动日期'),
          subtitle: Text(
            dateRange == null
                ? '点击选择日期范围'
                : '${_formatDate(dateRange!.start)} → ${_formatDate(dateRange!.end)}',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onPickDateRange,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
