import 'package:flutter/material.dart';

import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';

Future<void> showPlazaPostCommentsSheet(
  BuildContext context,
  PlazaPost post,
) {
  final theme = Theme.of(context);

  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '评论区',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: post.commentItems.isEmpty
                      ? Center(
                          child: Text(
                            '还没有评论，快来抢沙发吧～',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            final comment = post.commentItems[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: post.accentColor
                                      .withValues(alpha: 0.12),
                                  child: Text(
                                    comment.initials,
                                    style: TextStyle(
                                      color: post.accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              comment.author,
                                              style: theme
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            comment.timeLabel,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        comment.message,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemCount: post.commentItems.length,
                        ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: '来说点什么吧…',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    suffixIcon: Icon(
                      Icons.send,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  readOnly: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('演示模式下暂不支持评论提交'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
