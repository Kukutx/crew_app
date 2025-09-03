class EventFilter {
  final double distanceKm;    // 距离
  final String date;          // today/week/month/any
  final bool onlyFree;        // 仅免费
  final Set<String> categories; // 多选分类
  const EventFilter({
    this.distanceKm = 5,
    this.date = 'any',
    this.onlyFree = false,
    this.categories = const {},
  });

  EventFilter copyWith({
    double? distanceKm,
    String? date,
    bool? onlyFree,
    Set<String>? categories,
  }) => EventFilter(
    distanceKm: distanceKm ?? this.distanceKm,
    date: date ?? this.date,
    onlyFree: onlyFree ?? this.onlyFree,
    categories: categories ?? this.categories,
  );
}
