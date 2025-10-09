import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations loc;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const EventDetailAppBar({
    super.key,
    required this.loc,
    required this.onBack,
    required this.onShare,
    required this.onMore,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Colors.white;
    final iconBackground = Colors.black.withValues(alpha: 0.25);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: iconBackground,
          shape: const CircleBorder(),
        ),
        icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 20),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: iconBackground,
            shape: const CircleBorder(),
          ),
          icon: Icon(Icons.share_outlined, color: iconColor),
          onPressed: onShare,
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: iconBackground,
            shape: const CircleBorder(),
          ),
          icon: Icon(Icons.more_horiz, color: iconColor),
          onPressed: onMore,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              loc.registration_open,
              style: TextStyle(color: colorScheme.onPrimary, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
