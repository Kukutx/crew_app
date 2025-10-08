import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_share_sheet.dart';
import 'package:crew_app/features/user/presentation/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class EventDetailPage extends StatefulWidget {
  final Event event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  final GlobalKey _sharePreviewKey = GlobalKey();

  static const _fallbackHost = (
    name: 'Crew Host',
    bio: 'Crew · 活动主理人',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
  );

  bool _following = false;

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
        _sharePreviewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      await Share.share(shareText);
      if (!sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      return;
    }

    try {
      final ui.Image image =
          await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        await Share.share(shareText);
      } else {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'crew_event_share.png',
        );
        await Share.shareXFiles([xFile], text: shareText);
      }
    } catch (_) {
      await Share.share(shareText);
    }
    if (!sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
  }

  Future<void> _saveShareImage(BuildContext sheetContext) async {
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final loc = AppLocalizations.of(context)!;

    if (boundary == null) {
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
      return;
    }

    try {
      final ui.Image image = await boundary
          .toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (!sheetContext.mounted|| !mounted) return;
        Navigator.of(sheetContext).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
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

      final success = result is Map &&
          (result['isSuccess'] == true || result['success'] == true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? loc.share_save_success : loc.share_save_failure),
        ),
      );
    } catch (_) {
      if (!sheetContext.mounted || !mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
    }
  }

  void _showFeatureNotReadyMessage(AppLocalizations loc) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
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
                leading: const Icon(Icons.flag_outlined),
                title: Text(loc.report_issue),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showFeatureNotReadyMessage(loc);
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      extendBodyBehindAppBar: true,
      appBar: EventDetailAppBar(
        loc: loc,
        onBack: () => Navigator.pop(context),
        onShare: () => _showShareSheet(context),
        onMore: () => _showMoreActions(loc),
      ),
      bottomNavigationBar: EventDetailBottomBar(
        loc: loc,
        isFavorite: event.isFavorite,
        onFavorite: () => _showFeatureNotReadyMessage(loc),
        onRegister: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.registration_not_implemented)),
          );
        },
      ),
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
            SnackBar(
              content: Text(_following ? loc.followed : loc.unfollowed),
            ),
          );
        },
        isFollowing: _following,
        onTapLocation: () => Navigator.pop(context, widget.event),
      ),
    );
  }
}
