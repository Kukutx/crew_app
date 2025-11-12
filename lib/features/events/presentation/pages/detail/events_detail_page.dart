import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_app_bar.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_body.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_bottom_bar.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_constants.dart';
import 'package:crew_app/features/events/presentation/pages/detail/sheets/event_share_sheet.dart';
import 'package:crew_app/features/events/presentation/widgets/moment/widgets/create_moment_screen.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/road_trip_editor_page.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/shared/utils/image_share_helper.dart';
import 'package:crew_app/shared/widgets/buttons/app_floating_action_button.dart';
import 'package:crew_app/shared/widgets/sheets/report_sheet/report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  bool _following = false;

  static const _fallbackHost = (
    name: 'Crew Host',
    bio: 'Crew · 活动主理人',
    avatar: 'https://images.unsplash.com/photo-1502685104226-ee32379fefbe',
  );

  @override
  void initState() {
    super.initState();
    _captureCurrentOverlayStyle();
    SystemChrome.setSystemUIOverlayStyle(
      EventDetailConstants.transparentStatusBar,
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
    final url = widget.event.firstAvailableImageUrl;
    if (url != null && url.isNotEmpty) {
      precacheImage(
        Image.network(url).image,
        context,
        onError: (error, stackTrace) {
          debugPrint('Failed to precache event image: $error');
        },
      );
    }
  }

  String get _eventShareLink => 'https://crewapp.events/${widget.event.id}';

  String _buildShareMessage() {
    return '${widget.event.title} · ${widget.event.location}\n$_eventShareLink';
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
    
    final success = await ImageShareHelper.shareImageWithText(
      context: context,
      key: _sharePreviewKey,
      shareText: shareText,
      onError: (error) {
        if (mounted && sheetContext.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
    );
    
    if (!sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
    
    if (!success && mounted) {
      ref.read(talkerProvider).error('Share failed', StackTrace.current);
    }
  }

  Future<void> _saveShareImage(BuildContext sheetContext) async {
    final loc = AppLocalizations.of(context)!;
    final success = await ImageShareHelper.saveImageToGallery(
      context: context,
      key: _sharePreviewKey,
      fileName: '${EventDetailConstants.shareImageNamePrefix}${widget.event.id}',
      onSuccess: () {
        if (mounted && sheetContext.mounted) {
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.share_save_success)),
          );
        }
      },
      onError: (error) {
        if (mounted && sheetContext.mounted) {
          Navigator.of(sheetContext).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.share_save_failure)),
          );
        }
        if (mounted) {
          ref.read(talkerProvider).error(error, StackTrace.current);
        }
      },
    );
    
    if (!success && !sheetContext.mounted) {
      // 如果失败且 sheet 已关闭，不再显示错误提示
      return;
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
    final loc = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(loc.event_organizer_disclaimer_title),
          content: Text(loc.event_organizer_disclaimer_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.event_organizer_disclaimer_acknowledge),
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
                title: Text(loc.event_action_edit),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  final event = widget.event;
                  final start = event.startTime ?? DateTime.now();
                  final end = event.endTime != null && event.endTime!.isAfter(start)
                      ? event.endTime!
                      : start.add(const Duration(hours: 4));
                  // 从 waypointSegments 构建 segments
                  final segments = event.waypointSegments
                      .map((segment) => EventWaypointSegment(
                            coordinate: '${segment.latitude},${segment.longitude}',
                            direction: segment.direction,
                            order: segment.seq,
                          ))
                      .toList();

                  // 从 segments 获取终点位置
                  String endLocationStr = event.location;
                  if (segments.isNotEmpty) {
                    final lastSegment = segments.last;
                    endLocationStr = lastSegment.coordinate;
                  }

                  final draft = RoadTripDraft(
                    id: event.id,
                    title: event.title,
                    dateRange: DateTimeRange(start: start, end: end),
                    startLocation: event.location,
                    endLocation: endLocationStr,
                    meetingPoint: event.address ?? event.location,
                    isRoundTrip: event.isRoundTrip ?? true,
                    segments: segments,
                    maxMembers: event.maxMembers ?? 4,
                    isFree: event.isFree,
                    pricePerPerson: event.isFree ? null : event.price,
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
                            SnackBar(content: Text(loc.event_edit_not_implemented)),
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
                title: Text(loc.event_action_delete),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.event_delete_not_implemented)),
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
    final host = event.host;
    final hostName = (host?.name.isNotEmpty ?? false)
        ? host!.name
        : _fallbackHost.name;
    final hostBio = (host?.bio?.isNotEmpty ?? false)
        ? (host!.bio ?? _fallbackHost.bio)
        : _fallbackHost.bio;
    final hostAvatar = (host?.avatarUrl?.isNotEmpty ?? false)
        ? (host!.avatarUrl ?? _fallbackHost.avatar)
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
      floatingActionButton: _MomentPostFab(
        label: loc.event_detail_publish_plaza,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateMomentScreen(),
            ),
          );
        },
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
        onToggleFollow: () {
          // TODO: integrate backend follow logic
          setState(() => _following = !_following);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_following ? loc.followed : loc.unfollowed),
              ),
            );
          }
        },
        isFollowing: _following,
        onTapLocation: () => Navigator.pop(context, widget.event),
        heroTag: 'event-media-${event.id}',
        onShowOrganizerDisclaimer: _showOrganizerDisclaimer,
      ),
    );
  }
}

class _MomentPostFab extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _MomentPostFab({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppFloatingActionButton(
      onPressed: onPressed,
      tooltip: label,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      child: const Icon(Icons.camera_alt),
    );
  }
}
