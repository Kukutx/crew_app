/// 版本号比较辅助工具
class VersionHelper {
  /// 比较两个版本号
  /// 
  /// 返回:
  /// - 负数: 如果 version1 < version2
  /// - 0: 如果 version1 == version2
  /// - 正数: 如果 version1 > version2
  /// 
  /// 示例: compareVersions("1.2.3", "1.2.4") 返回负数
  static int compareVersions(String version1, String version2) {
    final v1Parts = _parseVersion(version1);
    final v2Parts = _parseVersion(version2);
    final length = v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;
    
    for (var i = 0; i < length; i++) {
      final v1Value = i < v1Parts.length ? v1Parts[i] : 0;
      final v2Value = i < v2Parts.length ? v2Parts[i] : 0;
      if (v1Value != v2Value) {
        return v1Value.compareTo(v2Value);
      }
    }
    return 0;
  }

  /// 解析版本字符串为数字列表
  /// 
  /// 示例: "1.2.3" -> [1, 2, 3]
  static List<int> _parseVersion(String version) {
    return version
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList(growable: false);
  }

  /// 检查当前版本是否需要更新
  /// 
  /// [currentVersion] 当前版本号
  /// [latestVersion] 最新版本号
  /// 返回 true 如果 currentVersion < latestVersion
  static bool requiresUpdate(String currentVersion, String latestVersion) {
    if (latestVersion.isEmpty || currentVersion.isEmpty) {
      return false;
    }
    return compareVersions(currentVersion, latestVersion) < 0;
  }

  /// 检查当前版本是否需要强制更新
  /// 
  /// [currentVersion] 当前版本号
  /// [minSupportedVersion] 最低支持的版本号
  /// 返回 true 如果 currentVersion < minSupportedVersion
  static bool requiresForceUpdate(
    String currentVersion,
    String minSupportedVersion,
  ) {
    if (minSupportedVersion.isEmpty || currentVersion.isEmpty) {
      return false;
    }
    return compareVersions(currentVersion, minSupportedVersion) < 0;
  }
}
