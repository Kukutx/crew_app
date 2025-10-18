List<double> toDoubleList(dynamic value) {
  if (value == null) {
    throw const FormatException('Expected a non-null list of numbers');
  }
  if (value is List) {
    return value.map((element) {
      if (element is num) {
        return element.toDouble();
      }
      if (element is String) {
        return double.parse(element);
      }
      throw FormatException('Invalid coordinate value: $element');
    }).toList(growable: false);
  }
  throw FormatException('Expected a JSON array but found ${value.runtimeType}');
}

List<String> toStringList(dynamic value) {
  if (value == null) {
    return const [];
  }
  if (value is List) {
    return value.map((element) => element?.toString() ?? '').toList(growable: false);
  }
  throw FormatException('Expected a JSON array but found ${value.runtimeType}');
}
