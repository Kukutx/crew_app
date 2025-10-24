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

String _localizedText(BuildContext context, {required String en, required String zh}) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'zh' ? zh : en;
}
