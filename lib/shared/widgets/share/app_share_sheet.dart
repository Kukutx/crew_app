import 'package:flutter/material.dart';

/// A reusable bottom sheet layout for sharing content with preview and actions.
class AppShareSheet extends StatelessWidget {
  const AppShareSheet({
    super.key,
    required this.preview,
    required this.actions,
    this.description,
    this.actionSpacing = 16,
    this.actionRunSpacing = 12,
  });

  final Widget preview;
  final Widget? description;
  final List<Widget> actions;
  final double actionSpacing;
  final double actionRunSpacing;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              preview,
              if (description != null) ...[
                const SizedBox(height: 20),
                description!,
              ],
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: actionSpacing,
                runSpacing: actionRunSpacing,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppShareActionButton extends StatelessWidget {
  const AppShareActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.orange,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
