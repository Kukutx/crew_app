import 'package:crew_app/playground/chat/widgets/category_selector.dart';
import 'package:crew_app/playground/chat/widgets/favorite_contacts.dart';
import 'package:crew_app/playground/chat/widgets/recent_chats.dart';
import 'package:flutter/material.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key, this.chatTitle, this.chatStatus, this.tags});

  final String? chatTitle;
  final String? chatStatus;
  final List<String>? tags;

  @override
  UserChatScreenState createState() => UserChatScreenState();
}

class UserChatScreenState extends State<UserChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          iconSize: 30.0,
          color: Colors.white,
          onPressed: () {},
        ),
        title: Text(
          widget.chatTitle ?? 'Chats',
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          CategorySelector(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  if (widget.chatStatus != null || (widget.tags?.isNotEmpty ?? false))
                    _EventChatHeader(
                      status: widget.chatStatus,
                      tags: widget.tags,
                    ),
                  FavoriteContacts(),
                  RecentChats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventChatHeader extends StatelessWidget {
  const _EventChatHeader({this.status, this.tags});

  final String? status;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasTags = tags != null && tags!.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (status != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
          if (hasTags) ...[
            if (status != null) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags!
                  .map(
                    (tag) => Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      backgroundColor: cs.surfaceVariant,
                      side: BorderSide.none,
                      label: Text(
                        '#$tag',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
