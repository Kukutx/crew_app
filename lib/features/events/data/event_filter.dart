enum EventDateFilter { today, thisWeek, thisMonth, any }

class EventFilter {
  const EventFilter({
    this.maxDistanceKm = 5,
    this.dateFilter = EventDateFilter.any,
    this.onlyFreeEvents = false,
    this.selectedCategories = const <String>{},
  });

  final double maxDistanceKm;
  final EventDateFilter dateFilter;
  final bool onlyFreeEvents;
  final Set<String> selectedCategories;

  EventFilter copyWith({
    double? maxDistanceKm,
    EventDateFilter? dateFilter,
    bool? onlyFreeEvents,
    Set<String>? selectedCategories,
  }) {
    return EventFilter(
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      dateFilter: dateFilter ?? this.dateFilter,
      onlyFreeEvents: onlyFreeEvents ?? this.onlyFreeEvents,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  Map<String, dynamic> toQueryParameters() => {
        'maxDistanceKm': maxDistanceKm,
        'dateFilter': dateFilter.name,
        'onlyFreeEvents': onlyFreeEvents,
        'selectedCategories': selectedCategories.toList(),
      };
}
