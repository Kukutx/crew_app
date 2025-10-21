import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarPreviewOverlay extends StatelessWidget {
  const AvatarPreviewOverlay({
    super.key,
    required this.imageUrl,
    required this.changeLabel,
    required this.onCancel,
    required this.onChange,
  });

  final String imageUrl;
  final String changeLabel;
  final VoidCallback onCancel;
  final Future<void> Function() onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isEmpty
                        ? Container(
                            color: Colors.black26,
                            child: const Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.white,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onCancel,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: FilledButton(
                  onPressed: () async {
                    await onChange();
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(changeLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
