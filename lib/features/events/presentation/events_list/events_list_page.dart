import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';

import '../../../../app/state/app_overlay_provider.dart';
import '../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({super.key});

  @override
  ConsumerState<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends ConsumerState<EventsListPage> {
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

    return Scaffold(
      appBar: AppBar(title: Text(loc.events_title)),
      body: RefreshIndicator(
        onRefresh: () async => await ref.refresh(eventsProvider.future),
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
                  ref.read(appOverlayIndexProvider.notifier).state = 1;
                  ref.read(mapFocusEventProvider.notifier).state = event;
                },
              ),
            );
          },
          loading: () =>
              const _CenteredScrollable(child: CircularProgressIndicator()),
          error: (_, _) => _CenteredScrollable(child: Text(loc.load_failed)),
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

