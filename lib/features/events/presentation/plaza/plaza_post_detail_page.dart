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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _PlazaPostMediaGallery(post: post),
          const SizedBox(height: 16),
          PlazaPostCard(
            post: post,
            margin: EdgeInsets.zero,
            onCommentTap: () => showPlazaPostCommentsSheet(context, post),
          ),
        ],
      ),
    );
  }
}

class _PlazaPostMediaGallery extends StatelessWidget {
  final PlazaPost post;

  const _PlazaPostMediaGallery({required this.post});

  @override
  Widget build(BuildContext context) {
    final mediaAssets = post.mediaAssets;
    if (mediaAssets.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 340,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                post.accentColor.withValues(alpha: 0.9),
                post.accentColor.withValues(alpha: 0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            post.previewLabel ?? post.content,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final assets = mediaAssets.take(4).toList(growable: false);
    final crossAxisCount = min(2, assets.length);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: assets.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final asset = assets[index];
            return Image.asset(
              asset,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
