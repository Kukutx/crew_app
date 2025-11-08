/// 钱包余额信息
class WalletBalance {
  const WalletBalance({
    required this.availableBalance,
    required this.reservedBalance,
    required this.totalBalance,
    this.lastUpdated,
  });

  /// 可用余额（已到账，可以提现）
  final double availableBalance;
  
  /// 预留余额（已授权但未到账，活动进行中）
  final double reservedBalance;
  
  /// 总余额（可用 + 预留）
  final double totalBalance;
  
  /// 最后更新时间
  final DateTime? lastUpdated;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      availableBalance: (json['availableBalance'] as num?)?.toDouble() ?? 0.0,
      reservedBalance: (json['reservedBalance'] as num?)?.toDouble() ?? 0.0,
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'availableBalance': availableBalance,
        'reservedBalance': reservedBalance,
        'totalBalance': totalBalance,
        if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
      };
}

