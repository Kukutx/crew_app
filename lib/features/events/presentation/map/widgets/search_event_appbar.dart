import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search/search_controller.dart' as event_search;
import 'avatar_icon.dart';

class SearchEventAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const SearchEventAppBar({
    super.key,
    required this.onSearch,
    required this.onAvatarTap,
    required this.tags,
    required this.selected,
    required this.onTagToggle,
    required this.onOpenFilter,
  });

  final void Function(String keyword) onSearch;
  final void Function(bool authed) onAvatarTap;
  final List<String> tags;
  final Set<String> selected;
  final void Function(String tag, bool value) onTagToggle;
  final VoidCallback onOpenFilter;

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  ConsumerState<SearchEventAppBar> createState() => _SearchEventAppBarState();
}

class _SearchEventAppBarState extends ConsumerState<SearchEventAppBar> {
  late final SearchController _searchBarController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(event_search.searchControllerProvider).query;
    _searchBarController = SearchController(text: initialQuery);

    ref.listen<event_search.SearchState>(
      event_search.searchControllerProvider,
      (prev, next) {
        if (!mounted) return;
        if (prev?.query != next.query &&
            _searchBarController.text != next.query) {
          _searchBarController.text = next.query;
        }
      },
    );
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitted(String value) async {
    final query = value.trim();
    final notifier = ref.read(event_search.searchControllerProvider.notifier);
    if (query.isEmpty) {
      notifier.clear();
      _searchBarController.closeView('');
      return;
    }
    await notifier.search(query);
    widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(event_search.searchControllerProvider);
    final notifier = ref.read(event_search.searchControllerProvider.notifier);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      bottom: PreferredSize(
        preferredSize: widget.preferredSize,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  surfaceTintColor: Colors.transparent,
                  child: SearchAnchor(
                    searchController: _searchBarController,
                    builder: (context, controller) => SearchBar(
                      controller: controller,
                      hintText: '搜索活动',
                      leading: const Icon(Icons.my_location_outlined),
                      padding: const MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: notifier.updateQuery,
                      onSubmitted: _onSubmitted,
                      trailing: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: AvatarIcon(onTap: widget.onAvatarTap),
                        ),
                      ],
                    ),
                    suggestionsBuilder: (context, controller) {
                      if (searchState.isLoading) {
                        return const <Widget>[
                          ListTile(
                            leading: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('正在搜索...'),
                          ),
                        ];
                      }

                      if (searchState.errorMessage != null &&
                          searchState.errorMessage!.isNotEmpty) {
                        return <Widget>[
                          ListTile(
                            leading: const Icon(Icons.error_outline),
                            title:
                                Text('搜索失败：${searchState.errorMessage}'),
                            onTap: () =>
                                controller.closeView(searchState.query),
                          ),
                        ];
                      }

                      if (searchState.results.isEmpty) {
                        if (!searchState.hasQuery) {
                          return const <Widget>[];
                        }
                        return const <Widget>[
                          ListTile(title: Text('没有找到活动')),
                        ];
                      }

                      return searchState.results.map((event) {
                        return ListTile(
                          title: Text(event.title),
                          subtitle: event.location.isNotEmpty
                              ? Text(event.location)
                              : null,
                          onTap: () {
                            controller.closeView(event.title);
                            notifier.updateQuery(event.title);
                            widget.onSearch(event.title);
                          },
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...widget.tags.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(t),
                          selected: widget.selected.contains(t),
                          onSelected: (v) => widget.onTagToggle(t, v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: const Text('筛选'),
                      onPressed: widget.onOpenFilter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
