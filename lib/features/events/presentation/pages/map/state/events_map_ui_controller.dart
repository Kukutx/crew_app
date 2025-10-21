import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/event.dart';

@immutable
class EventsMapUiState {
  const EventsMapUiState({
    this.carouselEvents = const <Event>[],
    this.isEventCardVisible = false,
    this.initialPage = 0,
    this.hasMovedToSelected = false,
  });

  final List<Event> carouselEvents;
  final bool isEventCardVisible;
  final int initialPage;
  final bool hasMovedToSelected;

  EventsMapUiState copyWith({
    List<Event>? carouselEvents,
    bool? isEventCardVisible,
    int? initialPage,
    bool? hasMovedToSelected,
  }) {
    return EventsMapUiState(
      carouselEvents: carouselEvents ?? this.carouselEvents,
      isEventCardVisible: isEventCardVisible ?? this.isEventCardVisible,
      initialPage: initialPage ?? this.initialPage,
      hasMovedToSelected: hasMovedToSelected ?? this.hasMovedToSelected,
    );
  }
}

class EventsMapUiController extends StateNotifier<EventsMapUiState> {
  EventsMapUiController(this._ref) : super(const EventsMapUiState());

  final Ref _ref;

  void showEventCard(Event event) {
    final events = _ref.read(eventsProvider).maybeWhen(
          data: (data) => data,
          orElse: () => const <Event>[],
        );
    final index = events.indexWhere((element) => element.id == event.id);
    if (index == -1) {
      state = state.copyWith(
        carouselEvents: <Event>[event],
        isEventCardVisible: true,
        initialPage: 0,
      );
      return;
    }
    state = state.copyWith(
      carouselEvents: events,
      isEventCardVisible: true,
      initialPage: index,
    );
  }

  void hideEventCard() {
    state = state.copyWith(
      carouselEvents: const <Event>[],
      isEventCardVisible: false,
      initialPage: 0,
    );
  }

  void setHasMovedToSelected(bool value) {
    if (state.hasMovedToSelected == value) {
      return;
    }
    state = state.copyWith(hasMovedToSelected: value);
  }
}

final eventsMapUiControllerProvider =
    StateNotifierProvider.autoDispose<EventsMapUiController, EventsMapUiState>(
  (ref) => EventsMapUiController(ref),
);
