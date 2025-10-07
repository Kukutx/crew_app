import 'package:crew_app/core/config/remote_config_providers.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/data/repositories/disclaimer_repository.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/data/sources/local_disclaimer_source.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/data/sources/remote_disclaimer_source.dart';
import 'package:crew_app/shared/widgets/sheets/legal_sheet/domain/models/disclaimer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

final disclaimerRepoProvider = Provider<DisclaimerRepository>((ref) {
  final remoteConfig = ref.watch(remoteConfigProvider);
  final Talker talker = ref.watch(talkerProvider);

  return DisclaimerRepository(
    cache: LocalCacheDisclaimerSource(),
    remote: remoteConfig != null
        ? RemoteConfigDisclaimerSource(remoteConfig, talker: talker)
        : const NoopRemoteDisclaimerSource(),
  );
});

class DisclaimerState {
  final Disclaimer? toShow;     // 当前可展示内容（缓存或线上）
  final int acceptedVersion;    // 已同意版本（0 表示未同意）
  final bool needsReconsent;    // 是否需要强制重签

  const DisclaimerState({
    required this.toShow,
    required this.acceptedVersion,
    required this.needsReconsent,
  });
}

final disclaimerStateProvider = FutureProvider<DisclaimerState>((ref) async {
  final repo = ref.watch(disclaimerRepoProvider);
  final r = await repo.bootstrap();
  final latestVer = r.latest?.version ?? r.show?.version ?? r.acceptedVersion;
  final needs = r.show != null && latestVer > r.acceptedVersion;
  return DisclaimerState(
    toShow: r.show,
    acceptedVersion: r.acceptedVersion,
    needsReconsent: needs,
  );
});

final acceptDisclaimerProvider = Provider((ref) {
  return (int version) async {
    final repo = ref.read(disclaimerRepoProvider);
    await repo.markAccepted(version);
    // 让界面刷新
    ref.invalidate(disclaimerStateProvider);
  };
});
