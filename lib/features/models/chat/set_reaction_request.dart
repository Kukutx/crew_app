class SetReactionRequest {
  const SetReactionRequest({
    required this.emoji,
  });

  factory SetReactionRequest.fromJson(Map<String, dynamic> json) {
    return SetReactionRequest(
      emoji: json['emoji'] as String,
    );
  }

  final String emoji;

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
      };
}
