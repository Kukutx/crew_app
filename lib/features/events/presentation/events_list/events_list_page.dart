import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_grid_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/shared/widgets/app_masonry_grid.dart';
import 'package:crew_app/shared/widgets/app_sheet_scaffold.dart';

import '../../../../app/state/app_overlay_provider.dart';
import '../../../../core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

class EventsListPage extends ConsumerStatefulWidget {
  const EventsListPage({
    super.key,
    this.scrollController,
    this.onClose,
    this.showAsSheet = false,
  });

  final ScrollController? scrollController;
  final VoidCallback? onClose;
  final bool showAsSheet;

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
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(eventsProvider);

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

    final body = RefreshIndicator(
      onRefresh: () async => await ref.refresh(eventsProvider.future),
      child: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return _CenteredScrollable(
              controller: _controller,
              child: Text(loc.no_events),
            );
          }

          return AppMasonryGrid(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: events.length,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
          child: const CircularProgressIndicator(),
        ),
        error: (_, __) => _CenteredScrollable(
          controller: _controller,
          child: Text(loc.load_failed),
        ),
      ),
    );

    if (!widget.showAsSheet) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.events_title)),
        body: body,
      );
    }

    return AppSheetScaffold(
      title: loc.events_title,
      controller: _controller,
      onClose: widget.onClose,
      child: body,
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
  const _CenteredScrollable({
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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

