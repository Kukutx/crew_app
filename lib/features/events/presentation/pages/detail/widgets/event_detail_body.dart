import 'dart:async';

import 'package:crew_app/features/events/data/event.dart';

import 'package:crew_app/features/events/presentation/pages/detail/controllers/event_detail_interaction_controller.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_host_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_info_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_plaza_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_summary_card.dart';
import 'package:crew_app/features/events/presentation/sheets/event_cost_calculator_sheet.dart';
import 'package:crew_app/features/events/presentation/widgets/event_media_header.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_fullscreen_page.dart';
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
  final bool isFollowBusy;
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
    required this.isFollowBusy,
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
  late EventDetailInteractionController _interactionController;
  int _lastReportedPage = 0;
  late int _mediaCount;
  bool _hasMedia = false;

  int _computeMediaCount(Event event) {
    final urls = <String>{};
    urls.addAll(
      event.imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
    );
    urls.addAll(
      event.videoUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
    );
    return urls.length;
  }

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
    _mediaCount = _computeMediaCount(widget.event);
    _hasMedia = _mediaCount > 0;
    _interactionController = EventDetailInteractionController(
      eventId: widget.event.id,
      openFullScreen: _openFullScreen,
      onFullScreenClosed: _handleFullScreenClosed,
    );
  }

  @override
  void didUpdateWidget(covariant EventDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _lastReportedPage = widget.currentPage;
    }
    if (oldWidget.event != widget.event) {
      _mediaCount = _computeMediaCount(widget.event);
      _hasMedia = _mediaCount > 0;
      if (oldWidget.event.id != widget.event.id) {
        _interactionController = EventDetailInteractionController(
          eventId: widget.event.id,
          openFullScreen: _openFullScreen,
          onFullScreenClosed: _handleFullScreenClosed,
        );
      }
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
        _headerStretchController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
      return;
    }
    if (offset < 0) {
      final progress = (-offset / _fullScreenTriggerOffset).clamp(0.0, 1.0);
      if (_headerStretchController.value != progress) {
        _headerStretchController.value = progress;
      }
      if (progress >= 1.0) {
        unawaited(_interactionController.handleStretchProgress(progress));
      }
    } else {
      if (_headerStretchController.value != 0) {
        _headerStretchController.animateTo(
          0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<int?> _openFullScreen() async {
    if (!_hasMedia || !mounted) {
      return null;
    }
    debugPrint('Analytics: event_fullscreen_enter_${widget.event.id}');
    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        pageBuilder: (_, animation, _) {
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
    return result;
  }

  void _handleFullScreenClosed(int? result) {
    if (!mounted) return;
    if (result != null && _hasMedia) {
      final targetIndex = result.clamp(0, _mediaCount - 1);
      if (widget.pageController.hasClients) {
        widget.pageController.jumpToPage(targetIndex);
      }
      _handlePageChanged(targetIndex);
    }
    _headerStretchController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _handlePageChanged(int index) {
    _lastReportedPage = index;
    widget.onPageChanged(index);
  }

  void _showCostCalculator() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EventCostCalculatorSheet(
        event: widget.event,
        loc: widget.loc,
      ),
    );
  }

  void _handleHeaderTap() {
    if (!_hasMedia) {
      return;
    }
    unawaited(_interactionController.handleTap());
  }

  void _handleKeyboardNavigation(int delta) {
    if (!_hasMedia || !widget.pageController.hasClients) {
      return;
    }
    final target = (widget.currentPage + delta).clamp(0, _mediaCount - 1);
    if (target == widget.currentPage) {
      return;
    }
    widget.pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
    _handlePageChanged(target);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final shortcutBindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
          _handleKeyboardNavigation(-1),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
          _handleKeyboardNavigation(1),
    };

    final contentSliver = SliverPadding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            switch (index) {
              case 0:
                return EventHostCard(
                  loc: widget.loc,
                  name: widget.hostName,
                  bio: widget.hostBio,
                  avatarUrl: widget.hostAvatarUrl,
                  onTapProfile: widget.onTapHostProfile,
                  onToggleFollow: widget.onToggleFollow,
                  isFollowing: widget.isFollowing,
                  isFollowBusy: widget.isFollowBusy,
                );
              case 1:
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: EventSummaryCard(
                    event: widget.event,
                    loc: widget.loc,
                  ),
                );
              case 2:
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: EventInfoCard(
                    event: widget.event,
                    loc: widget.loc,
                    onTapLocation: widget.onTapLocation,
                    onTapCostCalculator: _showCostCalculator,
                  ),
                );
              case 3:
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: EventPlazaCard(loc: widget.loc),
                );
              default:
                return const SizedBox.shrink();
            }
          },
          childCount: 4,
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: shortcutBindings,
      child: Focus(
        autofocus: true,
        child: NotificationListener<OverscrollIndicatorNotification>(
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
                child: EventMediaHeader(
                  event: widget.event,
                  pageController: widget.pageController,
                  currentPage: widget.currentPage,
                  onPageChanged: _handlePageChanged,
                  heroTag: widget.heroTag,
                  stretchAnimation: _headerStretchController,
                  topPadding: topInset,
                  baseHeight: _baseHeaderHeight,
                  extraStretchHeight: _extraStretchHeight,
                  maxCornerRadius: _maxCornerRadius,
                  hasMedia: _hasMedia,
                  mediaCount: _mediaCount,
                  onTap: _handleHeaderTap,
                  onDragEnd: (velocity) => unawaited(
                    _interactionController.handleDragEndVelocity(velocity),
                  ),
                ),
              ),
              contentSliver,
            ],
          ),
        ),
      ),
    );
  }
}
