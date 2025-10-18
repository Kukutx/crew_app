import '../common/enums.dart';

class AddMemberRequest {
  const AddMemberRequest({
    required this.userId,
    this.role = ChatMemberRole.member,
  });

  factory AddMemberRequest.fromJson(Map<String, dynamic> json) {
    return AddMemberRequest(
      userId: json['userId'] as String,
      role: json['role'] != null
          ? ChatMemberRole.fromJson(json['role'])
          : ChatMemberRole.member,
    );
  }

  final String userId;
  final ChatMemberRole role;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role.toJson(),
      };
}
