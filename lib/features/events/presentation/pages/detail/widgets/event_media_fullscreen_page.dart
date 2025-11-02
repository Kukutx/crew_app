import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class EventMediaFullscreenScreen extends StatefulWidget {
  const EventMediaFullscreenScreen({
    super.key,
    required this.event,
    required this.initialPage,
    required this.heroTag,
  });

  final Event event;
  final int initialPage;
  final String heroTag;

  @override
  State<EventMediaFullscreenScreen> createState() =>
      _EventMediaFullscreenScreenState();
}

class _EventMediaFullscreenScreenState extends State<EventMediaFullscreenScreen>
    with TickerProviderStateMixin {
  late final List<_FullscreenMediaItem> _items;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _items = _parseMediaItems(widget.event);
    if (_items.isEmpty) {
      _currentPage = 0;
    } else {
      final maxIndex = _items.length - 1;
      _currentPage = widget.initialPage.clamp(0, maxIndex);
    }
    _pageController = PageController(initialPage: _currentPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  List<_FullscreenMediaItem> _parseMediaItems(Event event) {
    final images = event.imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map(_FullscreenMediaItem.image);
    final videos = event.videoUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map(_FullscreenMediaItem.video);
    return [...images, ...videos];
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 650) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(_currentPage);
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    debugPrint('Analytics: fullscreen_page_change_$index');
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    Widget viewer;
    if (items.isEmpty) {
      viewer = const Center(
        child: Icon(Icons.image_not_supported, color: Colors.white, size: 48),
      );
    } else {
      viewer = PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          switch (item.type) {
            case _FullscreenMediaType.image:
              return _FullscreenImageViewer(url: item.url);
            case _FullscreenMediaType.video:
              return _FullscreenVideoPlayer(
                key: ValueKey(item.url),
                url: item.url,
                isActive: _currentPage == index,
              );
          }
        },
      );
    }

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_currentPage);
        }
      },
      child: GestureDetector(
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: Material(color: Colors.black, child: viewer),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(_currentPage),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (items.isNotEmpty)
                        Text(
                          widget.event.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (items.length > 1)
                        _FullscreenPageIndicator(
                          current: _currentPage,
                          total: items.length,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenPageIndicator extends StatelessWidget {
  const _FullscreenPageIndicator({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 14 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white38,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _FullscreenImageViewer extends StatelessWidget {
  const _FullscreenImageViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        memCacheHeight: 512, // 合理压缩，减内存抖动
        useOldImageOnUrlChange: true,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        errorWidget: (context, url, error) =>
            const _FullscreenErrorPlaceholder(),
      ),
    );
  }
}

enum _FullscreenMediaType { image, video }

class _FullscreenMediaItem {
  const _FullscreenMediaItem._(this.type, this.url);

  factory _FullscreenMediaItem.image(String url) =>
      _FullscreenMediaItem._(_FullscreenMediaType.image, url);
  factory _FullscreenMediaItem.video(String url) =>
      _FullscreenMediaItem._(_FullscreenMediaType.video, url);

  final _FullscreenMediaType type;
  final String url;
}

class _FullscreenVideoPlayer extends StatefulWidget {
  const _FullscreenVideoPlayer({
    super.key,
    required this.url,
    required this.isActive,
  });

  final String url;
  final bool isActive;

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _initialized = false;
  bool _wasActive = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant _FullscreenVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _disposeControllers();
      _initialize();
    } else if (widget.isActive != oldWidget.isActive) {
      _syncPlaybackState();
    }
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _hasError = false;
      _initialized = false;
    });

    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      setState(() {
        _hasError = true;
        _initialized = false;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;

    ChewieController? chewie;
    try {
      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            'Video initialization timed out for ${widget.url}',
          );
        },
      );
      await controller.setLooping(true);
      await controller.setVolume(0);

      chewie = ChewieController(
        videoPlayerController: controller,
        autoInitialize: false,
        autoPlay: false,
        looping: true,
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: false,
        allowMuting: true,
        allowFullScreen: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );

      if (!mounted) {
        chewie.dispose();
        await controller.dispose();
        return;
      }

      setState(() {
        _chewieController = chewie;
        _hasError = false;
        _initialized = true;
      });

      _syncPlaybackState();
    } catch (_) {
      chewie?.dispose();
      await controller.dispose();
      if (mounted) {
        setState(() {
          _chewieController = null;
          _hasError = true;
          _initialized = false;
        });
      }
    }
  }

  void _syncPlaybackState() {
    final controller = _controller;
    final chewie = _chewieController;
    if (!_initialized || controller == null || chewie == null) {
      return;
    }

    if (widget.isActive) {
      if (!_wasActive) {
        debugPrint('Analytics: video_play_${widget.url}');
      }
      _wasActive = true;
      controller.setVolume(1);
      chewie.play();
    } else {
      if (_wasActive) {
        debugPrint('Analytics: video_pause_${widget.url}');
      }
      _wasActive = false;
      chewie.pause();
      controller.setVolume(0);
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    final controller = _controller;
    if (controller != null) {
      controller.dispose();
    }
    _controller = null;
    _initialized = false;
    _wasActive = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError) {
      return const _FullscreenErrorPlaceholder();
    }

    final chewie = _chewieController;
    if (!_initialized || chewie == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Chewie(controller: chewie),
        Positioned(
          top: 16,
          right: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _FullscreenErrorPlaceholder extends StatelessWidget {
  const _FullscreenErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle =
        theme.textTheme.headlineSmall ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
    final bodyStyle =
        theme.textTheme.bodyMedium ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFF8E7D5),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFED6C02),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '404',
                style: headlineStyle.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '资源不存在或已被移除',
                textAlign: TextAlign.center,
                style: bodyStyle.copyWith(color: Colors.black54, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
