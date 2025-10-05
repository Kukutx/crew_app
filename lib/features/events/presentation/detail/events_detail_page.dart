import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/event_map_state/events_providers.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_share_sheet.dart';
import 'package:crew_app/features/profile/data/favorites_provider.dart';
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

  late Event _event;
  late bool _isFavorite;
  late bool _isFollowing;
  bool _favoriteLoading = false;
  bool _followLoading = false;

  String get _eventShareLink => 'https://crewapp.events/${widget.event.id}';

  String _buildShareMessage() {
    final event = widget.event;
    return '${event.title} · ${event.location}\n$_eventShareLink';
  }

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _isFavorite = widget.event.isFavorite;
    _isFollowing = widget.event.organizer?.isFollowed ?? false;
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleFavorite(AppLocalizations loc) async {
    if (_favoriteLoading) return;

    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      _showMessage(loc.not_logged_in);
      return;
    }

    if (_event.id.isEmpty) {
      _showMessage(loc.load_failed);
      return;
    }

    setState(() => _favoriteLoading = true);
    final api = ref.read(apiServiceProvider);

    try {
      if (_isFavorite) {
        await api.removeFavoriteEvent(currentUser.uid, _event.id);
      } else {
        await api.addFavoriteEvent(currentUser.uid, _event.id);
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _event = _event.copyWith(isFavorite: _isFavorite);
      });

      ref.invalidate(userFavoritesProvider);
      ref.invalidate(eventsProvider);

      _showMessage(
        _isFavorite ? loc.added_to_favorites : loc.removed_from_favorites,
      );
    } on ApiException catch (error) {
      final message =
          error.message.isNotEmpty ? error.message : loc.load_failed;
      _showMessage(message);
    } catch (_) {
      _showMessage(loc.load_failed);
    } finally {
      if (mounted) {
        setState(() => _favoriteLoading = false);
      }
    }
  }

  Future<void> _toggleFollow(AppLocalizations loc) async {
    if (_followLoading) return;

    final organizer = _event.organizer;
    if (organizer == null || organizer.id.isEmpty) {
      _showMessage(loc.load_failed);
      return;
    }

    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      _showMessage(loc.not_logged_in);
      return;
    }

    setState(() => _followLoading = true);
    final api = ref.read(apiServiceProvider);

    try {
      if (_isFollowing) {
        await api.unfollowUser(organizer.id);
      } else {
        await api.followUser(organizer.id);
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _event = _event.copyWith(
          organizer: organizer.copyWith(isFollowed: _isFollowing),
        );
      });

      _showMessage(_isFollowing ? loc.followed : loc.unfollowed);
    } on ApiException catch (error) {
      final message =
          error.message.isNotEmpty ? error.message : loc.load_failed;
      _showMessage(message);
    } catch (_) {
      _showMessage(loc.load_failed);
    } finally {
      if (mounted) {
        setState(() => _followLoading = false);
      }
    }
  }

  void _popWithResult() {
    Navigator.pop(context, _event);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
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
    return WillPopScope(
      onWillPop: () async {
        _popWithResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7E9),
        extendBodyBehindAppBar: true,
        appBar: EventDetailAppBar(
          loc: loc,
          onBack: _popWithResult,
          onShare: () => _showShareSheet(context),
          onFavorite: () => _toggleFavorite(loc),
          isFavorite: _isFavorite,
          isFavoriteLoading: _favoriteLoading,
        ),
        bottomNavigationBar: EventDetailBottomBar(
          loc: loc,
          isFavorite: _isFavorite,
          onFavorite: () => _toggleFavorite(loc),
          onRegister: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.registration_not_implemented)),
            );
          },
          isFavoriteLoading: _favoriteLoading,
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
          onToggleFollow: () => _toggleFollow(loc),
          isFollowing: _isFollowing,
          onTapLocation: () => _popWithResult(),
          followActionInProgress: _followLoading,
        ),
      ),
    );
  }
}
