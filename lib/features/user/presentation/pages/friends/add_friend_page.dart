import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatelessWidget {
  const AddFriendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加好友'),
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
    final contacts = [
      const _ContactInfo(name: 'Ethan Chen', crewId: '#EC-7421'),
      const _ContactInfo(name: 'Sofia Wang', crewId: '#SW-1884'),
      const _ContactInfo(name: 'Diego Martínez', crewId: '#DM-9935'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _AddFriendSearchBar(hintText: '按姓名或 Crew 号搜索'),
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

  final List<_ContactInfo> contacts;

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

  final _ContactInfo contact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CrewAvatar(
          radius: 24,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          foregroundColor: colorScheme.primary,
          child: Text(
            contact.initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              Text(
                contact.crewId,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
          child: const Text('添加好友'),
        ),
      ],
    );
  }
}

class _ContactInfo {
  const _ContactInfo({
    required this.name,
    required this.crewId,
  });

  final String name;
  final String crewId;

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
