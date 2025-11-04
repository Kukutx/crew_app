import 'package:flutter/material.dart';

import 'package:crew_app/l10n/generated/app_localizations.dart';

import 'section_card.dart';

class TagSection extends StatelessWidget {
  const TagSection({
    super.key,
    required this.tags,
    required this.tagInputController,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onSuggestedTag,
    required this.suggestedTags,
  });

  final List<String> tags;
  final TextEditingController tagInputController;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<String> onSuggestedTag;
  final List<String> suggestedTags;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                loc.preferences_tags_empty_helper,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.4,
                  letterSpacing: 0,
                ),
              ),
            ),
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    InputChip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                      onDeleted: () => onRemoveTag(tag),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                ],
              ),
            ),
          TextField(
            controller: tagInputController,
            onSubmitted: (_) => onAddTag(),
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              labelText: loc.preferences_add_tag_label,
              hintText: loc.preferences_tag_input_hint,
              labelStyle: const TextStyle(
                fontSize: 14,
                height: 1.3,
                letterSpacing: 0,
              ),
              hintStyle: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: onAddTag,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.preferences_recommended_tags_title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in suggestedTags)
                FilterChip(
                  label: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                  selected: tags.contains(tag),
                  onSelected: (_) => onSuggestedTag(tag),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
