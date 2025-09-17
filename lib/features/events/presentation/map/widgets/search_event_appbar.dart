import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter/material.dart';

import 'avatar_icon.dart';

class SearchEventAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchEventAppBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onAvatarTap,
    required this.tags,
    required this.selected,
    required this.onTagToggle,
    required this.onOpenFilter,
    required this.onResultTap,
    required this.onClearResults,
    required this.showResults,
    required this.isLoading,
    required this.results,
    this.errorText,
  });

  final TextEditingController controller;
  final void Function(String keyword) onSearch;
  final void Function(bool authed) onAvatarTap;
  final List<String> tags;
  final Set<String> selected;
  final void Function(String tag, bool value) onTagToggle;
  final VoidCallback onOpenFilter;
  final void Function(Event event) onResultTap;
  final VoidCallback onClearResults;
  final bool showResults;
  final bool isLoading;
  final List<Event> results;
  final String? errorText;

  double get _resultsHeight {
    if (!showResults) return 0;
    if (isLoading) return 72;
    if (errorText != null || results.isEmpty) return 64;

    final itemHeight = 60.0;
    const maxVisible = 4;
    final visibleCount = results.length > maxVisible ? maxVisible : results.length;
    return visibleCount * itemHeight;
  }

  // 搜索框 ~56 + 间距8 + 标签条44 + 顶部安全区 + 结果列表高度
  @override
  Size get preferredSize => Size.fromHeight(110 + _resultsHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Material(
                  elevation: 3,       // 若仍显压，可改为 3
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  surfaceTintColor: Colors.transparent,
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: '搜索活动',
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.my_location_outlined),
                      suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: AvatarIcon(onTap: onAvatarTap),
                      ),
                    ),
                    onSubmitted: onSearch,
                    onChanged: (value) {
                      if (value.isEmpty) onClearResults();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8), // 关键：给阴影留“呼吸”空间
              // 标签 + 筛选按钮（一行，水平滚动）
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    ...tags.map((t) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            visualDensity: VisualDensity.compact,
                            label: Text(t),
                            selected: selected.contains(t),
                            onSelected: (v) => onTagToggle(t, v),
                          ),
                        )),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: const Text('筛选'),
                      onPressed: onOpenFilter,
                    ),
                  ],
                ),
              ),
              if (showResults)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Material(
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: _buildResults(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (isLoading) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorText != null) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return const SizedBox(
        height: 64,
        child: Center(child: Text('没有找到活动')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          onTap: () => onResultTap(event),
          title: Text(event.title),
          subtitle: Text(
            event.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const Icon(Icons.location_on_outlined),
        );
      },
    );
  }
}
