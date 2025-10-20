import 'package:crew_app/features/user/presentation/settings/pages/developer_test/stripe_test_service.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeTestPage extends ConsumerStatefulWidget {
  const StripeTestPage({super.key});

  @override
  ConsumerState<StripeTestPage> createState() => _StripeTestPageState();
}

class _StripeTestPageState extends ConsumerState<StripeTestPage> {
  StripeTestScenario _scenario = StripeTestScenario.registrationWithSponsorship;
  bool _isProcessing = false;
  String? _lastStatus;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.developer_test_stripe_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.developer_test_stripe_description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final scenario in StripeTestScenario.values)
                  RadioListTile<StripeTestScenario>(
                    value: scenario,
                    groupValue: _scenario,
                    onChanged: _isProcessing
                        ? null
                        : (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _scenario = value;
                            });
                          },
                    title: Text(scenario.label(loc)),
                    subtitle: Text(scenario.subtitle(loc)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(loc.developer_test_stripe_button),
            onPressed: _isProcessing ? null : () => _runPayment(context),
          ),
          if (_lastStatus != null) ...[
            const SizedBox(height: 32),
            Text(
              loc.developer_test_stripe_last_status,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _lastStatus!,
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () {
                      setState(() {
                        _lastStatus = null;
                      });
                    },
              child: Text(loc.developer_test_stripe_reset),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runPayment(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final scenario = _scenario;
    setState(() {
      _isProcessing = true;
      _lastStatus = null;
    });

    try {
      final service = ref.read(stripeTestServiceProvider);
      final config = await service.createPaymentSheet(
        amountInCents: scenario.amountInCents,
        currency: 'eur',
        description: scenario.apiDescription,
      );

      if (!mounted) {
        return;
      }

      Stripe.publishableKey = config.publishableKey;
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: PaymentSheetParameters(
          paymentIntentClientSecret: config.paymentIntentClientSecret,
          customerEphemeralKeySecret: config.customerEphemeralKeySecret,
          customerId: config.customerId,
          merchantDisplayName: 'Crew Dev Tools',
          merchantCountryCode: 'IE',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          billingDetails: const BillingDetails(
            name: 'Crew Test User',
            email: 'test@example.com',
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      if (!mounted) {
        return;
      }
      setState(() {
        _lastStatus = loc.developer_test_stripe_success;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.developer_test_stripe_success)));
    } on StripeTestException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _lastStatus = loc.developer_test_stripe_failure(error: error.message);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.developer_test_stripe_failure(error: error.message))),
      );
    } on StripeException catch (error) {
      final stripeError = error.error;
      final message = stripeError?.localizedMessage ?? stripeError?.message;
      if (!mounted) {
        return;
      }
      setState(() {
        _lastStatus = message == null
            ? loc.developer_test_stripe_cancelled
            : loc.developer_test_stripe_failure(error: message);
      });
      if (message == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.developer_test_stripe_cancelled)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.developer_test_stripe_failure(error: message))),
        );
      }
    } catch (error) {
      final message = error.toString();
      if (!mounted) {
        return;
      }
      setState(() {
        _lastStatus = loc.developer_test_stripe_failure(error: message);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.developer_test_stripe_failure(error: message))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

enum StripeTestScenario {
  registrationWithSponsorship,
  registrationOnly,
  sponsorshipOnly,
}

extension on StripeTestScenario {
  String label(AppLocalizations loc) {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return loc.developer_test_stripe_option_registration_sponsor;
      case StripeTestScenario.registrationOnly:
        return loc.developer_test_stripe_option_registration_only;
      case StripeTestScenario.sponsorshipOnly:
        return loc.developer_test_stripe_option_sponsor_only;
    }
  }

  String subtitle(AppLocalizations loc) {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return loc.developer_test_stripe_option_registration_sponsor_detail;
      case StripeTestScenario.registrationOnly:
        return loc.developer_test_stripe_option_registration_only_detail;
      case StripeTestScenario.sponsorshipOnly:
        return loc.developer_test_stripe_option_sponsor_only_detail;
    }
  }

  String get apiDescription {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return 'registration+sponsorship';
      case StripeTestScenario.registrationOnly:
        return 'registration';
      case StripeTestScenario.sponsorshipOnly:
        return 'sponsorship';
    }
  }

  int get amountInCents {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return 100; // €1.00
      case StripeTestScenario.registrationOnly:
        return 50; // €0.50
      case StripeTestScenario.sponsorshipOnly:
        return 75; // €0.75
    }
  }
}
