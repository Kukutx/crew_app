// sheets/event_filter_sheet.dart
import 'package:crew_app/features/events/data/event_filter.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
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
      final loc = AppLocalizations.of(ctx)!;
      var temp = initial;
      return StatefulBuilder(builder: (ctx, setState) {
        final dateOptions = <(String, String)>[
          ('today', loc.filter_date_today),
          ('week', loc.filter_date_this_week),
          ('month', loc.filter_date_this_month),
          ('any', loc.filter_date_any),
        ];
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(loc.filter_distance),
                Text('${temp.distanceKm.toStringAsFixed(0)} km'),
              ]),
              Slider(
                value: temp.distanceKm, min: 1, max: 50, divisions: 49,
                label: '${temp.distanceKm.toStringAsFixed(0)} km',
                onChanged: (v) => setState(() => temp = temp.copyWith(distanceKm: v)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(loc.filter_date),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final e in dateOptions)
                  ChoiceChip(
                    label: Text(e.$2),
                    selected: temp.date == e.$1,
                    onSelected: (_) => setState(() => temp = temp.copyWith(date: e.$1)),
                  ),
              ]),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.filter_only_free),
                value: temp.onlyFree,
                onChanged: (v) => setState(() => temp = temp.copyWith(onlyFree: v)),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(loc.filter_category),
              ),
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
                  child: Text(loc.action_reset),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(loc.action_cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, temp),
                  child: Text(loc.action_apply),
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
