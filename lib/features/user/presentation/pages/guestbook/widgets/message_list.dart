import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:crew_app/features/user/presentation/pages/guestbook/state/guestbook_providers.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';

/// Neumorphism 装饰工具
class _NeumorphismDecoration {
  static BoxDecoration card(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = theme.colorScheme.surface;
    
    return BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        // 暗色阴影（右下）
        BoxShadow(
          color: isDark 
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.15),
          offset: const Offset(6, 6),
          blurRadius: 16,
          spreadRadius: -4,
        ),
        // 亮色高光（左上）
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.8),
          offset: const Offset(-6, -6),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ],
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        width: 1,
      ),
    );
  }
}

class GuestbookMessageList extends ConsumerWidget {
  const GuestbookMessageList({super.key});

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

  void _openEditComposer(BuildContext context, WidgetRef ref, ProfileMessage message) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return GuestbookMessageComposerSheet(
          initialMessage: message,
          onSubmit: (name, content) {
            ref.read(profileGuestbookProvider.notifier).updateMessage(message.id, content);
          },
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, String messageId) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条留言吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(profileGuestbookProvider.notifier).deleteMessage(messageId);
              Navigator.of(dialogContext).pop(true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功！')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(profileGuestbookProvider);

    if (messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 120),
          child: Text(
            _emptyPlaceholder,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).hintColor,
              height: 1.6,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final message = messages[index];
        final displayName = message.authorName.trim().isEmpty
            ? '匿名用户'
            : message.authorName.trim();
        final initial = displayName.characters.first;

        return Container(
          decoration: _NeumorphismDecoration.card(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CrewAvatar(
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
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openEditComposer(context, ref, message);
                        } else if (value == 'delete') {
                          _showDeleteConfirm(context, ref, message.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('编辑'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: 8),
                              Text('删除'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
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
          count.toCompactString(),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

class GuestbookMessageComposerSheet extends StatefulWidget {
  const GuestbookMessageComposerSheet({
    super.key,
    required this.onSubmit,
    this.initialMessage,
  });

  final void Function(String name, String content) onSubmit;
  final ProfileMessage? initialMessage;

  @override
  State<GuestbookMessageComposerSheet> createState() =>
      _GuestbookMessageComposerSheetState();
}

class _GuestbookMessageComposerSheetState
    extends State<GuestbookMessageComposerSheet> {
  late final TextEditingController _messageController;

  String? _contentError;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: widget.initialMessage?.content ?? '',
    );
  }

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

    final displayName = widget.initialMessage?.authorName ?? '匿名用户';
    widget.onSubmit(displayName, message);
    Navigator.of(context).pop(true);
    
    if (widget.initialMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('编辑成功！')),
      );
    }
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
              widget.initialMessage != null ? '编辑留言' : '发表留言',
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
              icon: Icon(widget.initialMessage != null ? Icons.check : Icons.send),
              label: Text(widget.initialMessage != null ? '保存' : '发表'),
            ),
          ],
        ),
      ),
    );
  }
}
