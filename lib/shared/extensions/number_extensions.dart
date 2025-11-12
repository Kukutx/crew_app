/// 数字扩展工具类
extension CompactNumber on int {
  /// 将数字格式化为紧凑格式（K、M 表示）
  /// 
  /// 例如：
  /// - 999 → "999"
  /// - 1500 → "1.5K"
  /// - 1200000 → "1.2M"
  String toCompactString() {
    if (this < 1000) {
      return toString();
    } else if (this < 1000000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    }
  }
}

