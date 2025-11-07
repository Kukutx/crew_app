import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/theme/app_spacing.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

class RoadTripSectionCard extends StatelessWidget {
  const RoadTripSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.headerTrailing, 
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? headerTrailing; 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: AppSpacing.only(bottom: AppDesignTokens.spacingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                  size: AppDesignTokens.iconSizeSM.sp,
                ),
              ),
              SizedBox(width: AppDesignTokens.spacingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行（标题 + 右侧插槽）
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppDesignTokens.fontSizeXL.sp,
                                ),
                              ),
                              if (subtitle.isNotEmpty) ...[
                                SizedBox(height: AppDesignTokens.spacingXS.h / 2),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: AppDesignTokens.fontSizeSM.sp,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (headerTrailing != null) ...[
                          SizedBox(width: AppDesignTokens.spacingSM.w),
                          headerTrailing!,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDesignTokens.spacingLG.h),
          ...children,
        ],
      ),
    );
  }
}


InputDecoration roadTripInputDecoration(
  BuildContext context,
  String label,
  String? hint,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final theme = Theme.of(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      fontSize: AppDesignTokens.fontSizeMD.sp,
    ),
    hintStyle: theme.textTheme.bodySmall?.copyWith(
      fontSize: 13.sp, // 13px 不在标准 token 中，使用响应式
    ),
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.2),
        width: AppDesignTokens.borderWidthThin,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
      borderSide: BorderSide(
        color: colorScheme.outline.withValues(alpha: 0.2),
        width: AppDesignTokens.borderWidthThin,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: AppDesignTokens.borderWidthMedium,
      ),
    ),
    contentPadding: AppSpacing.symmetric(
      horizontal: AppDesignTokens.spacingLG,
      vertical: 14.h, // 14px 不在标准 token 中，使用响应式
    ),
  );
}