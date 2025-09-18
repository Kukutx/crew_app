// 创建数据模型来存储事件信息
class EventData {
  final String title;
  final String description;
  final String locationName;
  
  final List<String> imagePaths;
  final int? coverIndex;

  const EventData({
    required this.title,
    required this.description,
    required this.locationName,
    this.imagePaths = const [],
    this.coverIndex,
  });
}