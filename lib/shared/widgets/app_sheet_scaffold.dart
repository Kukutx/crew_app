import 'package:flutter/material.dart';

class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.title,
    required this.controller,
    required this.child,
    this.actions,
    this.leading,
    this.onClose,
  });

  final String title;
  final ScrollController controller;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveActions = <Widget>[...?actions];
    if (onClose != null) {
      effectiveActions.add(
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: onClose,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final action in effectiveActions) ...[
                      const SizedBox(width: 8),
                      action,
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: PrimaryScrollController(
                  controller: controller,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
