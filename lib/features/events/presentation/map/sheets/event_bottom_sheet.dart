// sheets/event_bottom_sheet.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/events_detail_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// 地图报名页 事件
void showEventBottomSheet({
  required BuildContext context,
  required Event event,
  ValueChanged<Event>? onShowOnMap,
}) {
  // Tips： 判断imageUrls是否有值，否则用coverImageUrl
  // (这是当前后端的问题，因为目前后端只有在创建的时候才会自动赋值coverImageUrl，而用SeedDataService预先插入的数据没用自动首页逻辑)，日后待看获取直接用event.coverImageUrl
  final imageUrl = (event.imageUrls.isNotEmpty)
      ? event.imageUrls.first
      : event.coverImageUrl;
  final loc = AppLocalizations.of(context)!;
  final locale = loc.localeName;
  final status = _resolveEventStatus(loc, event);
  final peopleLabel = event.peopleText ?? loc.to_be_announced;
  final timeLabel =
      event.formattedStartTime(locale, pattern: 'M.d HH:mm') ?? loc.to_be_announced;
  final registerLabel =
      status.isOpen ? loc.action_register_now : loc.event_registration_closed;

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
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (_, __, ___) =>
                                const Center(child: Icon(Icons.error)),
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
                                        child: Text(event.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.favorite_border),
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
                                _smallChip(status.label,
                                    backgroundColor: status.isOpen
                                        ? const Color(0xFFFFE7C2)
                                        : Colors.grey.shade200,
                                    textColor: status.isOpen
                                        ? Colors.black87
                                        : Colors.grey.shade600),
                                const SizedBox(width: 6),
                                const Icon(Icons.groups,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(peopleLabel,
                                    style:
                                        const TextStyle(color: Colors.black54)),
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
                                    onPressed: status.isOpen
                                        ? () {
                                            // TODO: 报名逻辑
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(loc
                                                    .registration_not_implemented),
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(registerLabel),
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

Widget _smallChip(String text,
        {Color backgroundColor = const Color(0xFFFFE7C2),
        Color textColor = Colors.black87}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(fontSize: 11, color: textColor)),
    );

class _EventStatusState {
  const _EventStatusState({
    required this.label,
    required this.isOpen,
  });

  final String label;
  final bool isOpen;
}

_EventStatusState _resolveEventStatus(AppLocalizations loc, Event event) {
  final lowerStatus = event.status?.toLowerCase();
  if (event.isFull || lowerStatus == 'full') {
    return _EventStatusState(label: loc.event_status_full, isOpen: false);
  }
  final now = DateTime.now();
  final hasStarted = event.startTime != null && event.startTime!.isBefore(now);
  if (lowerStatus == 'closed' || lowerStatus == 'ended' || hasStarted) {
    return _EventStatusState(label: loc.event_status_closed, isOpen: false);
  }
  return _EventStatusState(label: loc.registration_open, isOpen: true);
}
