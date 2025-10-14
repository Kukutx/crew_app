import 'package:crew_app/features/user/presentation/settings/state/settings_models.dart';
import 'package:crew_app/features/user/presentation/settings/state/settings_view_model.dart';
import 'package:crew_app/features/user/presentation/settings/widgets/settings_section_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionSection extends ConsumerWidget {
  const SubscriptionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final plan = ref.watch(
      settingsViewModelProvider.select((value) => value.subscriptionPlan),
    );
    final viewModel = ref.read(settingsViewModelProvider.notifier);

    return SettingsSectionCard(
      title: loc.settings_section_subscription,
      children: [
        ListTile(
          leading: Icon(
            Icons.workspace_premium_outlined,
            semanticLabel: loc.settings_subscription_current_plan,
          ),
          title: Text(loc.settings_subscription_current_plan),
          subtitle: Text(
            loc.settings_subscription_current_plan_value(
              plan.label(loc),
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showSubscriptionPlanSheet(context, ref, plan),
        ),
        ListTile(
          leading: Icon(
            Icons.trending_up_outlined,
            semanticLabel: loc.settings_subscription_upgrade,
          ),
          title: Text(loc.settings_subscription_upgrade),
          onTap: () {
            viewModel.trackNavigation('subscription_upgrade');
            viewModel
                .notifyUnavailable(SettingsUnavailableReason.subscriptionUpgrade);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.cancel_schedule_send_outlined,
            semanticLabel: loc.settings_subscription_cancel,
          ),
          title: Text(loc.settings_subscription_cancel),
          onTap: () {
            viewModel.trackNavigation('subscription_cancel');
            viewModel
                .notifyUnavailable(SettingsUnavailableReason.subscriptionCancel);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.credit_card_outlined,
            semanticLabel: loc.settings_subscription_payment_methods,
          ),
          title: Text(loc.settings_subscription_payment_methods),
          onTap: () {
            viewModel.trackNavigation('subscription_payment_methods');
            viewModel.notifyUnavailable(
              SettingsUnavailableReason.subscriptionPaymentMethods,
            );
          },
        ),
      ],
    );
  }

  void _showSubscriptionPlanSheet(
    BuildContext context,
    WidgetRef ref,
    SubscriptionPlan currentPlan,
  ) {
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final plan in SubscriptionPlan.values)
                ListTile(
                  title: Text(plan.label(loc)),
                  trailing: Icon(
                    plan == currentPlan
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  selected: plan == currentPlan,
                  onTap: () {
                    viewModel.selectSubscriptionPlan(plan);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
