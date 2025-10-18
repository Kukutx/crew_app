class EventSegmentDto {
  final int seq;
  final List<double> waypoint;         // [lon, lat]
  final String? note;

  EventSegmentDto({required this.seq, required this.waypoint, this.note});

  factory EventSegmentDto.fromJson(Map<String, dynamic> json) => EventSegmentDto(
        seq: json['seq'],
        waypoint: (json['waypoint'] as List).map((e) => (e as num).toDouble()).toList(),
        note: json['note'],
      );

  Map<String, dynamic> toJson() => {'seq': seq, 'waypoint': waypoint, 'note': note};
}
