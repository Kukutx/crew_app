import '../common/enums.dart';

class SendMessageRequest {
  const SendMessageRequest({
    required this.kind,
    this.bodyText,
    this.metaJson,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) {
    return SendMessageRequest(
      kind: ChatMessageKind.fromJson(json['kind']),
      bodyText: json['bodyText'] as String?,
      metaJson: json['metaJson'] as String?,
    );
  }

  final ChatMessageKind kind;
  final String? bodyText;
  final String? metaJson;

  Map<String, dynamic> toJson() => {
        'kind': kind.toJson(),
        'bodyText': bodyText,
        'metaJson': metaJson,
      };
}
