import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

/// 可点击的页面指示器
class ClickablePageIndicator extends StatelessWidget {
  const ClickablePageIndicator({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  final PageController controller;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return GestureDetector(
          onTap: () => onPageTap(index),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: AppDesignTokens.spacingXS.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: isActive ? 12.w : 10.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(5.r),
              ),
            ),
          ),
        );
      }),
    );
  }
}


