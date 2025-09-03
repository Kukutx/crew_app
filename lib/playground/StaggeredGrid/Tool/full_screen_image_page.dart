import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.backgroundColor,
  });

  final String imageUrl;
  final Object heroTag;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              maxScale: 5,
              minScale: 0.8,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (c, _) => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (c, _, __) =>
                    const Icon(Icons.broken_image, color: Colors.white70, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



































// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class FullScreenImagePage extends StatelessWidget {
//   const FullScreenImagePage({
//     super.key,
//     required this.imageUrl,
//     required this.heroTag,
//     this.backgroundColor,
//     this.memCacheWidth,
//   });

//   final String imageUrl;
//   final Object heroTag;
//   final Color? backgroundColor;
//   final int? memCacheWidth; // 新增：限制全屏解码大小

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor ?? Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         bottom: false,
//         child: Center(
//           child: Hero(
//             tag: heroTag,
//             child: InteractiveViewer(
//               maxScale: 5,
//               minScale: 0.8,
//               child: CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 fit: BoxFit.contain,
//                 memCacheWidth: memCacheWidth,
//                 placeholder: (c, _) => GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () => Navigator.of(c).maybePop(),
//                   child: const SizedBox(
//                     height: 200,
//                     child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//                   ),
//                 ),
//                 errorWidget: (c, _, __) => GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () => Navigator.of(c).maybePop(),
//                   child: const Icon(Icons.broken_image, color: Colors.white70, size: 48),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
