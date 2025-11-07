import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
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
    required this.onQuickActionsTap,
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
  final VoidCallback onQuickActionsTap;
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

    // 结果列表容器外部有 Padding(top: 8, bottom: 12)，需要将这 20 像素计入
    // preferredSize，否则在部分屏幕上会出现底部溢出。
    final padding = 20.h;

    if (isLoading) return 72.h + padding;
    if (errorText != null || results.isEmpty) return 64.h + padding;

    const maxVisible = 4;
    final visibleCount = results.length > maxVisible
        ? maxVisible
        : results.length;
    // 如果有分隔线，需要减去最后一个分隔线（因为最后一个item后面没有分隔线）
    final dividerHeight = visibleCount > 1 ? (visibleCount - 1) * 1.h : 0.0;
    return visibleCount * 56.h + dividerHeight + padding;
  }

  // 搜索框 ~56 + 余量12 + 结果列表高度
  @override
  Size get preferredSize =>
      Size.fromHeight((showClearSelectionAction ? 112.h : 68.h) + _resultsHeight);

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
                12.w,
                showClearSelectionAction ? 8.h : 12.h,
                12.w,
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
                    SizedBox(height: 8.h),
                  Material(
                    elevation: 4, // 若仍显压，可改为 3
                    borderRadius: BorderRadius.circular(16.r),
                    clipBehavior: Clip.antiAlias,
                    surfaceTintColor: Colors.transparent,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final theme = Theme.of(context);
                        final hasQuery = value.text.isNotEmpty;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: loc.search_hint,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: IconButton(
                              icon: Icon(
                                Icons.menu,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: onQuickActionsTap,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 96.w,
                              minHeight: 44.h,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasQuery)
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    onPressed: onClear,
                                  )
                                else
                                  SizedBox(
                                    width: 48.w,
                                  ), // 占位，宽度和 IconButton 差不多,
                                Padding(
                                  padding: EdgeInsets.only(right: 6.w),
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
                padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16.r),
                  clipBehavior: Clip.antiAlias,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
                  child: _buildResults(context),
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
      return SizedBox(
        height: 72.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    if (errorText != null) {
      return SizedBox(
        height: 64.h,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              errorText!,
              style: TextStyle(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return SizedBox(
        height: 64.h,
        child: Center(
          child: Text(
            loc.no_events_found,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    // 计算实际可用高度
    final maxItems = results.length > 4 ? 4 : results.length;
    final itemHeight = 56.h;
    final dividerHeight = maxItems > 1 ? (maxItems - 1) * 1.h : 0.0;
    final calculatedHeight = maxItems * itemHeight + dividerHeight;
    
    return SizedBox(
      height: calculatedHeight,
      child: ListView.separated(
        shrinkWrap: false,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: results.length > 4 ? 4 : results.length,
        separatorBuilder: (_, _) => Divider(
          height: 1.h,
          thickness: 1.h,
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final event = results[index];
          return SizedBox(
            height: 56.h,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 0,
              ),
              minVerticalPadding: 0,
              visualDensity: VisualDensity.compact,
              onTap: () => onResultTap(event),
              title: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
              subtitle: Text(
                event.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12.sp,
                  height: 1.3,
                ),
              ),
              leading: Icon(
                Icons.location_on_outlined,
                size: 20.sp,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}
