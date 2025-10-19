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
    this.onAddTap,
    required this.onAvatarTap,
    required this.onResultTap,
    required this.showResults,
    required this.isLoading,
    required this.results,
    this.errorText,
    this.showClearSelectionAction = false,
    this.onClearSelection,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String keyword) onSearch;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback? onAddTap;
  final void Function(bool authed) onAvatarTap;
  final void Function(Event event) onResultTap;
  final bool showResults;
  final bool isLoading;
  final List<Event> results;
  final String? errorText;
  final bool showClearSelectionAction;
  final VoidCallback? onClearSelection;

  double get _resultsHeight {
    if (!showResults) return 0;

    // 结果列表容器外部有 Padding(top: 4, bottom: 12)，需要将这 16 像素计入
    // preferredSize，否则在部分屏幕上会出现底部溢出。
    const padding = 16.0;

    if (isLoading) return 72 + padding;
    if (errorText != null || results.isEmpty) return 64 + padding;

    const itemHeight = 60.0;
    const maxVisible = 4;
    final visibleCount =
        results.length > maxVisible ? maxVisible : results.length;
    return visibleCount * itemHeight + padding;
  }

  // 搜索框 ~56 + 余量12 + 结果列表高度
  @override
  Size get preferredSize => Size.fromHeight(
        (showClearSelectionAction ? 112 : 68) + _resultsHeight,
      );

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
              padding: EdgeInsets.fromLTRB(
                12,
                showClearSelectionAction ? 8 : 12,
                12,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showClearSelectionAction && onClearSelection != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onClearSelection,
                        icon: const Icon(Icons.close),
                        label: Text(loc.map_clear_selected_point),
                      ),
                    ),
                  if (showClearSelectionAction && onClearSelection != null)
                    const SizedBox(height: 8),
                  Material(
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
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: onAddTap != null
                                ? IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: onAddTap,
                                  )
                                : null,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 96,
                              minHeight: 44,
                            ),
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
                                    width: 48,
                                  ), // 占位，宽度和 IconButton 差不多,
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
                ],
              ),
            ),
            if (showResults)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
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

}
