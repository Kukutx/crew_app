// widgets/search_appbar.dart
import 'package:flutter/material.dart';
import 'avatar_icon.dart';

class SearchEventAppBar extends StatelessWidget implements PreferredSizeWidget {
  final void Function(String keyword) onSearch;
  final void Function(bool authed) onAvatarTap;


    final List<String> tags;
  final Set<String> selected;
  final void Function(String tag, bool value) onTagToggle;
  final VoidCallback onOpenFilter;

  const SearchEventAppBar({super.key, required this.onSearch, required this.onAvatarTap,    required this.tags,
    required this.selected,
    required this.onTagToggle,
    required this.onOpenFilter,});
  

  // 搜索框 ~56 + 间距8 + 标签条44 + 顶部安全区
  @override
  Size get preferredSize => const Size.fromHeight(110);

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
                  ),
                ),
              ),
              const SizedBox(height: 8),        // 关键：给阴影留“呼吸”空间
               // 标签 + 筛选
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
            ],
          
          ),
        ),
      ),
    );
  }
}
