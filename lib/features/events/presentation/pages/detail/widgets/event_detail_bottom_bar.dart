import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailBottomBar extends StatelessWidget {
  final AppLocalizations loc;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onRegister;
  final VoidCallback onOpenPrivateChat;
  final VoidCallback onOpenGroupChat;
  final int favoriteCount;

  const EventDetailBottomBar({
    super.key,
    required this.loc,
    required this.isFavorite,
    required this.onFavorite,
    required this.onRegister,
    required this.onOpenPrivateChat,
    required this.onOpenGroupChat,
    this.favoriteCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localeTag = Localizations.localeOf(context).toString();
    final sanitizedCount = favoriteCount < 0 ? 0 : favoriteCount;
    final countLabel = NumberFormat.compact(
      locale: localeTag,
    ).format(sanitizedCount);
    final favoriteColor = colorScheme.secondary;
    final favoriteBackgroundColor = colorScheme.secondaryContainer.withValues(
      alpha: isFavorite ? 0.45 : 0.25,
    );
    final chatBackgroundColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.35,
    );
    final chatForegroundColor = colorScheme.onSurfaceVariant;
      return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // 前三个按钮组合，更紧凑
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PillActionButton(
                  onPressed: onFavorite,
                  backgroundColor: favoriteBackgroundColor,
                  foregroundColor: favoriteColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        countLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _PillActionButton(
                  onPressed: onOpenPrivateChat,
                  backgroundColor: chatBackgroundColor,
                  foregroundColor: chatForegroundColor,
                  child: const Icon(Icons.chat_bubble_outline, size: 20),
                ),
                const SizedBox(width: 6),
                _PillActionButton(
                  onPressed: onOpenGroupChat,
                  backgroundColor: chatBackgroundColor,
                  foregroundColor: chatForegroundColor,
                  child: const Icon(Icons.groups_2_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 注册按钮
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    loc.action_register,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;

  const _PillActionButton({
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: IconTheme(
        data: IconThemeData(color: foregroundColor, size: 20),
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.3,
            letterSpacing: 0,
          ),
          child: child,
        ),
      ),
    );
  }
}
