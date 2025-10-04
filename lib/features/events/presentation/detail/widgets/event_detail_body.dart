import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_host_card.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_image_carousel.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_info_card.dart';
import 'package:crew_app/features/events/presentation/detail/widgets/event_summary_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventDetailBody extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String hostName;
  final String hostBio;
  final String? hostAvatarUrl;
  final VoidCallback onTapHostProfile;
  final VoidCallback onToggleFollow;
  final bool isFollowing;
  final VoidCallback onTapLocation;

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
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventImageCarousel(
            event: event,
            controller: pageController,
            currentPage: currentPage,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 16),
          EventHostCard(
            loc: loc,
            name: hostName,
            bio: hostBio,
            avatarUrl: hostAvatarUrl,
            onTapProfile: onTapHostProfile,
            onToggleFollow: onToggleFollow,
            isFollowing: isFollowing,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: EventSummaryCard(event: event, loc: loc),
          ),
          const SizedBox(height: 10),
          EventInfoCard(
            event: event,
            loc: loc,
            onTapLocation: onTapLocation,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
