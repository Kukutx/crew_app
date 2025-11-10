import 'package:flutter/material.dart';
import 'package:crew_app/features/user/presentation/pages/guestbook/state/guestbook_provider.dart';
import 'package:crew_app/features/user/presentation/pages/guestbook/widgets/message_list.dart';
import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GuestbookPage extends ConsumerWidget {
  const GuestbookPage({super.key});

  Future<void> _openGuestbookComposer(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return GuestbookMessageComposerSheet(
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
      body: const GuestbookMessageList(),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () => _openGuestbookComposer(context, ref),
        child: const FaIcon(FontAwesomeIcons.penToSquare),
      ),
    );
  }
}
