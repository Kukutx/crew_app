import 'package:flutter/material.dart';

/// 通用的图片占位符组件
/// 用于显示图片加载失败或无图片时的占位视图
class ImagePlaceholder extends StatelessWidget {
  final double? aspectRatio;
  final IconData icon;

  const ImagePlaceholder({
    super.key,
    this.aspectRatio,
    this.icon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.grey.shade500,
          size: 48,
        ),
      ),
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: placeholder,
      );
    }

    return placeholder;
  }
}

