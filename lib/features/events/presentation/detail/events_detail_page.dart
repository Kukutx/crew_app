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
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

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
  final SharePlus _sharePlus = SharePlus();

  final _host = (
    name: 'Luca B.',
    bio: 'Milan · 徒步/咖啡/摄影',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
    userId: 'user_123',
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
        onCopyLink: () => _copyShareLink(sheetContext),
        onShareSystem: () => _shareThroughSystem(sheetContext),
      ),
    );
  }

  Future<void> _shareThroughSystem(BuildContext sheetContext) async {
    final shareText = _buildShareMessage();
    final boundary =
        _sharePreviewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      await _sharePlus.share(shareText);
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
        await _sharePlus.share(shareText);
      } else {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'crew_event_share.png',
        );
        await _sharePlus.shareXFiles([xFile], text: shareText);
      }
    } catch (_) {
      await _sharePlus.share(shareText);
    }
    if (!mounted) return;
    Navigator.of(sheetContext).pop();
  }

  Future<void> _copyShareLink(BuildContext sheetContext) async {
    await Clipboard.setData(ClipboardData(text: _buildShareMessage()));
    if (!mounted) return;
    Navigator.of(sheetContext).pop();
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(loc.share_copy_success)));
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
        hostName: _host.name,
        hostBio: _host.bio,
        hostAvatarUrl: _host.avatar,
        onTapHostProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilePage(/*userId: _host.userId*/)),
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
