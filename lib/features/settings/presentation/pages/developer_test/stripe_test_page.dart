// lib/features/user/presentation/settings/pages/developer_test/stripe_test_page.dart

import 'package:crew_app/features/settings/presentation/pages/developer_test/stripe_test_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Stripe PaymentSheet · Dev Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '使用 Glitch 演示后端创建 PaymentIntent，打开 PaymentSheet 测试支付流程（测试卡 4242 4242 4242 4242）。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                for (final s in StripeTestScenario.values)
                  RadioListTile<StripeTestScenario>(
                    title: Text(s.label),
                    subtitle: Text(s.subtitle),
                    value: s,
                    groupValue: _scenario,
                    onChanged: _isProcessing
                        ? null
                        : (v) => setState(() => _scenario = v ?? _scenario),
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
            label: const Text('开始测试支付'),
            onPressed: _isProcessing ? null : () => _runPayment(context),
          ),
          if (_lastStatus != null) ...[
            const SizedBox(height: 24),
            Text('最近状态：', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_lastStatus!, style: theme.textTheme.bodyMedium),
            TextButton(
              onPressed: _isProcessing
                  ? null
                  : () => setState(() => _lastStatus = null),
              child: const Text('清除状态'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runPayment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
      _lastStatus = null;
    });

    try {
      final service = ref.read(stripeTestServiceProvider);

      // 1) 向演示后端要 PaymentSheet 所需配置
      final cfg = await service.createPaymentSheet(
        amountInCents: _scenario.amountInCents,
        currency: 'eur',
        description: _scenario.apiDescription,
      );

      if (!mounted) return;

      // 2) 设置 publishableKey（v12 仍然需要）
      Stripe.publishableKey = cfg.publishableKey;

      // 3) 初始化 PaymentSheet（v12 参数）
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: cfg.paymentIntentClientSecret,
          customerId: cfg.customerId,
          customerEphemeralKeySecret: cfg.customerEphemeralKeySecret,
          merchantDisplayName: 'Crew Dev Tools',
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          // ✅ Google Pay
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'DE', // 你的结算国家
            testEnv: true, // 上线前要改为 false
          ),

          // ✅ Apple Pay
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'DE',
          ),
        ),
      );

      // 4) 展示 PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      setState(() => _lastStatus = '✅ 支付完成（模拟环境）');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('支付成功')));
    } on StripeException catch (e) {
      // Stripe 自身异常（取消 or 失败）
      final msg = e.error.localizedMessage ?? e.error.message ?? '已取消或失败';
      if (!mounted) return;
      setState(() => _lastStatus = '❌ $msg');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on StripeTestException catch (e) {
      if (!mounted) return;
      setState(() => _lastStatus = '❌ ${e.message}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _lastStatus = '❌ ${e.toString()}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
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
  String get label {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return '报名 + 赞助(€1.00)';
      case StripeTestScenario.registrationOnly:
        return '仅报名(€0.50)';
      case StripeTestScenario.sponsorshipOnly:
        return '仅赞助(€0.75)';
    }
  }

  String get subtitle {
    switch (this) {
      case StripeTestScenario.registrationWithSponsorship:
        return '同时创建报名与赞助的 PaymentIntent';
      case StripeTestScenario.registrationOnly:
        return '只创建报名费用的 PaymentIntent';
      case StripeTestScenario.sponsorshipOnly:
        return '只创建赞助费用的 PaymentIntent';
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
