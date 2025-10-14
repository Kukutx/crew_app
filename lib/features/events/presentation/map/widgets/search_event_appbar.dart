import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'avatar_icon.dart';

const double _searchBarHeight = 68.0;
const double _searchHorizontalPadding = 12.0;
const double _searchTopPadding = 12.0;
const double _dropdownGap = 8.0;
const double _resultItemHeight = 72.0;
const int _maxVisibleItems = 4;
const double _maxResultsHeight = _resultItemHeight * _maxVisibleItems;

class SearchEventAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchEventAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.onChanged,
    required this.onClear,
    required this.onCreateRoadTripTap,
    required this.onAvatarTap,
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
  final VoidCallback onCreateRoadTripTap;
  final void Function(bool authed) onAvatarTap;
  final void Function(Event event) onResultTap;
  final bool showResults;
  final bool isLoading;
  final List<Event> results;
  final String? errorText;

  double get _resultsHeight {
    if (!showResults) return 0;
    if (isLoading) return _resultItemHeight;
    if (errorText != null || results.isEmpty) return 64.0;

    final visibleCount =
        results.length > _maxVisibleItems ? _maxVisibleItems : results.length;
    return (visibleCount * _resultItemHeight)
        .clamp(0, _maxResultsHeight)
        .toDouble();
  }

  // 搜索框 ~56 + 余量12
  @override
  Size get preferredSize => const Size.fromHeight(_searchBarHeight);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: SizedBox(
          height: preferredSize.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _searchHorizontalPadding,
                    _searchTopPadding,
                    _searchHorizontalPadding,
                    0,
                  ),
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
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: onCreateRoadTripTap,
                            ),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 96, minHeight: 44),
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
              ),
              if (showResults)
                Positioned(
                  left: _searchHorizontalPadding,
                  right: _searchHorizontalPadding,
                  top: _searchBarHeight + _dropdownGap,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: _resultsHeight,
                      child: _buildResults(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            errorText!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(child: Text(loc.no_events_found));
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: results.length,
      physics: results.length > _maxVisibleItems
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final event = results[index];
        return SizedBox(
          height: _resultItemHeight,
          child: ListTile(
            onTap: () => onResultTap(event),
            title: Text(event.title),
            subtitle: Text(
              event.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(Icons.location_on_outlined),
          ),
        );
      },
    );
  }

}
