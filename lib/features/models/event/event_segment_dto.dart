import 'json_helpers.dart';

class EventSegmentDto {
  final int seq;
  final List<double> waypoint; // [lon, lat]
  final String? note;

  EventSegmentDto({required this.seq, required List<double> waypoint, this.note})
      : waypoint = List.unmodifiable(waypoint);

  factory EventSegmentDto.fromJson(Map<String, dynamic> json) {
    final waypoint = parseDoubleList(json['waypoint']);
    return EventSegmentDto(
      seq: parseInt(json['seq']) ?? 0,
      waypoint: waypoint.isEmpty ? const <double>[] : waypoint,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'seq': seq, 'waypoint': waypoint, 'note': note};
}
