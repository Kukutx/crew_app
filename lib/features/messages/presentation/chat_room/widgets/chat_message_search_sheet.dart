import 'dart:math' as math;

import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatMessageSearchSheet extends StatefulWidget {
  const ChatMessageSearchSheet({
    super.key,
    required this.messages,
    required this.onMessageSelected,
  });

  final List<ChatMessage> messages;
  final ValueChanged<ChatMessage> onMessageSelected;

  @override
  State<ChatMessageSearchSheet> createState() => _ChatMessageSearchSheetState();
}

class _ChatMessageSearchSheetState extends State<ChatMessageSearchSheet> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    final trimmedQuery = _query.trim();
    final lowerQuery = trimmedQuery.toLowerCase();

    final List<ChatMessage> results;
    if (lowerQuery.isEmpty) {
      results = widget.messages;
    } else {
      results = widget.messages
          .where(
            (message) => message.body.toLowerCase().contains(lowerQuery) ||
                message.attachmentLabels.any(
                  (label) => label.toLowerCase().contains(lowerQuery),
                ),
          )
          .toList(growable: false);
    }

    return SafeArea(
      child: SizedBox(
        height: math.min(mediaQuery.size.height * 0.75, 520),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 16 + mediaQuery.viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.chat_search_title,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: loc.chat_search_hint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: trimmedQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: results.isEmpty
                    ? _EmptySearchState(message: loc.chat_search_no_results)
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final message = results[index];
                          final senderLabel = message.sender.isCurrentUser
                              ? loc.chat_you_label
                              : message.sender.displayName;
                          final subtitle =
                              '$senderLabel · ${message.sentAtLabel}';

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 6),
                            onTap: () => widget.onMessageSelected(message),
                            title: Text(
                              message.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(subtitle),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
