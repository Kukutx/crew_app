import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 收藏 Provider
final favoritesProvider = Provider<List<String>>((ref) => [
      "Favorite 1",
      "Favorite 2",
      "Favorite 3",
    ]);

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.favorites_title),
      ),
      body: favorites.isEmpty
          ? Center(child: Text(loc.favorites_empty))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // TODO: 点击查看详情
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.feature_not_ready)),
                      );
                    },
                    child: Center(
                      child: Text(item),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
