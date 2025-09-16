import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../map/events_map_page.dart';
import 'search_controller.dart';

class SearchEventsPage extends ConsumerStatefulWidget {
  const SearchEventsPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchEventsPage> createState() => _SearchEventsPageState();
}

class _SearchEventsPageState extends ConsumerState<SearchEventsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = ref.read(searchControllerProvider);
    final initialQuery = widget.initialQuery;
    final initialText = initialQuery ?? state.query;
    _controller = TextEditingController(text: initialText);

    ref.listen<SearchState>(searchControllerProvider, (prev, next) {
      if (!mounted) return;
      if (prev?.query != next.query && _controller.text != next.query) {
        _controller.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage!.isNotEmpty &&
          prev?.errorMessage != next.errorMessage &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final trimmed = initialQuery?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(searchControllerProvider.notifier);
        notifier.updateQuery(trimmed);
        notifier.search(trimmed);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    FocusScope.of(context).unfocus();
    await ref.read(searchControllerProvider.notifier).search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('搜索活动')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: '输入活动标题...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        ref.read(searchControllerProvider.notifier)
                            .updateQuery(value),
                    onSubmitted: (_) => _runSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _runSearch,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('搜索'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _SearchResultsView(state: state),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return Center(child: Text('搜索失败：${state.errorMessage}'));
    }

    if (state.results.isEmpty) {
      if (!state.hasQuery) {
        return const Center(child: Text('输入关键字开始搜索'));
      }
      return const Center(child: Text('没有找到活动'));
    }

    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final event = state.results[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.description),
          trailing: const Icon(Icons.location_on),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventsMapPage(selectedEvent: event),
              ),
            );
          },
        );
      },
    );
  }
}
