import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GridHomePage extends StatelessWidget {
  const GridHomePage({super.key});

  // 示例图片，可替换为你的数据源
  final List<String> imgList = const [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
    'https://images.unsplash.com/photo-1520975928316-56c6f6f163a4',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba',
    'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?ixlib=rb-1.2.1',
  ];

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: imgList.length,
      itemBuilder: (context, index) => _item(context, index),
    );
  }

  Widget _item(BuildContext context, int index) {
    final img = imgList[index];
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showImage(context, img, index),
        child: Hero(
          tag: 'img_$index',
          child: CachedNetworkImage(
            imageUrl: '$img?w=800',
            fit: BoxFit.cover,
            placeholder: (c, _) => const AspectRatio(
              aspectRatio: 1,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (c, _, __) => const AspectRatio(
              aspectRatio: 1,
              child: Center(child: Icon(Icons.broken_image)),
            ),
          ),
        ),
      ),
    );
  }
  
  void _showImage(BuildContext context, String url, int index) {
    showDialog(
      context: context,
      barrierDismissible: true, // 关键：点遮罩可关闭
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SafeArea(
          // 防刘海遮挡
          child: Stack(
            children: [
              // ↓ 把占位/错误态做成“可点退出”的
              _ZoomableImage(url: '$url?w=1600', heroTag: 'img_$index'),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatelessWidget {
  const _ZoomableImage({required this.url, required this.heroTag});
  final String url;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final memW = (mq.size.longestSide * mq.devicePixelRatio).round();

    return Hero(
      tag: heroTag,
      child: InteractiveViewer(
        maxScale: 5,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          memCacheWidth: memW, // 防超大图卡顿
          placeholder: (c, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(c).maybePop(), // 占位期也能退出
            child: const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
          errorWidget: (c, _, __) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(c).maybePop(), // 失败时一键退出
            child: const SizedBox(
              height: 220,
              child: Center(child: Icon(Icons.broken_image, size: 48)),
            ),
          ),
        ),
      ),
    );
  }
}