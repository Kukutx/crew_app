import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.add_friend_title),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: const SliverToBoxAdapter(
                child: _AddFriendContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFriendContent extends StatelessWidget {
  const _AddFriendContent();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final quickActions = [
      _QuickAction(
        icon: Icons.qr_code_scanner,
        title: loc.add_friend_quick_action_scan,
        description: loc.add_friend_quick_action_scan_description,
      ),
      _QuickAction(
        icon: Icons.share,
        title: loc.add_friend_quick_action_invite,
        description: loc.add_friend_quick_action_invite_description,
      ),
      _QuickAction(
        icon: Icons.contacts,
        title: loc.add_friend_quick_action_import_contacts,
        description: loc.add_friend_quick_action_import_contacts_description,
      ),
    ];

    final interests = [
      loc.tag_city_explore,
      loc.tag_music,
      loc.tag_easy_social,
      loc.tag_sports,
      loc.tag_party,
      loc.tag_trending,
    ];

    final suggestions = [
      _FriendSuggestion(
        name: 'Lena Zhou',
        headline: _localizedText(
          context,
          en: 'Hosts weekend photo walks',
          zh: '周末领队城市摄影漫步',
        ),
        mutualFriends: 3,
        interests: [loc.tag_city_explore, loc.tag_music, loc.tag_easy_social],
        color: colorScheme.primary,
      ),
      _FriendSuggestion(
        name: 'Malik Rivera',
        headline: _localizedText(
          context,
          en: 'Leads community runs',
          zh: '组织社区晨跑',
        ),
        mutualFriends: 2,
        interests: [loc.tag_sports, loc.tag_trending],
        color: colorScheme.tertiary,
      ),
      _FriendSuggestion(
        name: 'Aria Patel',
        headline: _localizedText(
          context,
          en: 'Co-host of the indie music circle',
          zh: '独立音乐圈共同发起人',
        ),
        mutualFriends: 4,
        interests: [loc.tag_music, loc.tag_party],
        color: colorScheme.secondary,
      ),
      _FriendSuggestion(
        name: 'Noah Tan',
        headline: _localizedText(
          context,
          en: 'Planning a creative market pop-up',
          zh: '筹划创意市集快闪',
        ),
        mutualFriends: 1,
        interests: [loc.tag_trending, loc.tag_city_explore],
        color: colorScheme.error,
      ),
    ];

    final contacts = [
      _ContactRecommendation(
        name: 'Ethan Chen',
        note: _localizedText(
          context,
          en: 'Joined your cycling crew last month',
          zh: '上月加入你的骑行团',
        ),
        status: loc.add_friend_contact_status_joined(
          _localizedText(context, en: 'Mar 12', zh: '3月12日'),
        ),
        color: colorScheme.primary,
      ),
      _ContactRecommendation(
        name: 'Sofia Wang',
        note: _localizedText(
          context,
          en: 'Saved in contacts as event planner',
          zh: '通讯录备注为活动策划',
        ),
        status: loc.add_friend_contact_status_pending,
        color: colorScheme.secondary,
      ),
      _ContactRecommendation(
        name: 'Diego Martínez',
        note: _localizedText(
          context,
          en: 'Frequently joins food tours',
          zh: '常常报名城市美食游',
        ),
        status: loc.add_friend_contact_status_joined(
          _localizedText(context, en: 'Feb 28', zh: '2月28日'),
        ),
        color: colorScheme.tertiary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AddFriendSearchBar(hintText: loc.add_friend_search_hint),
        const SizedBox(height: 24),
        _QuickActionsCarousel(actions: quickActions),
        const SizedBox(height: 24),
        _SectionHeader(title: loc.add_friend_interest_section_title),
        const SizedBox(height: 12),
        _InterestChips(interests: interests),
        const SizedBox(height: 32),
        _SectionHeader(title: loc.add_friend_suggestions_section_title),
        const SizedBox(height: 16),
        _SuggestionGrid(suggestions: suggestions),
        const SizedBox(height: 32),
        _SectionHeader(title: loc.add_friend_contacts_section_title),
        const SizedBox(height: 12),
        _ContactList(contacts: contacts),
      ],
    );
  }
}

class _AddFriendSearchBar extends StatelessWidget {
  const _AddFriendSearchBar({required this.hintText});

  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
        ),
        hintText: hintText,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      ),
    );
  }
}

class _QuickActionsCarousel extends StatelessWidget {
  const _QuickActionsCarousel({required this.actions});

  final List<_QuickAction> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final action = actions[index];
          return SizedBox(
            width: 220,
            child: _QuickActionCard(action: action),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemCount: actions.length,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(action.icon, size: 32, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            action.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            action.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _InterestChips extends StatelessWidget {
  const _InterestChips({required this.interests});

  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: interests
          .map(
            (interest) => Chip(
              label: Text(interest),
              backgroundColor: colorScheme.surfaceContainerLowest,
              shape: StadiumBorder(
                side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({required this.suggestions});

  final List<_FriendSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _FriendSuggestionCard(suggestion: suggestion);
      },
    );
  }
}

class _FriendSuggestionCard extends StatelessWidget {
  const _FriendSuggestionCard({required this.suggestion});

  final _FriendSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: suggestion.color.withValues(alpha: 0.18),
            child: Text(
              suggestion.initials,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: suggestion.color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            suggestion.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            suggestion.headline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!
                .add_friend_mutual_count(suggestion.mutualFriends),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestion.interests
                .map(
                  (interest) => Chip(
                    label: Text(interest),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: colorScheme.surfaceContainerLowest,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(36),
            ),
            child: Text(AppLocalizations.of(context)!.add_friend_invite_button),
          ),
        ],
      ),
    );
  }
}

class _ContactList extends StatelessWidget {
  const _ContactList({required this.contacts});

  final List<_ContactRecommendation> contacts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: contacts
          .map(
            (contact) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _ContactTile(contact: contact),
            ),
          )
          .toList(),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final _ContactRecommendation contact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: contact.color.withValues(alpha: 0.18),
          child: Text(
            contact.initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: contact.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contact.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                contact.note,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                contact.status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Text(AppLocalizations.of(context)!.add_friend_invite_button),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _FriendSuggestion {
  const _FriendSuggestion({
    required this.name,
    required this.headline,
    required this.mutualFriends,
    required this.interests,
    required this.color,
  });

  final String name;
  final String headline;
  final int mutualFriends;
  final List<String> interests;
  final Color color;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    final firstPart = parts.first;
    final length = firstPart.length >= 2 ? 2 : 1;
    return firstPart.substring(0, length).toUpperCase();
  }
}

class _ContactRecommendation {
  const _ContactRecommendation({
    required this.name,
    required this.note,
    required this.status,
    required this.color,
  });

  final String name;
  final String note;
  final String status;
  final Color color;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    final firstPart = parts.first;
    final length = firstPart.length >= 2 ? 2 : 1;
    return firstPart.substring(0, length).toUpperCase();
  }
}

String _localizedText(BuildContext context,
    {required String en, required String zh}) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'zh' ? zh : en;
}
