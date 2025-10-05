import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/events_detail_page.dart';
import 'package:crew_app/features/profile/data/favorites_provider.dart';
import 'package:crew_app/features/events/presentation/widgets/event_image_placeholder.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final favoritesAsync = ref.watch(userFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.favorites_title),
      ),
      body: currentUser == null
          ? _CenteredScrollable(child: Text(loc.not_logged_in))
          : favoritesAsync.when(
              data: (favorites) => RefreshIndicator(
                onRefresh: () => ref.refresh(userFavoritesProvider.future),
                child: favorites.isEmpty
                    ? _CenteredScrollable(child: Text(loc.favorites_empty))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: favorites.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final event = favorites[index];
                          return _FavoriteEventTile(event: event);
                        },
                      ),
              ),
              loading: () =>
                  const _CenteredScrollable(child: CircularProgressIndicator()),
              error: (error, _) =>
                  _CenteredScrollable(child: Text(_errorMessage(error, loc))),
            ),
    );
  }
}

String _errorMessage(Object error, AppLocalizations loc) {
  if (error is ApiException) {
    return error.message.isNotEmpty ? error.message : loc.load_failed;
  }
  final message = error.toString();
  return message.isEmpty ? loc.load_failed : message;
}

class _FavoriteEventTile extends StatelessWidget {
  const _FavoriteEventTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.firstAvailableImageUrl;
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
        ),
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) =>
                            const EventImagePlaceholder(aspectRatio: 4 / 3),
                      )
                    : const EventImagePlaceholder(aspectRatio: 4 / 3),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (event.location.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.place_outlined,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      if (event.startTime != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.event_outlined,
                                size: 16, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(event.startTime!),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
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
