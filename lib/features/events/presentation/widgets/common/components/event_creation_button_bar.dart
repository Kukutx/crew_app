import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// 事件创建按钮栏
/// 
/// 统一的按钮布局逻辑，用于事件创建流程
class EventCreationButtonBar extends StatelessWidget {
  const EventCreationButtonBar({
    super.key,
    required this.isCreating,
    required this.canCreate,
    required this.onCreate,
    this.onContinue,
    this.showContinue = false,
    this.createButtonText,
    this.continueButtonText,
  });

  final bool isCreating;
  final bool canCreate;
  final VoidCallback? onCreate;
  final VoidCallback? onContinue;
  final bool showContinue;
  final String? createButtonText;
  final String? continueButtonText;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final createText = createButtonText ?? loc.road_trip_create_button;
    final continueText = continueButtonText ?? loc.road_trip_continue_button;

    if (showContinue && onContinue != null) {
      // 显示创建和继续两个按钮
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: (canCreate && !isCreating) ? onCreate : null,
              child: isCreating
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(createText),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: FilledButton(
              onPressed: onContinue,
              child: Text(continueText),
            ),
          ),
        ],
      );
    } else {
      // 只显示创建按钮
      return FilledButton(
        onPressed: (canCreate && !isCreating) ? onCreate : null,
        style: FilledButton.styleFrom(
          minimumSize: Size(double.infinity, 44.h),
        ),
        child: isCreating
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(createText),
      );
    }
  }
}

