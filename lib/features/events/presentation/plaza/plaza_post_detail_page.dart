import 'dart:math';

import 'package:flutter/material.dart';

import 'package:crew_app/features/events/presentation/widgets/plaza_post_card.dart';

import 'plaza_post_comments_sheet.dart';

class PlazaPostDetailPage extends StatelessWidget {
  final PlazaPost post;

  const PlazaPostDetailPage({super.key, required this.post});

  static Route<void> route({required PlazaPost post}) {
    return MaterialPageRoute(
      builder: (context) => PlazaPostDetailPage(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(theme.brightness == Brightness.dark ? '瞬间详情' : '瞬间'),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _PlazaPostMediaGallery(post: post),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: PlazaPostCard(
              post: post,
              margin: EdgeInsets.zero,
              onCommentTap: () => showPlazaPostCommentsSheet(context, post),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlazaPostMediaGallery extends StatefulWidget {
  final PlazaPost post;

  const _PlazaPostMediaGallery({required this.post});

  @override
  State<_PlazaPostMediaGallery> createState() => _PlazaPostMediaGalleryState();
}

class _PlazaPostMediaGalleryState extends State<_PlazaPostMediaGallery> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaAssets = widget.post.mediaAssets;
    final galleryHeight = max(
      MediaQuery.of(context).size.height * 0.55,
      320.0,
    );

    if (mediaAssets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: galleryHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.post.accentColor.withValues(alpha: 0.9),
                  widget.post.accentColor.withValues(alpha: 0.55),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.post.previewLabel ?? widget.post.content,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: galleryHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: mediaAssets.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final asset = mediaAssets[index];
              return Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
          if (mediaAssets.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(mediaAssets.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
