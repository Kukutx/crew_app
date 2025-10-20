import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter_riverpod/legacy.dart';

enum SubscriptionPlan { free, plus, pro }

extension SubscriptionPlanLabel on SubscriptionPlan {
  String label(AppLocalizations loc) {
    switch (this) {
      case SubscriptionPlan.free:
        return loc.settings_subscription_plan_free;
      case SubscriptionPlan.plus:
        return loc.settings_subscription_plan_plus;
      case SubscriptionPlan.pro:
        return loc.settings_subscription_plan_pro;
    }
  }
}

final subscriptionPlanProvider = StateProvider<SubscriptionPlan>(
  (ref) => SubscriptionPlan.free,
);
