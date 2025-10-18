import 'package:flutter/material.dart';

@immutable
class EnumParseException implements FormatException {
  const EnumParseException(this.message, [this.source, this.offset]);

  @override
  final String message;

  @override
  final dynamic source;

  @override
  final int? offset;
}

T _enumFromJson<T>(List<T> values, Object? jsonValue, String enumName) {
  if (jsonValue == null) {
    throw EnumParseException('Null is not a valid $enumName value');
  }

  if (jsonValue is String) {
    final normalized = jsonValue.trim().toLowerCase();
    for (final value in values) {
      if (value.toString().split('.').last.toLowerCase() == normalized) {
        return value;
      }
    }
    throw EnumParseException('`$jsonValue` is not a valid $enumName value');
  }

  if (jsonValue is num) {
    final index = jsonValue.toInt();
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    throw EnumParseException('`$jsonValue` is out of range for $enumName');
  }

  throw EnumParseException('Unsupported $enumName value type: ${jsonValue.runtimeType}');
}

enum ChatMemberRole { owner, admin, member, guest;
  static ChatMemberRole fromJson(Object? value) =>
      _enumFromJson(values, value, 'ChatMemberRole');
  Object toJson() => index;
}

enum ChatMessageKind { text, image, file, location, system, reply, voice, route;
  static ChatMessageKind fromJson(Object? value) =>
      _enumFromJson(values, value, 'ChatMessageKind');
  Object toJson() => index;
}

enum ChatMessageStatus { persisted, removed, hidden;
  static ChatMessageStatus fromJson(Object? value) =>
      _enumFromJson(values, value, 'ChatMessageStatus');
  Object toJson() => index;
}

enum ChatType { eventGroup, direct, system;
  static ChatType fromJson(Object? value) =>
      _enumFromJson(values, value, 'ChatType');
  Object toJson() => index;
}

enum EventVisibility { private, unlisted, public;
  static EventVisibility fromJson(Object? value) =>
      _enumFromJson(values, value, 'EventVisibility');
  Object toJson() => index;
}
