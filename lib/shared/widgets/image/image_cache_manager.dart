import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 通用的图片缓存管理器，支持失败重试限制
/// 
/// **性能优化策略：**
/// - 限制缓存对象数量：最多200个图片对象
/// - 缓存过期时间：7天后过期
/// - 失败重试限制：失败后1分钟内不再重试，避免频繁请求
/// 
/// **图片尺寸限制建议：**
/// 在使用 [CachedNetworkImage] 时，建议设置以下参数来控制内存使用：
/// - `memCacheHeight`: 推荐 512-1024 像素（根据显示需求）
/// - `memCacheWidth`: 推荐 512-1024 像素（根据显示需求）
/// - 这些参数会限制图片在内存中的尺寸，自动进行压缩，减少内存占用
/// 
/// **示例：**
/// ```dart
/// CachedNetworkImage(
///   imageUrl: url,
///   cacheManager: ImageCacheManager.instance,
///   memCacheHeight: 512, // 限制内存中图片高度为512px
///   memCacheWidth: 512,  // 限制内存中图片宽度为512px
///   fit: BoxFit.cover,
/// )
/// ```
class ImageCacheManager extends CacheManager {
  ImageCacheManager._()
      : super(
          Config(
            'app_images',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 200, // 限制缓存对象数量，控制存储空间
          ),
        );

  /// Singleton instance used throughout the app.
  static final ImageCacheManager instance = ImageCacheManager._();

  /// Duration to wait before retrying a failed download.
  /// 
  /// 当图片下载失败后，会等待此时间再允许重试，避免频繁请求失败的URL。
  final Duration retryDelay = const Duration(minutes: 1);

  final Map<String, DateTime> _failedFetches = <String, DateTime>{};

  bool _shouldThrottle(String cacheKey) {
    final lastFailedAt = _failedFetches[cacheKey];
    if (lastFailedAt == null) {
      return false;
    }
    final hasToWait = DateTime.now().difference(lastFailedAt) < retryDelay;
    if (!hasToWait) {
      _failedFetches.remove(cacheKey);
    }
    return hasToWait;
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = true,
  }) {
    final cacheKey = key ?? url;

    if (_shouldThrottle(cacheKey)) {
      return _loadFromCacheOrError(cacheKey);
    }

    final controller = StreamController<FileResponse>();
    late final StreamSubscription<FileResponse> subscription;

    subscription = super
        .getFileStream(
      url,
      key: cacheKey,
      headers: headers,
      withProgress: withProgress,
    )
        .listen(
      (event) {
        if (event is FileInfo) {
          _failedFetches.remove(cacheKey);
        }
        controller.add(event);
      },
      onError: (error, stackTrace) async {
        _failedFetches[cacheKey] = DateTime.now();
        final cached = await getFileFromCache(cacheKey);
        if (cached != null && !controller.isClosed) {
          controller.add(cached);
        }
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      },
      onDone: () {
        controller.close();
      },
      cancelOnError: false,
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  Stream<FileResponse> _loadFromCacheOrError(String cacheKey) async* {
    final cached = await getFileFromCache(cacheKey);
    if (cached != null) {
      yield cached;
      return;
    }
    throw ThrottledFetchException(retryDelay);
  }
}

/// Exception used to signal that a request has been throttled.
class ThrottledFetchException implements Exception {
  ThrottledFetchException(this.retryDelay);

  final Duration retryDelay;

  @override
  String toString() =>
      'ThrottledFetchException: retry after ${retryDelay.inSeconds}s';
}

