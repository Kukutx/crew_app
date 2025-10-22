import 'package:crew_app/features/user/presentation/pages/settings/state/subscription_plan.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionPlanPage extends ConsumerWidget {
  const SubscriptionPlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentPlan = ref.watch(subscriptionPlanProvider);

    final plans = [
      _SubscriptionPlanOption(
        plan: SubscriptionPlan.free,
        priceLabel: loc.subscription_plan_price_free,
        features: [
          loc.subscription_plan_free_feature_discover,
          loc.subscription_plan_free_feature_save,
          loc.subscription_plan_free_feature_notifications,
        ],
        gradient: [
          colorScheme.surfaceContainerHighest.withValues(alpha: .65),
          colorScheme.surface,
        ],
        accentColor: colorScheme.primary,
      ),
      _SubscriptionPlanOption(
        plan: SubscriptionPlan.plus,
        priceLabel: loc.subscription_plan_price_plus,
        features: [
          loc.subscription_plan_plus_feature_filters,
          loc.subscription_plan_plus_feature_private,
          loc.subscription_plan_plus_feature_support,
        ],
        gradient: [
          colorScheme.primary.withValues(alpha: .18),
          colorScheme.primary.withValues(alpha: .05),
        ],
        accentColor: colorScheme.primary,
        highlight: true,
      ),
      _SubscriptionPlanOption(
        plan: SubscriptionPlan.pro,
        priceLabel: loc.subscription_plan_price_pro,
        features: [
          loc.subscription_plan_pro_feature_collaboration,
          loc.subscription_plan_pro_feature_insights,
        ],
        gradient: [
          colorScheme.secondary.withValues(alpha: .18),
          colorScheme.secondary.withValues(alpha: .05),
        ],
        accentColor: colorScheme.secondary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.subscription_plan_title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            loc.subscription_plan_current_label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _CurrentPlanCard(
            plan: currentPlan,
            priceLabel: plans
                .firstWhere((element) => element.plan == currentPlan)
                .priceLabel,
            description: loc.subscription_plan_current_hint(
              currentPlan.label(loc),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            loc.subscription_plan_subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .8),
            ),
          ),
          const SizedBox(height: 16),
          for (final option in plans) ...[
            _PlanOptionCard(
              option: option,
              currentPlan: currentPlan,
              onSelect: () => _selectPlan(context, ref, option.plan, loc),
            ),
            const SizedBox(height: 20),
          ],
          if (currentPlan != SubscriptionPlan.free) ...[
            const SizedBox(height: 4),
            _CancellationCard(
              description: loc.subscription_plan_cancel_description,
              buttonLabel: loc.subscription_plan_button_cancel,
              onCancel: () => _selectPlan(
                context,
                ref,
                SubscriptionPlan.free,
                loc,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectPlan(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan plan,
    AppLocalizations loc,
  ) {
    ref.read(subscriptionPlanProvider.notifier).state = plan;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(loc.settings_saved_toast)),
      );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.plan,
    required this.priceLabel,
    required this.description,
  });

  final SubscriptionPlan plan;
  final String priceLabel;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.workspace_premium_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.label(loc),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanOptionCard extends ConsumerWidget {
  const _PlanOptionCard({
    required this.option,
    required this.currentPlan,
    required this.onSelect,
  });

  final _SubscriptionPlanOption option;
  final SubscriptionPlan currentPlan;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final isCurrent = currentPlan == option.plan;
    final isUpgrade = option.plan.index > currentPlan.index;
    final label = option.plan.label(loc);
    final buttonLabel = isCurrent
        ? loc.subscription_plan_button_selected
        : isUpgrade
            ? loc.subscription_plan_button_upgrade(label)
            : loc.subscription_plan_button_switch(label);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: option.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isCurrent
              ? option.accentColor
              : colorScheme.outlineVariant.withValues(alpha: .5),
          width: 1.4,
        ),
        boxShadow: option.highlight
            ? [
                BoxShadow(
                  color: option.accentColor.withValues(alpha: .18),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.priceLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: option.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (option.highlight)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: option.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loc.subscription_plan_badge_popular,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: option.accentColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          for (final feature in option.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: option.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.textTheme.bodyMedium?.color?.withValues(alpha: .85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isCurrent ? option.accentColor.withValues(alpha: .3) : null,
                foregroundColor:
                    isCurrent ? colorScheme.onPrimary : null,
                elevation: isCurrent ? 0 : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancellationCard extends StatelessWidget {
  const _CancellationCard({
    required this.description,
    required this.buttonLabel,
    required this.onCancel,
  });

  final String description;
  final String buttonLabel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error.withValues(alpha: .6)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.cancel_schedule_send_outlined),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPlanOption {
  const _SubscriptionPlanOption({
    required this.plan,
    required this.priceLabel,
    required this.features,
    required this.gradient,
    required this.accentColor,
    this.highlight = false,
  });

  final SubscriptionPlan plan;
  final String priceLabel;
  final List<String> features;
  final List<Color> gradient;
  final Color accentColor;
  final bool highlight;
}
