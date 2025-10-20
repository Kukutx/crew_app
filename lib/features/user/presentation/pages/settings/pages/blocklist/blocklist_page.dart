import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String username;
  final String avatarUrl;
}

class BlockedUsersNotifier extends StateNotifier<List<BlockedUser>> {
  BlockedUsersNotifier()
      : super(const [
          BlockedUser(
            id: 'u_201',
            name: '沐晴',
            username: 'muxing',
            avatarUrl:
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1',
          ),
          BlockedUser(
            id: 'u_202',
            name: 'Harper',
            username: 'harper.outdoors',
            avatarUrl:
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          ),
          BlockedUser(
            id: 'u_203',
            name: 'Leo',
            username: 'leo_travels',
            avatarUrl:
                'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7',
          ),
        ]);

  void unblock(String userId) {
    state = [
      for (final user in state)
        if (user.id != userId) user,
    ];
  }
}

final blockedUsersProvider =
    StateNotifierProvider<BlockedUsersNotifier, List<BlockedUser>>(
  (ref) => BlockedUsersNotifier(),
);

class BlocklistPage extends ConsumerWidget {
  const BlocklistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsers = ref.watch(blockedUsersProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.blocklist_title),
      ),
      body: blockedUsers.isEmpty
          ? Center(
              child: Text(
                loc.blocklist_empty,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: blockedUsers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                  ),
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.red,
                    tooltip: loc.blocklist_unblock,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(loc.blocklist_unblock_confirm_title),
                          content: Text(
                            loc.blocklist_unblock_confirm_message(user.name),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(loc.action_cancel),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: Text(loc.blocklist_unblock),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        ref
                            .read(blockedUsersProvider.notifier)
                            .unblock(user.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                loc.blocklist_unblocked_snackbar(user.name),
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
