import 'dart:math' as math;
import 'package:crew_app/features/events/presentation/map/widgets/avatar_icon.dart';
import 'package:flutter/material.dart';
import 'package:crew_app/features/events/data/event.dart';

/// Overlay 控制器：负责创建/销毁下拉结果的 OverlayEntry
class SearchOverlayController {
  final LayerLink link = LayerLink();
  OverlayEntry? _entry;

  bool get isShown => _entry != null;

  void show(
    BuildContext context,
    Widget dropdown, {
    required double width,    // <- 新增
    double? maxWidth,         // <- 新增，可选最大宽
  }) {
    hide();
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        // 让下拉在键盘弹出时也不会被挤爆
        final double maxH = math.max(
          0,
          math.min(240, media.size.height - media.viewInsets.bottom - 120),
        );

            // 水平最大宽度：考虑屏幕安全区与左右 padding（跟上方搜索框 12 一致）
      final double safeMaxW = media.size.width - media.padding.horizontal - 24;
      final double w = math.min(width, math.min(safeMaxW, maxWidth ?? double.infinity));


        return Positioned.fill(
          child: Stack(
            children: [
              // 点击空白处关闭
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hide,
                ),
              ),
              CompositedTransformFollower(
                link: link,
                showWhenUnlinked: false,
                // 目标锚点正下方 4px
                offset: const Offset(0, 4),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxH),
                  child: SizedBox( // <- 宽度自适应且有上限
                    width: w,
                    child: dropdown,
                  ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }

  void dispose() => hide();
}

/// 使用方法：用此组件替换原先的 SearchEventAppBar
/// - 结果列表不再放在 AppBar 内部，而是通过 Overlay 悬浮展示
class SearchEventAppBar extends StatefulWidget implements PreferredSizeWidget {
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

  // 固定高度：搜索框(56) + 间距(8) + 标签条(44) + 间距(4)
  @override
  Size get preferredSize => const Size.fromHeight(112);

  @override
  State<SearchEventAppBar> createState() => _SearchEventAppBarState();
}

class _SearchEventAppBarState extends State<SearchEventAppBar> {
  late final SearchOverlayController _overlay = SearchOverlayController();

  // 保存锚点（搜索框）实时宽度
  double _anchorWidth = 0;

  @override
  void initState() {
    super.initState();
    // 首帧后根据初始状态处理 Overlay
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
  }

  @override
  void didUpdateWidget(covariant SearchEventAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 属性变化后，同步 Overlay 显示/隐藏
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
  }

  @override
  void dispose() {
    _overlay.dispose();
    super.dispose();
  }

  void _syncOverlay() {
    final shouldShow = widget.showResults &&
        (widget.isLoading || widget.errorText != null || widget.results.isNotEmpty);
    if (!mounted) return;

    if (shouldShow) {
      _overlay.show(
        context,
        _buildResults(),
        width: _anchorWidth,   // <- 传入测得宽度
        maxWidth: 560,         // <- 你想要的最大宽度（可按需调整/去掉）
      );
    } else {
      _overlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      bottom: PreferredSize(
        preferredSize: widget.preferredSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
    // 2) 用 LayoutBuilder 读出搜索框可用宽度
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth; // 实际可用宽度
                  if (w != _anchorWidth) {
                    _anchorWidth = w;
                    // 宽度变化时，同步 Overlay 尺寸
                    WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
                  }
                  return Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    surfaceTintColor: Colors.transparent,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: widget.controller,
                      builder: (context, value, _) {
                        final hasQuery = value.text.isNotEmpty;
                        return TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          textInputAction: TextInputAction.search,
                          onSubmitted: widget.onSearch,
                          onChanged: widget.onChanged,
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
                            suffixIconConstraints: const BoxConstraints(minWidth: 96, minHeight: 44),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasQuery)
                                  IconButton(icon: const Icon(Icons.close), onPressed: widget.onClear)
                                else
                                  const SizedBox(width: 48),
                                const SizedBox(width: 6),
                                AvatarIcon(onTap: widget.onAvatarTap),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // 标签 + 筛选
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
            const SizedBox(height: 4),
            // 作为下拉锚点：将 Overlay 跟随到此处
            CompositedTransformTarget(
              link: _overlay.link,
              child: const SizedBox(height: 0, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.errorText != null) {
      return SizedBox(
        height: 64,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (widget.results.isEmpty) {
      return const SizedBox(
        height: 64,
        child: Center(child: Text('没有找到活动')),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: widget.results.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final event = widget.results[index];
        return ListTile(
          onTap: () => widget.onResultTap(event),
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
