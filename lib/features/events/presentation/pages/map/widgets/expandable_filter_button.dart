import 'package:flutter/material.dart';

/// 可展开的筛选器按钮组件
/// 位于搜索框下方，点击可展开显示筛选器选项（附近、最新、热门、关注）
class ExpandableFilterButton extends StatefulWidget {
  const ExpandableFilterButton({
    super.key,
    this.onFilterSelected,
    this.selectedFilter,
  });

  final ValueChanged<String>? onFilterSelected;
  final String? selectedFilter;

  @override
  State<ExpandableFilterButton> createState() => _ExpandableFilterButtonState();
}

class _ExpandableFilterButtonState extends State<ExpandableFilterButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  static const _filters = ['附近', '最新', '热门', '关注'];
  String _selectedFilter = _filters.first;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _selectedFilter = widget.selectedFilter ?? _filters.first;
  }

  @override
  void didUpdateWidget(ExpandableFilterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFilter != null && widget.selectedFilter != _selectedFilter) {
      _selectedFilter = widget.selectedFilter!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 主按钮 - 使用主题颜色
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
          child: InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 左侧图标 - 附近图标
                  Icon(
                    Icons.near_me,
                    color: colorScheme.onSurface,
                    size: 18,
                  ),
                  // 文字 - 显示选中的筛选器，展开时隐藏
                  if (!_isExpanded) ...[
                    const SizedBox(width: 6),
                    Text(
                      _selectedFilter,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  // 右侧箭头 - ">"
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // 横向展开内容 - 筛选器按钮行
        Flexible(
          child: SizeTransition(
            axis: Axis.horizontal,
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              margin: const EdgeInsets.only(left: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final filter in _filters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterButton(
                          context,
                          label: filter,
                          isSelected: _selectedFilter == filter,
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                              // 点击筛选器后自动缩回
                              _isExpanded = false;
                              _animationController.reverse();
                            });
                            widget.onFilterSelected?.call(filter);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.95),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

