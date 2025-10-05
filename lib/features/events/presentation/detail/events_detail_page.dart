import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_share_sheet.dart';
import 'package:crew_app/features/user/presentation/user_profile_page.dart';
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
      if (!mounted) return;
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
    if (!mounted) return;
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
        if (!mounted) return;
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
      );

      if (!mounted) return;
      Navigator.of(sheetContext).pop();

      final success = result is Map &&
          (result['isSuccess'] == true || result['success'] == true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? loc.share_save_success : loc.share_save_failure),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.share_save_failure)));
    }
  }

  void _onFavoriteNotReady(AppLocalizations loc) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.feature_not_ready)));
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E9),
      extendBodyBehindAppBar: true,
      appBar: EventDetailAppBar(
        loc: loc,
        onBack: () => Navigator.pop(context),
        onShare: () => _showShareSheet(context),
        onFavorite: () => _onFavoriteNotReady(loc),
      ),
      bottomNavigationBar: EventDetailBottomBar(
        loc: loc,
        onFavorite: () => _onFavoriteNotReady(loc),
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
        hostName: event.organizerName?.isNotEmpty == true
            ? event.organizerName!
            : loc.unknown,
        hostBio: event.organizerBio?.isNotEmpty == true
            ? event.organizerBio!
            : loc.to_be_announced,
        hostAvatarUrl: event.organizerAvatar,
        followEnabled: false,
        onTapHostProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()),
          );
        },
        onToggleFollow: null,
        isFollowing: false,
        onTapLocation: () => Navigator.pop(context, widget.event),
      ),
    );
  }
}
