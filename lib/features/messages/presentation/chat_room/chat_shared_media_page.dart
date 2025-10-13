import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatSharedMediaPage extends StatefulWidget {
  const ChatSharedMediaPage({
    super.key,
    required this.chatTitle,
    List<ChatSharedMediaItem>? items,
  }) : _items = items;

  final String chatTitle;
  final List<ChatSharedMediaItem>? _items;

  @override
  State<ChatSharedMediaPage> createState() => _ChatSharedMediaPageState();
}

enum ChatSharedMediaType { photo, video }

class ChatSharedMediaItem {
  const ChatSharedMediaItem({
    required this.id,
    required this.type,
    required this.assetPath,
    required this.senderDisplayName,
    required this.sentAtLabel,
    this.durationLabel,
  });

  final String id;
  final ChatSharedMediaType type;
  final String assetPath;
  final String senderDisplayName;
  final String sentAtLabel;
  final String? durationLabel;

  bool get isVideo => type == ChatSharedMediaType.video;
}

enum _ChatSharedMediaFilter { all, photos, videos }

class _ChatSharedMediaPageState extends State<ChatSharedMediaPage> {
  late final List<ChatSharedMediaItem> _allItems =
      widget._items ?? List<ChatSharedMediaItem>.unmodifiable(_demoMediaItems);
  _ChatSharedMediaFilter _filter = _ChatSharedMediaFilter.all;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filters = [
      (_ChatSharedMediaFilter.all, loc.chat_shared_media_filter_all),
      (_ChatSharedMediaFilter.photos, loc.chat_shared_media_filter_photos),
      (_ChatSharedMediaFilter.videos, loc.chat_shared_media_filter_videos),
    ];

    final filteredItems = _allItems.where((item) {
      switch (_filter) {
        case _ChatSharedMediaFilter.all:
          return true;
        case _ChatSharedMediaFilter.photos:
          return item.type == ChatSharedMediaType.photo;
        case _ChatSharedMediaFilter.videos:
          return item.isVideo;
      }
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.chat_settings_shared_files),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final filter in filters)
                      ChoiceChip(
                        label: Text(filter.$2),
                        selected: _filter == filter.$1,
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _filter = filter.$1);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filteredItems.isEmpty
                ? _ChatSharedMediaEmptyState(message: loc.chat_shared_media_empty)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: filteredItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: .82,
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _ChatSharedMediaTile(
                        item: item,
                        caption: loc.chat_shared_media_caption(
                          item.senderDisplayName,
                          item.sentAtLabel,
                        ),
                        typeLabel: item.isVideo
                            ? loc.chat_shared_media_filter_videos
                            : loc.chat_shared_media_filter_photos,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatSharedMediaTile extends StatelessWidget {
  const _ChatSharedMediaTile({
    required this.item,
    required this.caption,
    required this.typeLabel,
  });

  final ChatSharedMediaItem item;
  final String caption;
  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                  ),
                  child: Image.asset(
                    item.assetPath,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isVideo
                                ? Icons.videocam_outlined
                                : Icons.photo_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                          if (item.isVideo && item.durationLabel != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.durationLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: .55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        caption,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          typeLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChatSharedMediaEmptyState extends StatelessWidget {
  const _ChatSharedMediaEmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

const List<ChatSharedMediaItem> _demoMediaItems = [
  ChatSharedMediaItem(
    id: 'media-1',
    type: ChatSharedMediaType.photo,
    assetPath: 'assets/images/Image_20250917233011_307_216.png',
    senderDisplayName: '林雨晴',
    sentAtLabel: '昨天 19:21',
  ),
  ChatSharedMediaItem(
    id: 'media-2',
    type: ChatSharedMediaType.video,
    assetPath: 'assets/images/crew.png',
    senderDisplayName: 'Marco',
    sentAtLabel: '周二 14:05',
    durationLabel: '0:42',
  ),
  ChatSharedMediaItem(
    id: 'media-3',
    type: ChatSharedMediaType.photo,
    assetPath: 'assets/images/Image_20250917233011_307_216.png',
    senderDisplayName: '陈小岚',
    sentAtLabel: '周一 21:18',
  ),
  ChatSharedMediaItem(
    id: 'media-4',
    type: ChatSharedMediaType.video,
    assetPath: 'assets/images/crew.png',
    senderDisplayName: '我',
    sentAtLabel: '周一 08:36',
    durationLabel: '1:12',
  ),
  ChatSharedMediaItem(
    id: 'media-5',
    type: ChatSharedMediaType.photo,
    assetPath: 'assets/images/Image_20250917233011_307_216.png',
    senderDisplayName: '春天一起去爬山吧！',
    sentAtLabel: '周日 17:08',
  ),
];
