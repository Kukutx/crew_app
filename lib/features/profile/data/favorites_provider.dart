import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFavoritesProvider =
    FutureProvider.autoDispose<List<Event>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const [];
  }

  final api = ref.watch(apiServiceProvider);
  return api.getUserFavorites(user.uid);
});
