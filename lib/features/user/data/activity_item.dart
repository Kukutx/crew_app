// 与event重合了，目前先用日后更改
class ActivityItem {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime time;
  final String location;
  ActivityItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.location,
  });
}