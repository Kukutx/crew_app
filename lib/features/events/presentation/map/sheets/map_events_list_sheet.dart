import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';

import '../../../../../app/state/app_overlay_provider.dart';
import '../../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class MapEventsListSheet extends ConsumerStatefulWidget {
  const MapEventsListSheet({super.key});

  @override
  ConsumerState<MapEventsListSheet> createState() => _MapEventsListSheetState();
}

class _MapEventsListSheetState extends ConsumerState<MapEventsListSheet> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

    // 刷新列表
    ref.listen<AsyncValue<List<Event>>>(eventsProvider, (prev, next) {
      next.whenOrNull(error: (error, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final msg = _errorMessage(error);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        });
      });
    });

    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 4, 8),
              child: Row(
                children: [
                  Text(
                    loc.events_title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    await ref.refresh(eventsProvider.future),
                child: eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return _CenteredScrollable(child: Text(loc.no_events));
                    }

                    return AppMasonryGrid(
                      padding: const EdgeInsets.all(8),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: events.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, i) => EventGridCard(
                        event: events[i],
                        heroTag: 'event_$i',
                        onShowOnMap: (event) {
                          Navigator.of(context).maybePop();
                          ref.read(appOverlayIndexProvider.notifier).state = 1;
                          ref.read(mapFocusEventProvider.notifier).state = event;
                        },
                      ),
                    );
                  },
                  loading: () => const _CenteredScrollable(
                      child: CircularProgressIndicator()),
                  error: (_, _) =>
                      _CenteredScrollable(child: Text(loc.load_failed)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _errorMessage(Object error) {
  if (error is ApiException) {
    return error.message.isNotEmpty ? error.message : error.toString();
  }
  final msg = error.toString();
  return msg.isEmpty ? 'Unknown error' : msg;
}

class _CenteredScrollable extends StatelessWidget {
  final Widget child;

  const _CenteredScrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        );
      },
    );
  }
}

