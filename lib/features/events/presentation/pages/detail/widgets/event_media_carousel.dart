import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/widgets/event_image_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EventMediaCarousel extends StatefulWidget {
  final Event event;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final double? height;

  const EventMediaCarousel({
    super.key,
    required this.event,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    this.height,
  });

  @override
  State<EventMediaCarousel> createState() => _EventMediaCarouselState();
}

class _EventMediaCarouselState extends State<EventMediaCarousel> {
  late List<_EventMediaItem> _mediaItems;

  @override
  void initState() {
    super.initState();
    _mediaItems = _parseMediaItems(widget.event);
  }

  @override
  void didUpdateWidget(covariant EventMediaCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event != widget.event) {
      _mediaItems = _parseMediaItems(widget.event);
    }
  }

  List<_EventMediaItem> _parseMediaItems(Event event) {
    final images = event.imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map(_EventMediaItem.image);
    final videos = event.videoUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .map(_EventMediaItem.video);
    return [...images, ...videos];
  }

  @override
  Widget build(BuildContext context) {
    final mediaItems = _mediaItems;
    final fallbackUrl = widget.event.firstAvailableImageUrl;
    final hasMedia = mediaItems.isNotEmpty;

    final height = widget.height;

    final mediaContent = hasMedia
        ? PageView.builder(
            controller: widget.controller,
            itemCount: mediaItems.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (_, index) {
              final item = mediaItems[index];
              switch (item.type) {
                case _EventMediaType.image:
                  return _NetworkImageSlide(url: item.url);
                case _EventMediaType.video:
                  return _EventVideoPlayer(
                    key: ValueKey(item.url),
                    url: item.url,
                    isActive: widget.currentPage == index,
                  );
              }
            },
          )
        : _buildFallback(fallbackUrl);

    return Stack(
      children: [
        if (height != null)
          SizedBox(height: height, width: double.infinity, child: mediaContent)
        else
          AspectRatio(aspectRatio: 16 / 10, child: mediaContent),
        if (hasMedia && mediaItems.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaItems.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: widget.currentPage == index ? 10 : 8,
                  height: widget.currentPage == index ? 10 : 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == widget.currentPage
                        ? Colors.white
                        : Colors.white.withValues(alpha: .5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback(String? url) {
    if (url == null) {
      return const EventImagePlaceholder(aspectRatio: 16 / 10);
    }
    return _NetworkImageSlide(url: url);
  }
}

class _NetworkImageSlide extends StatelessWidget {
  const _NetworkImageSlide({
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.error),
      ),
    );
  }
}

enum _EventMediaType { image, video }

class _EventMediaItem {
  final _EventMediaType type;
  final String url;

  const _EventMediaItem._(this.type, this.url);

  factory _EventMediaItem.image(String url) =>
      _EventMediaItem._(_EventMediaType.image, url);

  factory _EventMediaItem.video(String url) =>
      _EventMediaItem._(_EventMediaType.video, url);
}

class _EventVideoPlayer extends StatefulWidget {
  const _EventVideoPlayer({
    super.key,
    required this.url,
    required this.isActive,
  });

  final String url;
  final bool isActive;

  @override
  State<_EventVideoPlayer> createState() => _EventVideoPlayerState();
}

class _EventVideoPlayerState extends State<_EventVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isInitialized = false;
  bool _userPaused = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant _EventVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _disposeControllers();
      _initialize();
    } else if (widget.isActive != oldWidget.isActive) {
      _syncPlaybackWithVisibility();
    }
  }

  Future<void> _initialize() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) {
      setState(() {
        _hasError = true;
        _isInitialized = false;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _videoController = controller;

    ChewieController? chewieController;
    var listenerAttached = false;

    try {
      await controller
          .initialize()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Video initialization timed out for ${widget.url}');
      });
      await controller.setLooping(true);
      await controller.setVolume(0);
      controller.addListener(_handlePlaybackStateChanged);
      listenerAttached = true;

      chewieController = ChewieController(
        videoPlayerController: controller,
        autoInitialize: false,
        autoPlay: false,
        looping: true,
        showControlsOnInitialize: false,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.white,
          handleColor: Colors.white,
          backgroundColor: Colors.black26,
          bufferedColor: Colors.white70,
        ),
      );

      if (!mounted) {
        if (listenerAttached) {
          controller.removeListener(_handlePlaybackStateChanged);
        }
        chewieController.dispose();
        await controller.dispose();
        _videoController = null;
        return;
      }

      setState(() {
        _chewieController = chewieController;
        _hasError = false;
        _isInitialized = true;
        _userPaused = false;
      });

      _syncPlaybackWithVisibility();
    } catch (_) {
      if (listenerAttached) {
        controller.removeListener(_handlePlaybackStateChanged);
      }
      chewieController?.dispose();
      await controller.dispose();
      _videoController = null;

      if (mounted) {
        setState(() {
          _chewieController = null;
          _hasError = true;
          _isInitialized = false;
          _userPaused = false;
        });
      }
    }
  }

  void _syncPlaybackWithVisibility() {
    final controller = _videoController;
    final chewieController = _chewieController;
    if (!_isInitialized || controller == null || chewieController == null) {
      return;
    }

    if (widget.isActive) {
      if (!_userPaused) {
        chewieController.play();
      }
    } else {
      chewieController.pause();
      controller.seekTo(Duration.zero);
      _userPaused = false;
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
    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_handlePlaybackStateChanged);
      controller.dispose();
    }
    _videoController = null;
    _isInitialized = false;
    _userPaused = false;
  }

  void _handlePlaybackStateChanged() {
    final controller = _videoController;
    if (!_isInitialized || controller == null || !mounted) {
      return;
    }

    final isPlaying = controller.value.isPlaying;
    if (!isPlaying && widget.isActive) {
      _userPaused = true;
    } else if (isPlaying) {
      _userPaused = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError) {
      return const EventImagePlaceholder(
        aspectRatio: 16 / 10,
        icon: Icons.videocam_off,
      );
    }

    final chewieController = _chewieController;
    if (!_isInitialized || chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Chewie(controller: chewieController),
        Positioned(
          top: 12,
          left: 12,
          child: IgnorePointer(
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
                    Icon(
                      Icons.videocam,
                      size: 16,
                      color: Colors.white,
                    ),
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
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
