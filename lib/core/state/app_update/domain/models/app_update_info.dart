class AppUpdateInfo {
  AppUpdateInfo({
    required this.latestVersion,
    required this.minSupportedVersion,
    this.downloadUrl,
    this.message,
  });

  final String latestVersion;
  final String minSupportedVersion;
  final String? downloadUrl;
  final String? message;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: (json['latestVersion'] as String?)?.trim() ?? '',
      minSupportedVersion: (json['minSupportedVersion'] as String?)?.trim() ?? '',
      downloadUrl: (json['downloadUrl'] as String?)?.trim(),
      message: (json['message'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latestVersion': latestVersion,
        'minSupportedVersion': minSupportedVersion,
        if (downloadUrl != null) 'downloadUrl': downloadUrl,
        if (message != null) 'message': message,
      };

  bool requiresUpdate(String currentVersion) {
    if (latestVersion.isEmpty || currentVersion.isEmpty) {
      return false;
    }
    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  bool requiresForceUpdate(String currentVersion) {
    if (minSupportedVersion.isEmpty || currentVersion.isEmpty) {
      return false;
    }
    return _compareVersions(currentVersion, minSupportedVersion) < 0;
  }

  static int _compareVersions(String a, String b) {
    final aParts = _parseVersion(a);
    final bParts = _parseVersion(b);
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < length; i++) {
      final aValue = i < aParts.length ? aParts[i] : 0;
      final bValue = i < bParts.length ? bParts[i] : 0;
      if (aValue != bValue) {
        return aValue.compareTo(bValue);
      }
    }
    return 0;
  }

  static List<int> _parseVersion(String version) {
    return version
        .split('.')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList(growable: false);
  }
}
