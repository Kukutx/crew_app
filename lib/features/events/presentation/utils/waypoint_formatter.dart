String formatWaypointLabel(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  final separator = RegExp(r'[\s\-|·,、/]+');
  final parts =
      trimmed.split(separator).where((part) => part.isNotEmpty).toList(growable: false);
  if (parts.isEmpty) {
    return trimmed;
  }
  final first = parts.first;
  if (trimmed.length > first.length) {
    return '$first…';
  }
  return trimmed;
}
