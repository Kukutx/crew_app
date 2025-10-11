import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_host_card.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_media_carousel.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_info_card.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_plaza_card.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_summary_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'dart:math' as math;

import 'package:crew_app/features/events/presentation/detail/widgets/event_media_fullscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  });

  @override
  State<EventDetailBody> createState() => _EventDetailBodyState();
}

class _EventDetailBodyState extends State<EventDetailBody>
    with SingleTickerProviderStateMixin {
  static const double _baseHeaderHeight = 280;
  static const double _extraStretchHeight = 140;
  static const double _maxCornerRadius = 28;
  static const double _fullScreenTriggerOffset = 160;

  late final ScrollController _scrollController;
  late final AnimationController _headerStretchController;
  bool _navigatingToFullScreen = false;
  int _lastReportedPage = 0;

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
      duration: const Duration(milliseconds: 220),
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
    if (!_hasMedia) {
      if (_headerStretchController.value != 0) {
        _headerStretchController.animateTo(0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut);
      }
      return;
    }
    if (offset < 0) {
      final progress = math.min(1.0, -offset / _fullScreenTriggerOffset);
      if (_headerStretchController.value != progress) {
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
        _headerStretchController.animateTo(0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut);
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
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: EventMediaFullscreenPage(
              event: widget.event,
              initialPage: _lastReportedPage,
              heroTag: widget.heroTag,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 220),
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
    _headerStretchController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _handlePageChanged(int index) {
    _lastReportedPage = index;
    widget.onPageChanged(index);
  }

  double get _currentHeaderHeight =>
      _baseHeaderHeight + _extraStretchHeight * _headerStretchController.value;

  double get _currentCornerRadius =>
      _maxCornerRadius * (1 - _headerStretchController.value);

  double get _currentGradientOpacity =>
      0.25 + 0.55 * _headerStretchController.value;

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
                final height = _currentHeaderHeight;
                final radius = _currentCornerRadius;
                final gradientOpacity = _currentGradientOpacity;
                return Padding(
                  padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 0),
                  child: Semantics(
                    label: widget.event.title,
                    button: true,
                    child: GestureDetector(
                      onTap: _handleHeaderTap,
                      onVerticalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity < -650 && !_navigatingToFullScreen) {
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
                        flightShuttleBuilder: (_, animation, __, ___, toHero) {
                          return FadeTransition(
                            opacity: animation,
                            child: toHero.widget,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
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
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(gradientOpacity * 0.65),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                const SizedBox(height: 16),
                EventHostCard(
                  loc: widget.loc,
                  name: widget.hostName,
                  bio: widget.hostBio,
                  avatarUrl: widget.hostAvatarUrl,
                  onTapProfile: widget.onTapHostProfile,
                  onToggleFollow: widget.onToggleFollow,
                  isFollowing: widget.isFollowing,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: EventSummaryCard(event: widget.event, loc: widget.loc),
                ),
                const SizedBox(height: 10),
                EventInfoCard(
                  event: widget.event,
                  loc: widget.loc,
                  onTapLocation: widget.onTapLocation,
                ),
                const SizedBox(height: 10),
                EventPlazaCard(loc: widget.loc),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
