import 'dart:ui';

import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_cost_calculator_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_host_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_info_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_carousel.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_media_fullscreen_page.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_plaza_card.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_summary_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailBody extends StatefulWidget {
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
    required this.onBack,
    required this.onShare,
    required this.onMore,
  });

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
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onMore;

  @override
  State<EventDetailBody> createState() => _EventDetailBodyState();
}

class _EventDetailBodyState extends State<EventDetailBody> {
  late final ScrollController _scrollController;
  double _appBarOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final offset = _scrollController.offset;
    final nextOpacity = (offset / 140).clamp(0, 1);
    if (nextOpacity != _appBarOpacity) {
      setState(() => _appBarOpacity = nextOpacity);
    }
  }

  Future<void> _openFullScreen() async {
    if (!mounted) return;
    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: EventMediaFullscreenPage(
              event: widget.event,
              initialPage: widget.currentPage,
              heroTag: widget.heroTag,
            ),
          );
        },
      ),
    );
    if (result != null && widget.pageController.hasClients) {
      widget.pageController.jumpToPage(result);
      widget.onPageChanged(result);
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final materialLoc = MaterialLocalizations.of(context);

    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: mediaQuery.size.height * 0.45,
            pinned: true,
            stretch: true,
            surfaceTintColor: Colors.transparent,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: _GlassIconButton(
              icon: Icons.arrow_back_ios_new,
              tooltip: materialLoc.backButtonTooltip,
              onPressed: widget.onBack,
              backgroundOpacity: 0.12 * (1 - _appBarOpacity),
            ),
            actions: [
              _GlassIconButton(
                icon: Icons.share_outlined,
                tooltip: 'Share',
                onPressed: widget.onShare,
                backgroundOpacity: 0.12 * (1 - _appBarOpacity),
              ),
              const SizedBox(width: 8),
              _GlassIconButton(
                icon: Icons.more_horiz,
                tooltip: 'More options',
                onPressed: widget.onMore,
                backgroundOpacity: 0.12 * (1 - _appBarOpacity),
              ),
              const SizedBox(width: 12),
            ],
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _appBarOpacity,
              child: Text(
                widget.event.title,
                style: theme.textTheme.titleLarge,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: GestureDetector(
                onTap: _openFullScreen,
                behavior: HitTestBehavior.opaque,
                child: Hero(
                  tag: widget.heroTag,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        EventMediaCarousel(
                          event: widget.event,
                          controller: widget.pageController,
                          currentPage: widget.currentPage,
                          onPageChanged: widget.onPageChanged,
                          height: mediaQuery.size.height * 0.45,
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.55),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          bottom: 36,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TagPill(text: widget.loc.tag_city_explore),
                              const SizedBox(height: 12),
                              Text(
                                widget.event.title,
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.place_outlined,
                                      color: Colors.white70, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      widget.event.location,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EventHostCard(
                    loc: widget.loc,
                    name: widget.hostName,
                    bio: widget.hostBio,
                    avatarUrl: widget.hostAvatarUrl,
                    onTapProfile: widget.onTapHostProfile,
                    onToggleFollow: widget.onToggleFollow,
                    isFollowing: widget.isFollowing,
                  ),
                  const SizedBox(height: 16),
                  EventSummaryCard(event: widget.event, loc: widget.loc),
                  const SizedBox(height: 16),
                  EventInfoCard(
                    event: widget.event,
                    loc: widget.loc,
                    onTapLocation: widget.onTapLocation,
                    onTapCostCalculator: _showCostCalculator,
                  ),
                  const SizedBox(height: 16),
                  EventPlazaCard(loc: widget.loc),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundOpacity = 0.12,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double backgroundOpacity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withOpacity(backgroundOpacity),
            child: InkWell(
              onTap: onPressed,
              child: Tooltip(
                message: tooltip,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(icon),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
