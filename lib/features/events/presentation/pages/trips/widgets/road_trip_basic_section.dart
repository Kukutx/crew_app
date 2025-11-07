import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/theme/app_design_tokens.dart';
import 'package:crew_app/shared/theme/app_spacing.dart';
import 'package:crew_app/shared/utils/formatted_date.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

import 'road_trip_section_card.dart';

class RoadTripBasicSection extends StatelessWidget {
  const RoadTripBasicSection({
    super.key,
    required this.titleController,
    required this.dateRange,
    required this.onPickDateRange,
  });

  final TextEditingController titleController;
  final DateTimeRange? dateRange;
  final VoidCallback onPickDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.rocket_launch_outlined,
      title: loc.road_trip_basic_section_title,
      subtitle: loc.road_trip_basic_section_subtitle,
      children: [
        TextFormField(
          controller: titleController,
          style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_basic_title_label,
            loc.road_trip_basic_title_hint,
          ),
          maxLength: 20,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? loc.road_trip_basic_title_required
              : null,
        ),
        SizedBox(height: AppDesignTokens.spacingMD.h),
        InkWell(
          onTap: onPickDateRange,
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
          child: Container(
            padding: AppSpacing.symmetric(
              horizontal: AppDesignTokens.spacingLG,
              vertical: 14.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusMD.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: AppDesignTokens.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: theme.colorScheme.primary,
                  size: AppDesignTokens.iconSizeSM.sp,
                ),
                SizedBox(width: AppDesignTokens.spacingMD.w),
                Expanded(
                  child: Text(
                    dateRange == null
                        ? loc.road_trip_basic_date_label
                        : '${DateFormatHelper.formatDate(dateRange!.start)} → ${DateFormatHelper.formatDate(dateRange!.end)}',
                    style: TextStyle(fontSize: AppDesignTokens.fontSizeMD.sp),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: AppDesignTokens.iconSizeSM.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
