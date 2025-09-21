// 免责声明
class Disclaimer {
  final int version;
  final String title;
  final String content;
  final DateTime updatedAt;

  Disclaimer({required this.version, required this.title, required this.content, required this.updatedAt});

  factory Disclaimer.fromJson(Map<String, dynamic> j) => Disclaimer(
    version: j['version'] as int,
    title: j['title'] as String,
    content: j['content'] as String,
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
}
