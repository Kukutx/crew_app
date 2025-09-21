import 'package:crew_app/shared/legal/data/disclaimer.dart';
import 'package:crew_app/shared/legal/disclaimer_sources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final disclaimerRepoProvider = Provider<DisclaimerRepository>((ref) {
  return DisclaimerRepository(
    asset: LocalAssetDisclaimerSource(),
    cache: LocalCacheDisclaimerSource(),
    // 选一个：RemoteConfigDisclaimerSource() 或 ApiDisclaimerSource()
    remote: ApiDisclaimerSource(),
  );
});

class DisclaimerState {
  final Disclaimer toShow;      // 当前可展示内容（缓存或资产或线上）
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
  final latestVer = r.latest?.version ?? r.show.version;
  final needs = latestVer > r.acceptedVersion;
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
