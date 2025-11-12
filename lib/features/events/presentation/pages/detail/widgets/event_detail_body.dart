import 'dart:math' as math;

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_content_tabs.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_detail_constants.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_host_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_info_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_carousel.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_fullscreen_page.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_meeting_point_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_summary_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class EventDetailBody extends StatefulWidget {
  final Event event;
  final AppLocalizations loc;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String hostName;
  final String hostBio;
  final String hostAvatarUrl;
  final VoidCallback onTapHostProfile;
  final VoidCallback onToggleFollow;
  final bool isFollowing;
  final VoidCallback onTapLocation;
  final String heroTag;
  final VoidCallback onShowOrganizerDisclaimer;

  const EventDetailBody({
    super.key,
    required this.event,
    required this.loc,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.hostName,
    required this.hostBio,
    required this.hostAvatarUrl,
    required this.onTapHostProfile,
    required this.onToggleFollow,
    required this.isFollowing,
    required this.onTapLocation,
    required this.heroTag,
    required this.onShowOrganizerDisclaimer,
  });

  @override
  State<EventDetailBody> createState() => _EventDetailBodyState();
}

class _EventDetailBodyState extends State<EventDetailBody>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _headerStretchController;
  bool _navigatingToFullScreen = false;
  int _lastReportedPage = 0;
  double _lastOffset = 0.0;

  int get _mediaCount {
    final imageCount = widget.event.imageUrls
        .where((url) => url.trim().isNotEmpty)
        .length;
    final videoCount = widget.event.videoUrls
        .where((url) => url.trim().isNotEmpty)
        .length;
    return imageCount + videoCount;
  }

  bool get _hasMedia => _mediaCount > 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerStretchController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 0,
      duration: EventDetailConstants.headerStretchDuration,
    );
    _scrollController.addListener(_handleScroll);
    _lastReportedPage = widget.currentPage;
  }

  @override
  void didUpdateWidget(covariant EventDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _lastReportedPage = widget.currentPage;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _headerStretchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final offset = _scrollController.offset;
    
    // 性能优化：只在偏移量变化足够大时才更新
    if ((offset - _lastOffset).abs() < 0.5) {
      return;
    }
    _lastOffset = offset;
    
    if (!_hasMedia) {
      if (_headerStretchController.value != 0) {
        _headerStretchController.animateTo(
          0,
          duration: EventDetailConstants.headerStretchResetDuration,
          curve: Curves.easeOut,
        );
      }
      return;
    }
    
    if (offset < 0) {
      final progress = math.min(
        1.0,
        -offset / EventDetailConstants.fullScreenTriggerOffset,
      );
      // 只在值变化足够大时才更新，减少不必要的重建
      if ((_headerStretchController.value - progress).abs() > 0.01) {
        _headerStretchController.value = progress;
      }
      if (!_navigatingToFullScreen && progress >= 1.0) {
        debugPrint('Analytics: event_fullscreen_threshold_${widget.event.id}');
        _navigatingToFullScreen = true;
        HapticFeedback.mediumImpact();
        _openFullScreen();
      }
    } else {
      if (_headerStretchController.value != 0) {
        _headerStretchController.animateTo(
          0,
          duration: EventDetailConstants.headerStretchResetDuration,
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _openFullScreen() async {
    if (!_hasMedia) {
      _navigatingToFullScreen = false;
      return;
    }
    debugPrint('Analytics: event_fullscreen_enter_${widget.event.id}');
    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: EventMediaFullscreenScreen(
              event: widget.event,
              initialPage: _lastReportedPage,
              heroTag: widget.heroTag,
            ),
          );
        },
        transitionDuration: EventDetailConstants.fullscreenTransitionDuration,
        reverseTransitionDuration:
            EventDetailConstants.fullscreenTransitionDuration,
      ),
    );
    if (!mounted) return;
    debugPrint('Analytics: event_fullscreen_exit_${widget.event.id}');
    _navigatingToFullScreen = false;
    if (result != null && _hasMedia) {
      final targetIndex = result.clamp(0, _mediaCount - 1);
      if (widget.pageController.hasClients) {
        widget.pageController.jumpToPage(targetIndex);
      }
      _handlePageChanged(targetIndex);
    }
    _headerStretchController.animateTo(
      0,
      duration: EventDetailConstants.headerStretchResetDuration,
      curve: Curves.easeOut,
    );
  }

  void _handlePageChanged(int index) {
    _lastReportedPage = index;
    widget.onPageChanged(index);
  }

  void _openGroupExpensePage() {
    if (!mounted) {
      return;
    }
    context.push(AppRoutePaths.expenses);
  }

  double get _currentHeaderHeight =>
      EventDetailConstants.baseHeaderHeight +
      EventDetailConstants.extraStretchHeight *
          _headerStretchController.value;

  double get _currentCornerRadius =>
      EventDetailConstants.maxCornerRadius *
      (0.6 - _headerStretchController.value);

  double get _currentGradientOpacity =>
      EventDetailConstants.gradientOpacityMin +
      (EventDetailConstants.gradientOpacityMax -
              EventDetailConstants.gradientOpacityMin) *
          _headerStretchController.value;

  void _handleHeaderTap() {
    if (_navigatingToFullScreen || !_hasMedia) {
      return;
    }
    HapticFeedback.mediumImpact();
    _navigatingToFullScreen = true;
    _openFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _headerStretchController,
              builder: (context, child) {
                final height = topInset + _currentHeaderHeight;
                final radius = _currentCornerRadius;
                final gradientOpacity = _currentGradientOpacity;
                return Semantics(
                  label: widget.event.title,
                  button: true,
                  child: GestureDetector(
                    onTap: _handleHeaderTap,
                    onVerticalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity < -EventDetailConstants.verticalDragVelocityThreshold &&
                          !_navigatingToFullScreen) {
                        if (!_hasMedia) {
                          return;
                        }
                        _navigatingToFullScreen = true;
                        HapticFeedback.mediumImpact();
                        _openFullScreen();
                      }
                    },
                    child: Hero(
                      tag: widget.heroTag,
                      flightShuttleBuilder: (_, animation, _, _, toHero) {
                        return FadeTransition(
                          opacity: animation,
                          child: toHero.widget,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(radius),
                          bottomRight: Radius.circular(radius),
                        ),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: height,
                              width: double.infinity,
                              child: EventMediaCarousel(
                                event: widget.event,
                                controller: widget.pageController,
                                currentPage: widget.currentPage,
                                onPageChanged: _handlePageChanged,
                                height: height,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                ignoring: true,
                                child: Container(
                                  height: topInset +
                                      EventDetailConstants.topGradientHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(
                                          alpha: math.min(1.0, gradientOpacity * 0.9),
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 12),
                EventHostCard(
                  loc: widget.loc,
                  name: widget.hostName,
                  bio: widget.hostBio,
                  avatarUrl: widget.hostAvatarUrl,
                  onTapProfile: widget.onTapHostProfile,
                  onToggleFollow: widget.onToggleFollow,
                  isFollowing: widget.isFollowing,
                ),
                const SizedBox(height: EventDetailConstants.sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  child: EventSummaryCard(
                    event: widget.event,
                    loc: widget.loc,
                    onTapCalculate: _openGroupExpensePage,
                  ),
                ),
                const SizedBox(height: EventDetailConstants.sectionSpacing),
                EventMeetingPointCard(
                  loc: widget.loc,
                  meetingPoint: widget.event.address?.isNotEmpty == true
                      ? widget.event.address!
                      : widget.event.location,
                  onViewOnMap: widget.onTapLocation,
                ),
                const SizedBox(height: EventDetailConstants.sectionSpacing),
                EventInfoCard(
                  event: widget.event,
                  loc: widget.loc,
                ),
                const SizedBox(height: EventDetailConstants.sectionSpacing),
                EventContentTabs(loc: widget.loc),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: widget.onShowOrganizerDisclaimer,
                    child: Text(widget.loc.event_organizer_disclaimer_title),
                  ),
                ),
                const SizedBox(height: EventDetailConstants.bottomSpacing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
