class AddGuestbookEntryRequest {
  final String content;
  final int? rating; // 1..5 可选

  AddGuestbookEntryRequest({required this.content, this.rating});

  factory AddGuestbookEntryRequest.fromJson(Map<String, dynamic> json) =>
      AddGuestbookEntryRequest(
        content: json['content'],
        rating: json['rating'],
      );

  Map<String, dynamic> toJson() => {'content': content, 'rating': rating};
}
