import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations loc;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool isFavorite;
  final bool isFavoriteLoading;

  const EventDetailAppBar({
    super.key,
    required this.loc,
    required this.onBack,
    required this.onShare,
    required this.onFavorite,
    required this.isFavorite,
    required this.isFavoriteLoading,
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
          icon: isFavoriteLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.black,
                ),
          onPressed: isFavoriteLoading ? null : onFavorite,
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
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              loc.registration_open,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
