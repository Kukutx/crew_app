import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/shared/widgets/app_masonry_grid.dart';

import '../../../../core/state/app/app_overlay_provider.dart';
import '../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({
    super.key,
    this.scrollController,
    this.useScaffold = true,
    this.contentPadding,
  });

  final ScrollController? scrollController;
  final bool useScaffold;
  final EdgeInsetsGeometry? contentPadding;

  @override
  ConsumerState<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends ConsumerState<EventsListPage> {
  ScrollController? _internalController;

  ScrollController get _controller =>
      widget.scrollController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _internalController = ScrollController();
    }
  }

  @override
  void didUpdateWidget(covariant EventsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      _internalController?.dispose();
      if (widget.scrollController == null) {
        _internalController = ScrollController();
      } else {
        _internalController = null;
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);
    final padding = widget.contentPadding ?? const EdgeInsets.all(8);
    const scrollPhysics =
        BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

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

    final content = RefreshIndicator(
      onRefresh: () async => await ref.refresh(eventsProvider.future),
      child: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _CenteredScrollable(
              controller: _controller,
              physics: scrollPhysics,
              child: Text(loc.no_events),
            );
          }

          return AppMasonryGrid(
            padding: padding,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: events.length,
            physics: scrollPhysics,
            controller: _controller,
            primary: false,
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
        loading: () => _CenteredScrollable(
          controller: _controller,
          physics: scrollPhysics,
          child: const CircularProgressIndicator(),
        ),
        error: (_, __) => _CenteredScrollable(
          controller: _controller,
          physics: scrollPhysics,
          child: Text(loc.load_failed),
        ),
      ),
    );

    if (widget.useScaffold) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.events_title)),
        body: content,
      );
    }

    return content;
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
  final ScrollController controller;
  final ScrollPhysics physics;

  const _CenteredScrollable({
    required this.child,
    required this.controller,
    required this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          controller: controller,
          physics: physics,
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

