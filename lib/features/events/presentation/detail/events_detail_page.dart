import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_share_sheet.dart';
import 'package:crew_app/features/user/data/user_profile_summary.dart';
import 'package:crew_app/features/user/presentation/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

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

  static const _fallbackHost = (
    name: 'Crew Host',
    bio: 'Crew · 活动主理人',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
  );

  bool _following = false;
  bool _isLoadingHost = false;
  String? _loadingOrganizerId;
  UserProfileSummary? _hostProfile;

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
  void initState() {
    super.initState();
    _loadOrganizerProfile();
  }

  @override
  void didUpdateWidget(covariant EventDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldOrganizerId = (oldWidget.event.organizer?.id ?? '').trim();
    final newOrganizerId = (widget.event.organizer?.id ?? '').trim();
    if (oldWidget.event.id != widget.event.id || oldOrganizerId != newOrganizerId) {
      _loadOrganizerProfile(force: true);
    }
  }

  void _loadOrganizerProfile({bool force = false}) {
    final organizerId = (widget.event.organizer?.id ?? '').trim();
    if (organizerId.isEmpty) {
      if (force && mounted) {
        setState(() {
          _resetHostStateValues();
          _following = false;
        });
      }
      return;
    }
    if (!force && _hostProfile != null && _hostProfile!.id == organizerId) {
      return;
    }
    if (force && mounted) {
      setState(_resetHostStateValues);
    }
    Future.microtask(() => _fetchOrganizerProfile(organizerId));
  }

  void _resetHostStateValues() {
    _hostProfile = null;
    _isLoadingHost = false;
    _loadingOrganizerId = null;
  }

  Future<void> _fetchOrganizerProfile(String organizerId) async {
    _loadingOrganizerId = organizerId;
    if (mounted) {
      setState(() {
        _isLoadingHost = true;
      });
    }
    try {
      final profile =
          await ref.read(apiServiceProvider).getUserProfileSummary(organizerId);
      if (!mounted || _loadingOrganizerId != organizerId) {
        return;
      }
      final normalizedProfile = profile.isFollowing == null
          ? profile.copyWith(isFollowing: _following)
          : profile;
      setState(() {
        _hostProfile = normalizedProfile;
        _following = normalizedProfile.isFollowing ?? _following;
      });
    } catch (error) {
      if (!mounted || _loadingOrganizerId != organizerId) {
        return;
      }
      final message = _resolveErrorMessage(error);
      if (message != null) {
        _showSnackBar(message);
      }
    } finally {
      if (!mounted || _loadingOrganizerId != organizerId) {
        return;
      }
      setState(() {
        _isLoadingHost = false;
        _loadingOrganizerId = null;
      });
    }
  }

  String? _resolveErrorMessage(Object error) {
    if (error is ApiException && error.message.isNotEmpty) {
      return error.message;
    }
    final message = error.toString();
    if (message.isEmpty || message == 'null') {
      return null;
    }
    return message;
  }

  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  String? _nonEmpty(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
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
    final hostProfile = _hostProfile;
    final hostName = _nonEmpty(hostProfile?.name) ??
        ((organizer?.name.isNotEmpty ?? false)
            ? organizer!.name
            : _fallbackHost.name);
    final hostBio = _nonEmpty(hostProfile?.bio) ??
        ((organizer?.bio?.isNotEmpty ?? false)
            ? organizer!.bio!
            : _fallbackHost.bio);
    final hostAvatar = _nonEmpty(hostProfile?.avatarUrl) ??
        ((organizer?.avatarUrl?.isNotEmpty ?? false)
            ? organizer!.avatarUrl!
            : _fallbackHost.avatar);
    final isHostLoading = _isLoadingHost && hostProfile == null;
    final isFollowing = hostProfile?.isFollowing ?? _following;
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
        isFavorite: event.isFavorite,
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
          setState(() {
            _following = !_following;
            if (_hostProfile != null) {
              _hostProfile = _hostProfile!.copyWith(isFollowing: _following);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_following ? loc.followed : loc.unfollowed),
            ),
          );
        },
        isFollowing: isFollowing,
        isHostLoading: isHostLoading,
        onTapLocation: () => Navigator.pop(context, widget.event),
      ),
    );
  }
}
