import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

/// 通用的卡片瓦片组件
/// 用于显示带有图标、标题、副标题和操作按钮的列表项
class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onLeadingTap,
    this.enabled = true,
    this.hasValue = false,
    this.onClear,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLeadingTap;
  final bool enabled;
  final bool hasValue; // 是否有值
  final VoidCallback? onClear; // 清空值的回调

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.5;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLG.r),
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            child: Row(
              children: [
                onLeadingTap != null
                    ? InkWell(
                        onTap: enabled ? onLeadingTap : null,
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: leading,
                        ),
                      )
                    : leading,
                SizedBox(width: AppDesignTokens.spacingMD.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        SizedBox(height: AppDesignTokens.spacingXS.h),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: AppDesignTokens.fontSizeSM.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 根据是否有值显示不同的图标
                if (hasValue && onClear != null)
                  // 有值时显示 X 图标（可点击清空）
                  IconButton(
                    icon: Icon(Icons.close, size: 20.r),
                    onPressed: enabled ? onClear : null,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    iconSize: 20.r,
                  )
                else
                  // 无值时显示箭头图标
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

