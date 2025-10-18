class MarkReadRequest {
  const MarkReadRequest({
    required this.chatId,
    required this.maxSeq,
  });

  factory MarkReadRequest.fromJson(Map<String, dynamic> json) {
    return MarkReadRequest(
      chatId: json['chatId'] as String,
      maxSeq: (json['maxSeq'] as num).toInt(),
    );
  }

  final String chatId;
  final int maxSeq;

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'maxSeq': maxSeq,
      };
}
