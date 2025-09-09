// sheets/event_filter_sheet.dart
import 'package:crew_app/features/events/data/event_filter.dart';
import 'package:flutter/material.dart';

  /// 地图活动筛选事件
Future<EventFilter?> showEventFilterSheet({
  required BuildContext context,
  required EventFilter initial,
  required List<String> allCategories,
}) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      var temp = initial;
      return StatefulBuilder(builder: (ctx, setState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('距离'), Text('${temp.distanceKm.toStringAsFixed(0)} km'),
              ]),
              Slider(
                value: temp.distanceKm, min: 1, max: 50, divisions: 49,
                label: '${temp.distanceKm.toStringAsFixed(0)} km',
                onChanged: (v) => setState(() => temp = temp.copyWith(distanceKm: v)),
              ),
              const SizedBox(height: 8),
              const Align(alignment: Alignment.centerLeft, child: Text('日期')),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in [
                  ('today','今天'),('week','本周'),('month','本月'),('any','不限'),
                ])
                  ChoiceChip(
                    label: Text(e.$2),
                    selected: temp.date == e.$1,
                    onSelected: (_) => setState(() => temp = temp.copyWith(date: e.$1)),
                  ),
              ]),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('仅显示免费活动'),
                value: temp.onlyFree,
                onChanged: (v) => setState(() => temp = temp.copyWith(onlyFree: v)),
              ),
              const Align(alignment: Alignment.centerLeft, child: Text('分类')),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final c in allCategories)
                  FilterChip(
                    label: Text(c),
                    selected: temp.categories.contains(c),
                    onSelected: (v) {
                      final next = {...temp.categories};
                      v ? next.add(c) : next.remove(c);
                      setState(() => temp = temp.copyWith(categories: next));
                    },
                  ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                TextButton(
                  onPressed: () => setState(() => temp = const EventFilter()),
                  child: const Text('重置'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, temp),
                  child: const Text('应用'),
                ),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        );
      });
    },
  );
}
