import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:crew_app/features/user/presentation/user_profile/profile_guestbook_provider.dart';

class ProfileGuestbook extends ConsumerStatefulWidget {
  const ProfileGuestbook({super.key});

  @override
  ConsumerState<ProfileGuestbook> createState() => _ProfileGuestbookState();
}

class _ProfileGuestbookState extends ConsumerState<ProfileGuestbook> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() {
    final messenger = ScaffoldMessenger.of(context);
    final rawName = _nameController.text.trim();
    final content = _messageController.text.trim();

    if (content.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('请输入留言内容')), 
      );
      return;
    }

    final displayName = rawName.isEmpty ? '匿名用户' : rawName;
    ref.read(profileGuestbookProvider.notifier).addMessage(displayName, content);

    _messageController.clear();
    messenger.showSnackBar(
      const SnackBar(content: Text('留言成功！')),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(profileGuestbookProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(32),
                    children: const [
                      SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('还没有留言，快来抢沙发吧！'),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final trimmedName = message.authorName.trim();
                      final initial = trimmedName.isNotEmpty
                          ? String.fromCharCode(trimmedName.runes.first)
                          : '客';

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: CircleAvatar(child: Text(initial)),
                          title: Text(message.authorName),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _dateFormat.format(message.timestamp),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                  ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '昵称（选填）',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: '留言内容',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _submitMessage,
                      icon: const Icon(Icons.send),
                      label: const Text('发表'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
