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

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No history yet~'))
          : ListView.separated(
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(),
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
