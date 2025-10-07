import 'package:crew_app/shared/widgets/legal_bottom_sheet/data/sources/local_disclaimer_source.dart';
import 'package:crew_app/shared/widgets/legal_bottom_sheet/data/sources/remote_disclaimer_source.dart';
import 'package:crew_app/shared/widgets/legal_bottom_sheet/domain/models/disclaimer.dart';

class DisclaimerRepository {
  DisclaimerRepository({
    required this.cache,
    required this.remote,
  });

  final LocalCacheDisclaimerSource cache;
  final RemoteDisclaimerSource remote;

  /// 启动时使用：先拿**可展示**版本（缓存），并尝试后台拉取线上
  Future<({Disclaimer? show, Disclaimer? latest, int acceptedVersion})> bootstrap() async {
    final cached = await cache.loadCached();
    Disclaimer? show = cached;
    final accepted = await cache.loadAcceptedVersion();

    Disclaimer? latest;
    try {
      latest = await remote.fetchLatest();
      if (latest != null) {
        await cache.saveCached(latest);
        show = latest;
      }
    } catch (_) {
      // 静默失败，保留 show
    }
    return (show: show, latest: latest, acceptedVersion: accepted);
  }

  Future<void> markAccepted(int version) => cache.saveAcceptedVersion(version);
}
