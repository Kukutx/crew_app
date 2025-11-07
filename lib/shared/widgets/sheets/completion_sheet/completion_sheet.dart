import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

/// 显示完成页 Sheet
/// 
/// 用于在后端请求完成后弹出完成页
Future<void> showCompletionSheet(
  BuildContext context, {
  required bool isSuccess,
  String? errorMessage,
  VoidCallback? onDone,
}) async {
  final loc = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // 图标
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  size: 48.sp,
                  color: isSuccess
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onErrorContainer,
                ),
              ),
              SizedBox(height: 32.h),
              // 标题
              Text(
                isSuccess
                    ? loc.road_trip_create_success_title
                    : loc.road_trip_create_failed_title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              // 消息
              Text(
                isSuccess
                    ? loc.road_trip_create_success_message
                    : (errorMessage ?? loc.road_trip_create_failed_message),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // 完成按钮
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDone?.call();
                  },
                  child: Text(loc.road_trip_create_done_button),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
