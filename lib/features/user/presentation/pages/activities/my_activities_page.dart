import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MyActivitiesPage extends StatelessWidget {
  const MyActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final joiningActivities = <_ActivityCardData>[
      _ActivityCardData(
        title: loc.my_activities_sample_yoga_title,
        description: loc.my_activities_sample_yoga_details,
        participantsLabel: loc.my_activities_card_participants('18'),
        statusLabel: loc.my_activities_status_registered,
        color: colorScheme.primary,
      ),
      _ActivityCardData(
        title: loc.my_activities_sample_market_title,
        description: loc.my_activities_sample_market_details,
        participantsLabel: loc.my_activities_card_participants('42'),
        statusLabel: loc.my_activities_status_registered,
        color: colorScheme.secondary,
      ),
    ];

    final hostingActivities = <_ActivityCardData>[
      _ActivityCardData(
        title: loc.my_activities_sample_cleanup_title,
        description: loc.my_activities_sample_cleanup_details,
        participantsLabel: loc.my_activities_card_participants('25'),
        statusLabel: loc.my_activities_status_hosting,
        color: colorScheme.tertiary,
      ),
      _ActivityCardData(
        title: loc.my_activities_sample_bake_title,
        description: loc.my_activities_sample_bake_details,
        participantsLabel: loc.my_activities_card_participants('11'),
        statusLabel: loc.my_activities_status_hosting,
        color: colorScheme.primary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.my_activities_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: loc.my_activities_joining_title,
              subtitle: loc.my_activities_joining_subtitle,
            ),
            const SizedBox(height: 12),
            for (final activity in joiningActivities) ...[
              _ActivityCard(data: activity),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            _SectionHeader(
              title: loc.my_activities_hosting_title,
              subtitle: loc.my_activities_hosting_subtitle,
            ),
            const SizedBox(height: 12),
            for (final activity in hostingActivities) ...[
              _ActivityCard(data: activity),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ActivityCardData {
  const _ActivityCardData({
    required this.title,
    required this.description,
    required this.participantsLabel,
    required this.statusLabel,
    required this.color,
  });

  final String title;
  final String description;
  final String participantsLabel;
  final String statusLabel;
  final Color color;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.data});

  final _ActivityCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [data.color.withOpacity(0.12), colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  data.statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: data.color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                data.participantsLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
