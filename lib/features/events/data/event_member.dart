import 'event_registration.dart';

/// 事件成员
class EventMember {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String registrationId;
  final RegistrationStatus status;
  final DateTime registeredAt;
  final bool isHost;

  const EventMember({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.registrationId,
    required this.status,
    required this.registeredAt,
    this.isHost = false,
  });

  factory EventMember.fromJson(Map<String, dynamic> json) {
    return EventMember(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userAvatarUrl: json['userAvatarUrl'] as String?,
      registrationId: json['registrationId'] as String? ?? '',
      status: _parseRegistrationStatus(json['status'] as String?),
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : DateTime.now(),
      isHost: (json['isHost'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        if (userAvatarUrl != null) 'userAvatarUrl': userAvatarUrl,
        'registrationId': registrationId,
        'status': _registrationStatusToString(status),
        'registeredAt': registeredAt.toIso8601String(),
        'isHost': isHost,
      };

  static RegistrationStatus _parseRegistrationStatus(String? value) {
    switch (value) {
      case 'pending':
        return RegistrationStatus.pending;
      case 'approved':
        return RegistrationStatus.approved;
      case 'rejected':
        return RegistrationStatus.rejected;
      case 'cancelled':
        return RegistrationStatus.cancelled;
      default:
        return RegistrationStatus.pending;
    }
  }

  static String _registrationStatusToString(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return 'pending';
      case RegistrationStatus.approved:
        return 'approved';
      case RegistrationStatus.rejected:
        return 'rejected';
      case RegistrationStatus.cancelled:
        return 'cancelled';
    }
  }
}

