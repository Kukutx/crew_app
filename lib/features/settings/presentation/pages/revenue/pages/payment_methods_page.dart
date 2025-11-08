import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/data/payment_method.dart';
import 'package:crew_app/features/settings/presentation/pages/revenue/providers/revenue_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 支付方式管理页面
class PaymentMethodsPage extends ConsumerWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final methodsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.wallet_payment_methods_title),
      ),
      body: methodsAsync.when(
        data: (methods) => _PaymentMethodsList(methods: methods),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(paymentMethodsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 打开添加支付方式对话框
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${loc.wallet_payment_method_add}（待实现）')),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(loc.wallet_payment_method_add),
      ),
    );
  }
}

class _PaymentMethodsList extends ConsumerWidget {
  const _PaymentMethodsList({required this.methods});

  final List<PaymentMethod> methods;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final baseColor = colorScheme.surfaceContainerHighest;

    if (methods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_off_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              loc.wallet_payment_methods_empty,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              gradient: AppTheme.neumorphicGradient(baseColor, isDark: isDark),
              boxShadow: AppTheme.neumorphicShadowRaised(colorScheme, isDark: isDark),
            ),
            child: ListTile(
              leading: _PaymentMethodIcon(type: method.type),
              title: Text(
                method.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: _buildSubtitle(context, method),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (method.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        loc.wallet_payment_method_default,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      _handleMenuAction(context, ref, method, value);
                    },
                    itemBuilder: (context) => [
                      if (!method.isDefault)
                        PopupMenuItem(
                          value: 'setDefault',
                          child: Row(
                            children: [
                              const Icon(Icons.star_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(loc.wallet_payment_method_set_default),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              loc.wallet_payment_method_delete,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(BuildContext context, PaymentMethod method) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parts = <String>[];

    if (method.bankName != null) {
      parts.add(method.bankName!);
    }
    if (method.last4Digits != null) {
      parts.add('尾号${method.last4Digits}');
    }
    if (method.email != null) {
      parts.add(method.email!);
    }

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      parts.join(' · '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PaymentMethod method,
    String action,
  ) {
    final loc = AppLocalizations.of(context)!;
    final service = ref.read(revenueApiServiceProvider);

    switch (action) {
      case 'setDefault':
        service.setDefaultPaymentMethod(method.id).then((_) {
          ref.invalidate(paymentMethodsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已设为默认支付方式')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('操作失败: $error')),
          );
        });
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.wallet_payment_method_delete),
            content: Text('确定要删除支付方式"${method.name}"吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.wallet_payment_method_cancel),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  service.deletePaymentMethod(method.id).then((_) {
                    ref.invalidate(paymentMethodsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已删除')),
                    );
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('删除失败: $error')),
                    );
                  });
                },
                child: Text(loc.wallet_payment_method_delete),
              ),
            ],
          ),
        );
        break;
    }
  }
}

class _PaymentMethodIcon extends StatelessWidget {
  const _PaymentMethodIcon({required this.type});

  final PaymentMethodType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (type) {
      PaymentMethodType.bankCard => Icons.credit_card_outlined,
      PaymentMethodType.paypal => Icons.account_balance_wallet_outlined,
      PaymentMethodType.stripeAccount => Icons.payment_outlined,
      PaymentMethodType.other => Icons.more_horiz_outlined,
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Icon(
        icon,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

