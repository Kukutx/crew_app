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
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                loc.preferences_tags_empty_helper,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            ),
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    InputChip(
                      label: Text(tag),
                      onDeleted: () => onRemoveTag(tag),
                    ),
                ],
              ),
            ),
          TextField(
            controller: tagInputController,
            onSubmitted: (_) => onAddTag(),
            decoration: InputDecoration(
              labelText: loc.preferences_add_tag_label,
              hintText: loc.preferences_tag_input_hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: onAddTag,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.preferences_recommended_tags_title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in suggestedTags)
                FilterChip(
                  label: Text(tag),
                  selected: tags.contains(tag),
                  onSelected: (_) => onSuggestedTag(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
