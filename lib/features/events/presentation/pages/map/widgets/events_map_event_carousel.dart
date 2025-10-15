import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/map_event_floating_card.dart';
import 'package:flutter/material.dart';

class EventsMapEventCarousel extends StatelessWidget {
  const EventsMapEventCarousel({
    super.key,
    required this.events,
    required this.visible,
    required this.controller,
    required this.safeBottom,
    required this.onPageChanged,
    required this.onOpenDetails,
    required this.onClose,
    required this.onRegister,
    required this.onFavorite,
  });

  final List<Event> events;
  final bool visible;
  final PageController controller;
  final double safeBottom;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<Event> onOpenDetails;
  final VoidCallback onClose;
  final VoidCallback onRegister;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          offset: Offset(0, visible ? 0 : 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            opacity: visible ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + safeBottom),
              child: SizedBox(
                height: 158,
                child: PageView.builder(
                  controller: controller,
                  physics: events.length > 1
                      ? const PageScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: onPageChanged,
                  itemCount: events.length,
                  itemBuilder: (_, index) {
                    final event = events[index];
                    return MapEventFloatingCard(
                      key: ValueKey(event.id),
                      event: event,
                      onTap: () => onOpenDetails(event),
                      onClose: onClose,
                      onRegister: onRegister,
                      onFavorite: onFavorite,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
