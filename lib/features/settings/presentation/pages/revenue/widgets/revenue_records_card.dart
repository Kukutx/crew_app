import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/revenue_record.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/number_format_helper.dart';
import 'package:flutter/material.dart';

/// 活动收益记录卡片
/// 
/// 按活动状态分类显示：
/// - 进行中的活动（报名费预留中）
/// - 已结束的活动（收益已到账）
class RevenueRecordsCard extends StatelessWidget {
  const RevenueRecordsCard({
    required this.records,
    super.key,
  });

  final List<RevenueRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final baseColor = colorScheme.surfaceContainerHighest;

    // 分类记录
    final ongoingRecords = records.where((r) => 
      r.eventStatus == 'ongoing' || 
      r.eventStatus == 'recruiting' || 
      r.eventStatus == 'reviewing'
    ).toList();
    
    final endedRecords = records.where((r) => 
      r.eventStatus == 'ended'
    ).toList();

    // 计算汇总金额
    final ongoingTotal = ongoingRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.reservedAmount,
    );
    
    final endedTotal = endedRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.availableAmount,
    );

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
        boxShadow: AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.wallet_revenue_records_title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  loc.wallet_revenue_records_empty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 进行中的活动
                if (ongoingRecords.isNotEmpty) ...[
                  _RevenueSection(
                    title: loc.wallet_revenue_ongoing_title,
                    totalAmount: ongoingTotal,
                    isAvailable: false,
                    records: ongoingRecords,
                  ),
                  if (endedRecords.isNotEmpty) const SizedBox(height: 24),
                ],
                // 已结束的活动
                if (endedRecords.isNotEmpty)
                  _RevenueSection(
                    title: loc.wallet_revenue_ended_title,
                    totalAmount: endedTotal,
                    isAvailable: true,
                    records: endedRecords,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 收益分类区域
class _RevenueSection extends StatelessWidget {
  const _RevenueSection({
    required this.title,
    required this.totalAmount,
    required this.isAvailable,
    required this.records,
  });

  final String title;
  final double totalAmount;
  final bool isAvailable;
  final List<RevenueRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标题和汇总
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              NumberFormatHelper.formatCurrency(totalAmount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isAvailable
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 记录列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final record = records[index];
            return _RevenueRecordItem(
              record: record,
              showReservedAmount: !isAvailable,
            );
          },
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
          itemCount: records.length,
        ),
      ],
    );
  }
}

class _RevenueRecordItem extends StatelessWidget {
  const _RevenueRecordItem({
    required this.record,
    this.showReservedAmount = false,
  });

  final RevenueRecord record;
  final bool showReservedAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    // 显示金额：
    // - showReservedAmount=true（进行中）: 显示预留金额
    // - showReservedAmount=false（已结束）: 显示可用金额
    final displayAmount = showReservedAmount
        ? record.reservedAmount
        : record.availableAmount;
    // 状态标识：已结束的活动显示"已到账"，进行中的活动显示"预留中"
    final isAvailable = record.eventStatus == 'ended';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Icon(
          Icons.emoji_events_outlined,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        record.eventTitle,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        loc.wallet_revenue_record_participants(record.participantCount),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            NumberFormatHelper.formatCurrency(displayAmount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: isAvailable
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              isAvailable ? loc.wallet_revenue_status_available : loc.wallet_revenue_status_reserved,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isAvailable
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

