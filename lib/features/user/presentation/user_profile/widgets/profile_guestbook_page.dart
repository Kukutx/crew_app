import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/user/presentation/user_profile/state/profile_guestbook_provider.dart';
import 'package:crew_app/features/user/presentation/user_profile/widgets/profile_guestbook.dart';

class ProfileGuestbookPage extends ConsumerWidget {
  const ProfileGuestbookPage({super.key});

  Future<void> _openGuestbookComposer(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ProfileGuestbookComposerSheet(
          onSubmit: (name, content) {
            ref
                .read(profileGuestbookProvider.notifier)
                .addMessage(name, content);
          },
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('留言成功！')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('留言簿'),
      ),
      body: const ProfileGuestbook(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openGuestbookComposer(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
