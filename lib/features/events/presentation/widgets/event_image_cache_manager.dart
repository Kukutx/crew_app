import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A cache manager that throttles repeated failed image downloads for events.
class EventImageCacheManager extends CacheManager {
  EventImageCacheManager._()
      : super(
          Config(
            'event_images',
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 200,
          ),
        );

  /// Singleton instance used throughout the events feature.
  static final EventImageCacheManager instance = EventImageCacheManager._();

  /// Duration to wait before retrying a failed download.
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
