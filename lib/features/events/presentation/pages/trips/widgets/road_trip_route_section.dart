import 'package:flutter/material.dart';
import '../data/road_trip_editor_models.dart';
import 'road_trip_section_card.dart';

class RoadTripRouteSection extends StatelessWidget {
  const RoadTripRouteSection({
    super.key,
    required this.routeType,
    required this.onRouteTypeChanged,

    // 单程/去程
    required this.forwardWaypoints,
    required this.onAddForward,
    required this.onRemoveForward,
    required this.onReorderForward,

    // 返程（仅往返时用）
    required this.returnWaypoints,
    required this.onAddReturn,
    required this.onRemoveReturn,
    required this.onReorderReturn,
  });

  final RoadTripRouteType routeType;
  final ValueChanged<RoadTripRouteType> onRouteTypeChanged;

  final List<String> forwardWaypoints;
  final VoidCallback onAddForward;
  final ValueChanged<int> onRemoveForward;
  final void Function(int oldIndex, int newIndex) onReorderForward;

  final List<String> returnWaypoints;
  final VoidCallback onAddReturn;
  final ValueChanged<int> onRemoveReturn;
  final void Function(int oldIndex, int newIndex) onReorderReturn;

  @override
  Widget build(BuildContext context) {
    return RoadTripSectionCard(
      icon: Icons.route_outlined,
      title: '路线类型',
      subtitle: '',
       headerTrailing: routeType == RoadTripRouteType.roundTrip
      ? MenuAnchor(
          builder: (context, ctrl, _) => FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
            onPressed: () => ctrl.isOpen ? ctrl.close() : ctrl.open(),
            icon: const Icon(Icons.add_road, size: 18),
            label: const Text('添加途经点'),
          ),
          menuChildren: [
            MenuItemButton(onPressed: onAddForward, child: const Text('添加到去程')),
            MenuItemButton(onPressed: onAddReturn,  child: const Text('添加到返程')),
          ],
        )
      : FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
          onPressed: onAddForward,
          icon: const Icon(Icons.add_road, size: 18),
          label: const Text('添加途经点'),
        ),
      children: [
        // 顶部：中间 SegmentedButton + 右上“添加途经点”
        SizedBox(
          height: 48,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: SegmentedButton<RoadTripRouteType>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: RoadTripRouteType.roundTrip,
                      label: Text('往返路线'),
                      icon: Icon(Icons.autorenew),
                    ),
                    ButtonSegment(
                      value: RoadTripRouteType.oneWay,
                      label: Text('单程路线'),
                      icon: Icon(Icons.route_outlined),
                    ),
                  ],
                  selected: {routeType},
                  onSelectionChanged: (value) => onRouteTypeChanged(value.first),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 列表区域
        if (routeType == RoadTripRouteType.oneWay)
          _ReorderableListSection(
            title: '途经点（单程） · 共 ${forwardWaypoints.length} 个',
            items: forwardWaypoints,
            onRemove: onRemoveForward,
            onReorder: onReorderForward,
          )
        else ...[
          _ReorderableListSection(
            title: '去程 · 共 ${forwardWaypoints.length} 个',
            items: forwardWaypoints,
            onRemove: onRemoveForward,
            onReorder: onReorderForward,
          ),
          const SizedBox(height: 12),
          _ReorderableListSection(
            title: '返程 · 共 ${returnWaypoints.length} 个',
            items: returnWaypoints,
            onRemove: onRemoveReturn,
            onReorder: onReorderReturn,
          ),
        ],
      ],
    );
  }
}

class _ReorderableListSection extends StatelessWidget {
  const _ReorderableListSection({
    required this.title,
    required this.items,
    required this.onRemove,
    required this.onReorder,
  });

  final String title;
  final List<String> items;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            onReorder(oldIndex, newIndex);
          },
          buildDefaultDragHandles: false,
          itemBuilder: (context, index) {
            final text = items[index];
            return Dismissible(
              key: ValueKey('wp-$text-$index'),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onRemove(index),
              child: ListTile(
                leading: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator),
                ),
                title: Text('${index + 1}. $text'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemove(index),
                ),
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        ),
      ],
    );
  }
}
