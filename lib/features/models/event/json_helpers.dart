DateTime? parseDateTime(dynamic value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String) {
    return DateTime.tryParse(value)?.toUtc();
  }
  if (value is num) {
    final milliseconds = value.toDouble();
    if (milliseconds.isNaN) {
      return null;
    }
    final ms = milliseconds >= 1e12
        ? milliseconds.round()
        : (milliseconds * 1000).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }
  return null;
}

int? parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim());
  }
  return null;
}

double? parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

bool parseBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final lowered = value.trim().toLowerCase();
    if (lowered.isEmpty) {
      return false;
    }
    return lowered == 'true' || lowered == '1' || lowered == 'yes';
  }
  return false;
}

List<double> parseDoubleList(dynamic value) {
  if (value is List) {
    return value
        .map((element) {
          if (element is num) {
            return element.toDouble();
          }
          if (element is String) {
            return double.tryParse(element.trim());
          }
          return null;
        })
        .whereType<double>()
        .toList(growable: false);
  }
  return const [];
}

List<String> parseStringList(dynamic value) {
  if (value is List) {
    return value
        .map((element) => element == null ? '' : element.toString().trim())
        .where((element) => element.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}

List<Map<String, dynamic>> parseMapList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  return const [];
}
