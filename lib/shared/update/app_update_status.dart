import 'package:meta/meta.dart';

@immutable
class AppUpdateStatus {
  const AppUpdateStatus({
    required this.currentVersion,
    required this.latestVersion,
    required this.updateAvailable,
    required this.forceUpdate,
    required this.updateUrl,
    required this.message,
    this.errorDescription,
  });

  final String currentVersion;
  final String latestVersion;
  final bool updateAvailable;
  final bool forceUpdate;
  final String? updateUrl;
  final String? message;
  final String? errorDescription;

  bool get hasError => errorDescription != null && errorDescription!.isNotEmpty;

  bool get requiresUpdate => updateAvailable && forceUpdate;

  bool get canLaunchUpdate => updateUrl != null && updateUrl!.isNotEmpty;
}
