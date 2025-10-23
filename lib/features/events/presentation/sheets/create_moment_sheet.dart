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
  _MomentType _selectedType = _MomentType.event;

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
    final colorScheme = theme.colorScheme;
    final selectedType = _selectedType;

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
              Text(
                loc.create_moment_type_section_title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _MomentTypeSelector(
                loc: loc,
                selectedType: selectedType,
                onChanged: (type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
              if (selectedType == _MomentType.event) ...[
                const SizedBox(height: 12),
                _LinkedActivityBanner(loc: loc),
              ],
              const SizedBox(height: 20),
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

class _MomentTypeSelector extends StatelessWidget {
  const _MomentTypeSelector({
    required this.loc,
    required this.selectedType,
    required this.onChanged,
  });

  final AppLocalizations loc;
  final _MomentType selectedType;
  final ValueChanged<_MomentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MomentTypeCard(
            title: loc.create_moment_type_instant,
            icon: Icons.flash_on_outlined,
            accentColor: const Color(0xFFE8457C),
            backgroundColor: const Color(0xFFFFEDF3),
            selected: selectedType == _MomentType.instant,
            onTap: () => onChanged(_MomentType.instant),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MomentTypeCard(
            title: loc.create_moment_type_event,
            icon: Icons.event_outlined,
            accentColor: const Color(0xFF3D6FE0),
            backgroundColor: const Color(0xFFE7F1FF),
            selected: selectedType == _MomentType.event,
            onTap: () => onChanged(_MomentType.event),
          ),
        ),
      ],
    );
  }
}

class _MomentTypeCard extends StatelessWidget {
  const _MomentTypeCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBackground =
        selected ? backgroundColor : colorScheme.surfaceContainerHighest;
    final borderColor =
        selected ? accentColor : colorScheme.outlineVariant.withValues(alpha: 0.4);
    final titleStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: titleStyle),
          ],
        ),
      ),
    );
  }
}

class _LinkedActivityBanner extends StatelessWidget {
  const _LinkedActivityBanner({required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.route_outlined,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.create_moment_event_link_label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.create_moment_event_link_value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MomentType { instant, event }
