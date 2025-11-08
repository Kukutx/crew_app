/// 活动收益记录
/// 
/// 表示一个活动的收益信息，包括参与者报名费、活动状态等
class RevenueRecord {
  const RevenueRecord({
    required this.eventId,
    required this.eventTitle,
    required this.eventStatus,
    required this.totalAmount,
    required this.reservedAmount,
    required this.availableAmount,
    required this.participantCount,
    this.startTime,
    this.endTime,
    this.createdAt,
  });

  /// 活动ID
  final String eventId;
  
  /// 活动标题
  final String eventTitle;
  
  /// 活动状态（通过Event.status判断）
  /// reviewing: 审核中
  /// recruiting: 招募中
  /// ongoing: 进行中
  /// ended: 已结束
  final String eventStatus;
  
  /// 总收益金额（所有参与者的报名费总和）
  final double totalAmount;
  
  /// 预留金额（已授权但未到账，活动进行中时）
  final double reservedAmount;
  
  /// 可用金额（已到账，活动结束后）
  final double availableAmount;
  
  /// 参与者数量
  final int participantCount;
  
  /// 活动开始时间
  final DateTime? startTime;
  
  /// 活动结束时间
  final DateTime? endTime;
  
  /// 记录创建时间
  final DateTime? createdAt;

  factory RevenueRecord.fromJson(Map<String, dynamic> json) {
    return RevenueRecord(
      eventId: json['eventId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
      eventStatus: json['eventStatus'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      reservedAmount: (json['reservedAmount'] as num?)?.toDouble() ?? 0.0,
      availableAmount: (json['availableAmount'] as num?)?.toDouble() ?? 0.0,
      participantCount: (json['participantCount'] as int?) ?? 0,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventTitle': eventTitle,
        'eventStatus': eventStatus,
        'totalAmount': totalAmount,
        'reservedAmount': reservedAmount,
        'availableAmount': availableAmount,
        'participantCount': participantCount,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}

