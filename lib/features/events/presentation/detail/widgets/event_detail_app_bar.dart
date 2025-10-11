import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const EventDetailAppBar({
    super.key,
    required this.onBack,
    required this.onShare,
    required this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: onMore,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: const SizedBox.shrink(),
    );
  }
}
