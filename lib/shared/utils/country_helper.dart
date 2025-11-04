/// 国家代码相关辅助工具
class CountryHelper {
  /// 将 ISO 3166-1 alpha-2 国家代码转换为对应的国旗 Emoji
  /// 
  /// 例如: "US" -> "🇺🇸", "CN" -> "🇨🇳"
  /// 
  /// [countryCode] 必须是 2 位大写字母的国家代码
  /// 返回对应的国旗 Emoji，如果输入无效则返回 null
  static String? countryCodeToEmoji(String? countryCode) {
    if (countryCode == null || countryCode.length != 2) {
      return null;
    }

    final upper = countryCode.toUpperCase();
    final codeUnits = upper.codeUnits
        .map((unit) => 0x1F1E6 + unit - 'A'.codeUnitAt(0))
        .toList();
    return String.fromCharCodes(codeUnits);
  }
}
