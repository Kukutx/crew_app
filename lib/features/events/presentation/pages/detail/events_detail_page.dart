import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/pages/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/events/presentation/pages/detail/sheets/event_share_sheet.dart';
import 'package:crew_app/features/events/presentation/sheets/create_moment_sheet.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/shared/widgets/sheets/report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  final GlobalKey _sharePreviewKey = GlobalKey();
  SystemUiOverlayStyle? _previousOverlayStyle;
  bool _hasPrefetchedCover = false;

  static const _fallbackHost = (
    name: 'Crew Host',
    bio: 'Crew · 活动主理人',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
  );

  bool _following = false;

  @override
  void initState() {
    super.initState();
    _captureCurrentOverlayStyle();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _captureCurrentOverlayStyle() {
    // The framework does not expose the currently applied overlay style, so
    // we best-effort remember the most recently set value via
    // WidgetsBindingObserver. This page always sets a transparent status bar
    // with light icons and restores a dark style on dispose to avoid leaving
    // the app in an unexpected state.
    _previousOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasPrefetchedCover) {
      return;
    }

    final url = widget.event.firstAvailableImageUrl;
    if (url != null && url.isNotEmpty) {
      _hasPrefetchedCover = true;
      final mq = MediaQuery.of(context);
      final targetHeight =
          (mq.size.width * mq.devicePixelRatio).round();
      final provider = CachedNetworkImageProvider(
        url,
        maxHeight: targetHeight,
        maxWidth: targetHeight,
      );
      unawaited(
        precacheImage(
          provider,
          context,
          onError: (error, stackTrace) {
            debugPrint('Failed to precache event image: $error');
          },
        ),
      );
    }
  }

  String get _eventShareLink => 'https://crewapp.events/${widget.event.id}';

  String _buildShareMessage() {
    final event = widget.event;
    return '${event.title} · ${event.location}\n$_eventShareLink';
  }

  void _showShareSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EventShareSheet(
        event: widget.event,
        loc: loc,
        previewKey: _sharePreviewKey,
        shareLink: _eventShareLink,
        onSaveImage: () => _saveShareImage(sheetContext),
        onShareSystem: () => _shareThroughSystem(sheetContext),
      ),
    );
  }

  Future<void> _shareThroughSystem(BuildContext sheetContext) async {
    final shareText = _buildShareMessage();
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      await SharePlus.instance.share(ShareParams(text: shareText));
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      return;
    }

    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        await SharePlus.instance.share(ShareParams(text: shareText));
      } else {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'crew_event_share.png',
        );
        await SharePlus.instance.share(
          ShareParams(text: shareText, files: [xFile]),
        );
      }
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: shareText));
    }
    if (!sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
  }

  Future<void> _saveShareImage(BuildContext sheetContext) async {
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    final loc = AppLocalizations.of(context)!;

    if (boundary == null) {
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
      return;
    }

    try {
      final ui.Image image = await boundary.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        if (!sheetContext.mounted || !mounted) return;
        Navigator.of(sheetContext).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        name: 'crew_event_${widget.event.id}',
        quality: 100,
        isReturnImagePathOfIOS: true,
      );

      if (!sheetContext.mounted || !mounted) return;
      Navigator.of(sheetContext).pop();

      final success =
          result is Map &&
          (result['isSuccess'] == true || result['success'] == true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? loc.share_save_success : loc.share_save_failure,
          ),
        ),
      );
    } catch (_) {
      if (!sheetContext.mounted || !mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
    }
  }

  Future<void> _showReportIssueSheet(AppLocalizations loc) async {
    final submission = await ReportSheet.show(
      context: context,
      title: loc.report_issue,
      description: loc.report_issue_description,
      typeLabel: loc.report_event_type_label,
      typeEmptyHint: loc.report_event_type_required,
      contentLabel: loc.report_event_content_label,
      contentHint: loc.report_event_content_hint,
      attachmentLabel: loc.report_event_attachment_label,
      attachmentOptional: loc.report_event_attachment_optional,
      attachmentAddLabel: loc.report_event_attachment_add,
      attachmentReplaceLabel: loc.report_event_attachment_replace,
      attachmentEmptyLabel: loc.report_event_attachment_empty,
      submitLabel: loc.report_event_submit,
      cancelLabel: loc.action_cancel,
      reportTypes: [
        loc.report_event_type_misinformation,
        loc.report_event_type_illegal,
        loc.report_event_type_fraud,
        loc.report_event_type_other,
      ],
      imagePicker: ImagePicker(),
    );

    if (!mounted || submission == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.report_event_submit_success),
      ),
    );
  }

  void _showFeatureNotReadyMessage(AppLocalizations loc) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
  }

  void _showOrganizerDisclaimer() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('发起人免责声明'),
          content: const Text(
            '本活动由发起人自行发布并负责组织，Crew 仅提供信息展示与沟通工具。'
            '请在参与前自行核实活动详情与安全保障，并根据自身情况评估风险。'
            '如遇异常情况或争议，请及时与发起人沟通或联系 Crew 寻求协助。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
  }

  void _showMoreActions(AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  final event = widget.event;
                  final start = event.startTime ?? DateTime.now();
                  final end = event.endTime != null && event.endTime!.isAfter(start)
                      ? event.endTime!
                      : start.add(const Duration(hours: 4));
                  final draft = RoadTripDraft(
                    id: event.id,
                    title: event.title,
                    dateRange: DateTimeRange(start: start, end: end),
                    startLocation: event.location,
                    endLocation: event.waypoints.isNotEmpty
                        ? event.waypoints.last
                        : event.location,
                    meetingPoint: event.address ?? event.location,
                    isRoundTrip: event.isRoundTrip ?? true,
                    waypoints: event.waypoints,
                    maxParticipants: event.maxParticipants ?? 4,
                    isFree: event.isFree,
                    pricePerPerson: event.isFree ? null : event.price,
                    carType: null,
                    tags: event.tags,
                    description: event.description,
                    existingImageUrls: event.imageUrls,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (routeContext) => RoadTripEditorPage(
                        onClose: () => Navigator.of(routeContext).pop(),
                        initialValue: draft,
                        onSubmit: (input) async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('活动编辑提交暂未接入后端')),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('活动删除暂未接入后端')),
                  );
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(loc.report_issue),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showReportIssueSheet(loc);
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(loc.action_cancel),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    if (_previousOverlayStyle != null) {
      SystemChrome.setSystemUIOverlayStyle(_previousOverlayStyle!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = AppLocalizations.of(context)!;
    final organizer = event.organizer;
    final hostName = (organizer?.name.isNotEmpty ?? false)
        ? organizer!.name
        : _fallbackHost.name;
    final hostBio = (organizer?.bio?.isNotEmpty ?? false)
        ? organizer!.bio!
        : _fallbackHost.bio;
    final hostAvatar = (organizer?.avatarUrl?.isNotEmpty ?? false)
        ? organizer!.avatarUrl!
        : _fallbackHost.avatar;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: EventDetailAppBar(
        onBack: () => Navigator.pop(context),
        onShare: () => _showShareSheet(context),
        onMore: () => _showMoreActions(loc),
        event: event,
      ),
      bottomNavigationBar: EventDetailBottomBar(
        loc: loc,
        isFavorite: event.isFavorite,
        favoriteCount: event.favoriteCount,
        onFavorite: () => _showFeatureNotReadyMessage(loc),
        onRegister: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.registration_not_implemented)),
          );
        },
        onOpenPrivateChat: () => _showFeatureNotReadyMessage(loc),
        onOpenGroupChat: () => _showFeatureNotReadyMessage(loc),
      ),
      floatingActionButton: _PlazaPostFab(
        label: loc.event_detail_publish_plaza,
        onPressed: () => showCreateMomentSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: EventDetailBody(
        event: event,
        loc: loc,
        pageController: _pageCtrl,
        currentPage: _page,
        onPageChanged: (index) => setState(() => _page = index),
        hostName: hostName,
        hostBio: hostBio,
        hostAvatarUrl: hostAvatar,
        onTapHostProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilePage()),
          );
        },
        onToggleFollow: () async {
          // TODO: integrate backend follow logic
          setState(() => _following = !_following);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_following ? loc.followed : loc.unfollowed)),
          );
        },
        isFollowing: _following,
        onTapLocation: () => Navigator.pop(context, widget.event),
        heroTag: 'event-media-${event.id}',
        onShowOrganizerDisclaimer: _showOrganizerDisclaimer,
      ),
    );
  }
}

class _PlazaPostFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PlazaPostFab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppFloatingActionButton(
      onPressed: onPressed,
      tooltip: label,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const Icon(Icons.add),
    );
  }
}
