// sheets/event_bottom_sheet.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/events_detail_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 地图报名页 事件
void showEventBottomSheet({
  required BuildContext context,
  required Event event,
  ValueChanged<Event>? onShowOnMap,
}) {
  final imageUrl = event.firstAvailableImageUrl;
  final loc = AppLocalizations.of(context)!;
  final participantSummary = event.participantSummary ?? loc.to_be_announced;
  final startTime = event.startTime;
  final timeLabel = startTime != null
      ? DateFormat('MM.dd HH:mm').format(startTime.toLocal())
      : loc.to_be_announced;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          child: ListView(
            controller: controller,
            children: [
              // 卡片
              Material(
                color: Colors.white,
                elevation: 0,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 缩略图
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  errorWidget: (_, __, ___) =>
                                      const Center(child: Icon(Icons.error)),
                                )
                              : const ColoredBox(
                                  color: Colors.black12,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 文本区
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题 + 收藏
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          final navigator = Navigator.of(context);
                                          navigator.pop(); // 先收起
                                          final result = await navigator.push<Event>(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EventDetailPage(event: event),
                                            ),
                                          );
                                          if (result != null) {
                                            onShowOnMap?.call(result);
                                          }
                                        },
                                        child: Text(
                                          event.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: Icon(event.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border),
                                      onPressed: () {
                                        // TODO: 收藏
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(loc.feature_not_ready),
                                          ),
                                        );
                                      },
                                    ),
                                  ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.place,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(event.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black54))),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                _smallChip(loc.registration_open),
                                const SizedBox(width: 6),
                                const Icon(Icons.groups,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(participantSummary,
                                    style: const TextStyle(color: Colors.black54)),
                              ]),
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.event,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(timeLabel,
                                    style:
                                        const TextStyle(color: Colors.black87)),
                                const Spacer(),
                                SizedBox(
                                  height: 36,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      // TODO: 报名逻辑
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              loc.registration_not_implemented),
                                        ),
                                      );
                                    },
                                    child: Text(loc.action_register_now),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    ]),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _smallChip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Color(0xFFFFE7C2), borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Colors.black87)),
    );
