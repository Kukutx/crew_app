import 'package:crew_app/shared/utils/version_helper.dart';

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
    return VersionHelper.requiresUpdate(currentVersion, latestVersion);
  }

  bool requiresForceUpdate(String currentVersion) {
    return VersionHelper.requiresForceUpdate(currentVersion, minSupportedVersion);
  }
}
