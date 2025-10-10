import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:crew_app/features/user/presentation/user_profile/profile_guestbook_provider.dart';

class ProfileGuestbook extends ConsumerWidget {
  const ProfileGuestbook({super.key});

  static const _emptyPlaceholder = '还没有留言，点击右下角的 “+” 来发表第一条吧！';

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分钟前';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} 小时前';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} 天前';
    }

    final formatter = DateFormat('yyyy年M月d日 HH:mm');
    return formatter.format(timestamp);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(profileGuestbookProvider);

    if (messages.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 120),
        children: const [
          Center(
            child: Text(
              _emptyPlaceholder,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final message = messages[index];
        final displayName = message.authorName.trim().isEmpty
            ? '匿名用户'
            : message.authorName.trim();
        final initial = displayName.characters.first;

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(initial),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(message.timestamp),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '更多操作',
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _GuestbookStat(
                      icon: Icons.favorite_border,
                      count: message.likes,
                    ),
                    const SizedBox(width: 16),
                    _GuestbookStat(
                      icon: Icons.mode_comment_outlined,
                      count: message.comments,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GuestbookStat extends StatelessWidget {
  const _GuestbookStat({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

class ProfileGuestbookComposerSheet extends StatefulWidget {
  const ProfileGuestbookComposerSheet({
    super.key,
    required this.onSubmit,
  });

  final void Function(String name, String content) onSubmit;

  @override
  State<ProfileGuestbookComposerSheet> createState() =>
      _ProfileGuestbookComposerSheetState();
}

class _ProfileGuestbookComposerSheetState
    extends State<ProfileGuestbookComposerSheet> {
  final TextEditingController _messageController = TextEditingController();

  String? _contentError;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _contentError = '请输入留言内容';
      });
      return;
    }

    setState(() {
      _contentError = null;
    });

    widget.onSubmit('匿名用户', message);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '发表留言',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              minLines: 4,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                labelText: '留言内容',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                errorText: _contentError,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.send),
              label: const Text('发表'),
            ),
          ],
        ),
      ),
    );
  }
}
