import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'map_event_floating_card.dart';

class MapEventSheet extends StatelessWidget {
  const MapEventSheet({
    super.key,
    required this.event,
    required this.collapsed,
    this.onClose,
    this.onTapBody,
    this.onRegister,
    this.onFavorite,
    this.onHandleDragUpdate,
    this.onHandleDragEnd,
  });

  final Event event;
  final bool collapsed;
  final VoidCallback? onClose;
  final VoidCallback? onTapBody;
  final VoidCallback? onRegister;
  final VoidCallback? onFavorite;
  final void Function(DragUpdateDetails details)? onHandleDragUpdate;
  final void Function(DragEndDetails details)? onHandleDragEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final grabHandle = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onHandleDragUpdate,
      onVerticalDragEnd: onHandleDragEnd,
      child: _Grabber(height: collapsed ? 24 : 20),
    );

    return SafeArea(
      top: false,
      child: _SheetContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            grabHandle,
            if (collapsed)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  loc.map_selection_sheet_tap_to_expand,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                onTap: onTapBody,
                trailing: IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: MapEventFloatingCard(
                  event: event,
                  onClose: onClose ?? () {},
                  onTap: onTapBody ?? () {},
                  onRegister: onRegister ?? () {},
                  onFavorite: onFavorite ?? () {},
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      elevation: 12,
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber({this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: cs.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
