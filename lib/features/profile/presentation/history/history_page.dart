import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 假设有一个历史记录 Provider
final historyProvider = Provider<List<String>>((ref) => [
      "Item 1",
      "Item 2",
      "Item 3",
    ]);

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.history_title),
      ),
      body: history.isEmpty
          ? Center(child: Text(loc.history_empty))
          : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final item = history[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      // TODO: 删除单条历史
                    },
                  ),
                  onTap: () {
                    // TODO: 点击查看详情
                  },
                );
              },
            ),
    );
  }
}
