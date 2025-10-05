import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'avatar_icon.dart';

class SearchEventAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchEventAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onChanged,
    required this.onClear,
    required this.onAvatarTap,
    required this.tags,
    required this.selected,
    required this.onTagToggle,
    required this.onOpenFilter,
    required this.onResultTap,
    required this.showResults,
    required this.isLoading,
    required this.results,
    this.errorText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String keyword) onSearch;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final void Function(bool authed) onAvatarTap;
  final List<String> tags;
  final Set<String> selected;
  final void Function(String tag, bool value) onTagToggle;
  final VoidCallback onOpenFilter;
  final void Function(Event event) onResultTap;
  final bool showResults;
  final bool isLoading;
  final List<Event> results;
  final String? errorText;

  double get _resultsHeight {
    if (!showResults) return 0;
    if (isLoading) return 72;
    if (errorText != null || results.isEmpty) return 64;

    const itemHeight = 60.0;
    const maxVisible = 4;
    final visibleCount =
        results.length > maxVisible ? maxVisible : results.length;
    return visibleCount * itemHeight;
  }

  // 搜索框 ~56 + 间距8 + 标签条44 + 结果列表高度
  @override
  Size get preferredSize => Size.fromHeight(112 + _resultsHeight);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Material(
                elevation: 4, // 若仍显压，可改为 3
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                surfaceTintColor: Colors.transparent,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final hasQuery = value.text.isNotEmpty;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: loc.search_hint,
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.my_location_outlined),
                        suffixIconConstraints:
                            const BoxConstraints(minWidth: 96, minHeight: 44),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasQuery)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: onClear,
                              )
                            else
                              const SizedBox(
                                  width: 48), // 占位，宽度和 IconButton 差不多,
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: AvatarIcon(onTap: onAvatarTap),
                            ),
                          ],
                        ),
                      ),
                      onSubmitted: onSearch,
                      onChanged: onChanged,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 标签 + 筛选按钮（一行，水平滚动）
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ...tags.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        visualDensity: VisualDensity.compact,
                        label: Text(_tagLabel(loc, t)),
                        selected: selected.contains(t),
                        onSelected: (v) => onTagToggle(t, v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.tune),
                    label: Text(loc.filter),
                    onPressed: onOpenFilter,
                  ),
                ],
              ),
            ),
            if (showResults)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: _buildResults(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
      return SizedBox(
        height: 64,
        child: Center(child: Text(loc.no_events_found)),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1, thickness: 1),
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

  String _tagLabel(AppLocalizations loc, String key) {
    switch (key) {
      case 'today':
        return loc.tag_today;
      case 'nearby':
        return loc.tag_nearby;
      case 'party':
        return loc.tag_party;
      case 'sports':
        return loc.tag_sports;
      case 'music':
        return loc.tag_music;
      case 'free':
        return loc.tag_free;
      case 'trending':
        return loc.tag_trending;
      case 'friends':
        return loc.tag_friends;
      default:
        return key;
    }
  }
}
