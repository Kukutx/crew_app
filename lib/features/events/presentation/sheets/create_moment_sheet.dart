import 'package:flutter/material.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

Future<void> showCreateMomentSheet(BuildContext context) {
  final parentContext = context;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CreateMomentSheet(parentContext: parentContext),
  );
}

class _CreateMomentSheet extends StatefulWidget {
  const _CreateMomentSheet({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_CreateMomentSheet> createState() => _CreateMomentSheetState();
}

class _CreateMomentSheetState extends State<_CreateMomentSheet> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.create_moment_title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                loc.create_moment_subtitle,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                minLines: 4,
                maxLines: 6,
                maxLength: 240,
                decoration: InputDecoration(
                  labelText: loc.create_moment_description_label,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _CreateMomentActionButton(
                    icon: Icons.photo_outlined,
                    label: loc.create_moment_add_photo,
                    onTap: () =>
                        _showFeaturePreview(loc.create_moment_add_photo),
                  ),
                  _CreateMomentActionButton(
                    icon: Icons.location_on_outlined,
                    label: loc.create_moment_add_location,
                    onTap: () =>
                        _showFeaturePreview(loc.create_moment_add_location),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(loc.action_cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
                          SnackBar(content: Text(loc.feature_not_ready)),
                        );
                      },
                      child: Text(loc.create_moment_submit_button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeaturePreview(String featureName) {
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(widget.parentContext).showSnackBar(
      SnackBar(
        content: Text(
          loc.create_moment_preview_message(featureName),
        ),
      ),
    );
  }
}

class _CreateMomentActionButton extends StatelessWidget {
  const _CreateMomentActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}
