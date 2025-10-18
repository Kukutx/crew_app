class AddMomentCommentRequest {
  const AddMomentCommentRequest({
    required this.content,
  });

  factory AddMomentCommentRequest.fromJson(Map<String, dynamic> json) {
    return AddMomentCommentRequest(
      content: json['content'] as String,
    );
  }

  final String content;

  Map<String, dynamic> toJson() => {
        'content': content,
      };
}
