import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/cards/event_grid_card.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';

class ProfileTabView extends ConsumerWidget {
  const ProfileTabView({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 只 watch 一次 eventsProvider，然后在子组件中过滤数据
    final eventsAsync = ref.watch(eventsProvider);

    return TabBarView(
      controller: controller,
      children: [
        _EventsGrid(eventsAsync: eventsAsync),
        _FavoritesGrid(eventsAsync: eventsAsync),
      ],
    );
  }
}

class _EventsGrid extends StatelessWidget {
  const _EventsGrid({required this.eventsAsync});

  final AsyncValue<List<Event>> eventsAsync;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return eventsAsync.when(
      data: (events) {
        final registered =
            events.where((event) => event.isRegistered).toList(growable: false);

        if (registered.isEmpty) {
          return _CenteredScrollable(child: Text(loc.no_events));
        }

        return AppMasonryGrid(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: registered.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final event = registered[index];
            return EventGridCard(
              event: event,
              heroTag: 'profile_event_${event.id}_$index',
            );
          },
        );
      },
      loading: () => const _CenteredScrollable(
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => _CenteredScrollable(child: Text(loc.load_failed)),
    );
  }
}

class _FavoritesGrid extends StatelessWidget {
  const _FavoritesGrid({required this.eventsAsync});

  final AsyncValue<List<Event>> eventsAsync;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return eventsAsync.when(
      data: (events) {
        final favorites =
            events.where((event) => event.isFavorite).toList(growable: false);

        if (favorites.isEmpty) {
          return _CenteredScrollable(child: Text(loc.favorites_empty));
        }

        return AppMasonryGrid(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: favorites.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final event = favorites[index];
            return EventGridCard(
              event: event,
              heroTag: 'profile_favorite_${event.id}_$index',
            );
          },
        );
      },
      loading: () => const _CenteredScrollable(
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => _CenteredScrollable(child: Text(loc.load_failed)),
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

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
