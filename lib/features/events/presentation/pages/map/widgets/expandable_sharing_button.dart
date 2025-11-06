import 'package:flutter/material.dart';

/// 可展开的分享按钮组件
/// 位于搜索框下方，点击可展开显示更多内容
class ExpandableSharingButton extends StatefulWidget {
  const ExpandableSharingButton({
    super.key,
    this.onFilterSelected,
    this.selectedFilter,
  });

  final ValueChanged<String>? onFilterSelected;
  final String? selectedFilter;

  @override
  State<ExpandableSharingButton> createState() => _ExpandableSharingButtonState();
}

class _ExpandableSharingButtonState extends State<ExpandableSharingButton>
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
  void didUpdateWidget(ExpandableSharingButton oldWidget) {
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
        // 主按钮 - 与图片完全一致：白色背景、圆角、深蓝色文字
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent,
          color: Colors.white,
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
                  // 左侧图标 - 两个互联的人物图标
                  Icon(
                    Icons.people,
                    color: const Color(0xFF1E3A8A), // 深蓝色，与图片一致
                    size: 18,
                  ),
                  // 文字 - 显示选中的筛选器，展开时隐藏
                  if (!_isExpanded) ...[
                    const SizedBox(width: 6),
                    Text(
                      _selectedFilter,
                      style: TextStyle(
                        color: const Color(0xFF1E3A8A), // 深蓝色，与图片一致
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
                      color: const Color(0xFF1E3A8A), // 深蓝色，与图片一致
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
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF1E3A8A),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

