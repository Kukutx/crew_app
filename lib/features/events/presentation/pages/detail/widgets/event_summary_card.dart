import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventSummaryCard extends StatefulWidget {
  final Event event;
  final AppLocalizations loc;

  const EventSummaryCard({
    super.key,
    required this.event,
    required this.loc,
  });

  @override
  State<EventSummaryCard> createState() => _EventSummaryCardState();
}

class _EventSummaryCardState extends State<EventSummaryCard> {
  static const _collapsedMaxLines = 5;

  bool _isExpanded = false;

  Event get _event => widget.event;

  AppLocalizations get _loc => widget.loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceTint = theme.colorScheme.primaryContainer;
    final gradientStart = surfaceTint.withOpacity(0.42);
    final gradientEnd = surfaceTint.withOpacity(0.08);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
    final headingStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final description = _buildDescription();
    final hasDescription = description.trim().isNotEmpty;
    final showToggle = _isExpandable(description);
    final facts = _buildQuickFacts(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titleStyle != null)
                  Text(
                    _loc.event_details_title,
                    style: titleStyle,
                  )
                else
                  Text(
                    _loc.event_details_title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  _event.title,
                  style: headingStyle ??
                      const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                if (facts.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: facts,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _loc.event_description_field_label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                if (hasDescription)
                  ClipRect(
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ) ??
                            const TextStyle(fontSize: 14, height: 1.5),
                        maxLines: _isExpanded ? null : _collapsedMaxLines,
                        overflow:
                            _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ),
                  )
                else
                  Text(
                    _loc.to_be_announced,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ) ??
                        TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.outline,
                        ),
                  ),
                if (showToggle) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _toggleExpanded,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                      ),
                      label: Text(_expandedLabel(context, _isExpanded)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildTagChips(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _buildDescription() {
    final raw = _event.description.trim();
    if (raw.isEmpty) {
      return '';
    }
    return raw;
  }

  bool _isExpandable(String description) {
    if (description.isEmpty) {
      return false;
    }
    if (description.length > 140) {
      return true;
    }
    final newlineCount = '\n'.allMatches(description).length;
    return newlineCount >= _collapsedMaxLines;
  }

  List<Widget> _buildQuickFacts(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final facts = <Widget>[];
    final schedule = _formatSchedule(locale);
    if (schedule != null) {
      facts.add(_FactChip(icon: Icons.event, label: schedule));
    }
    final meetingPoint = _event.location.trim();
    if (meetingPoint.isNotEmpty) {
      facts.add(_FactChip(icon: Icons.place, label: meetingPoint));
    }
    final participants = _event.participantSummary ?? _loc.to_be_announced;
    facts.add(_FactChip(icon: Icons.group, label: participants));
    final distanceLabel = _formatDistance(locale);
    if (distanceLabel != null) {
      facts.add(_FactChip(icon: Icons.route, label: distanceLabel));
    }
    return facts;
  }

  String? _formatSchedule(String localeTag) {
    final start = _event.startTime;
    final end = _event.endTime;
    if (start == null) {
      return null;
    }
    final startFmt = DateFormat('MM.dd HH:mm', localeTag).format(start.toLocal());
    if (end == null) {
      return startFmt;
    }
    final endFmt = DateFormat('MM.dd HH:mm', localeTag).format(end.toLocal());
    return '$startFmt - $endFmt';
  }

  String? _formatDistance(String localeTag) {
    final distance = _event.distanceKm;
    if (distance == null) {
      return null;
    }
    final numberFormat = NumberFormat.compact(locale: localeTag);
    final formatted = numberFormat.format(distance);
    if (localeTag.startsWith('zh')) {
      return '$formatted 公里';
    }
    return '$formatted km';
  }

  List<Widget> _buildTagChips() {
    final tags = _event.tags;
    if (tags.isEmpty) {
      return [
        _tagChip(_loc.tag_city_explore),
        _tagChip(_loc.tag_easy_social),
        _tagChip(_loc.tag_walk_friendly),
      ];
    }
    return tags.take(6).map(_tagChip).toList(growable: false);
  }

  Widget _tagChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withOpacity(0.8),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ) ??
              const TextStyle(fontSize: 12, color: Colors.orange),
        ),
      );

  String _expandedLabel(BuildContext context, bool isExpanded) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isChinese = languageCode.startsWith('zh');
    if (isExpanded) {
      return isChinese ? '收起' : 'Show less';
    }
    return isChinese ? '展开' : 'Show more';
  }
}

class _FactChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FactChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ) ??
                  TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
