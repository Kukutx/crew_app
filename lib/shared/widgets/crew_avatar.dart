import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CrewAvatar extends StatelessWidget {
  const CrewAvatar({
    super.key,
    double? radius,
    double? size,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundImage,
    this.child,
    this.borderRadius,
    this.border,
    this.padding,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  })  : _radius = radius,
        _size = size,
        assert(radius == null || size == null, 'Cannot provide both radius and size'),
        assert(radius == null || radius >= 0),
        assert(size == null || size >= 0);

  final double? _radius;
  final double? _size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final ImageProvider<Object>? backgroundImage;
  final Widget? child;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final BoxFit fit;

  double get _effectiveSize => _size ?? (_radius ?? 20) * 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetPixels = (_effectiveSize * devicePixelRatio).round();
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(_effectiveSize / 3);
    final effectiveBackgroundColor = backgroundColor ??
        theme.colorScheme.surfaceContainerHighest;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onSurface;

    Widget buildPlaceholder() => Container(
          color: effectiveBackgroundColor,
        );

    Widget? buildBackgroundImage() {
      if (backgroundImage == null) {
        return null;
      }

      if (backgroundImage case final CachedNetworkImageProvider provider) {
        return CachedNetworkImage(
          imageUrl: provider.url,
          cacheKey: provider.cacheKey,
          httpHeaders: provider.headers,
          cacheManager: provider.cacheManager,
          memCacheHeight: provider.memCacheHeight ?? targetPixels,
          memCacheWidth: provider.memCacheWidth,
          maxHeightDiskCache: provider.maxHeight ?? targetPixels,
          maxWidthDiskCache: provider.maxWidth,
          fit: fit,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 150),
          placeholder: (_, __) => buildPlaceholder(),
          errorWidget: (_, __, ___) => buildPlaceholder(),
        );
      }

      return Image(
        image: backgroundImage!,
        fit: fit,
      );
    }

    Widget? content = child;
    if (content != null) {
      if (padding != null) {
        content = Padding(
          padding: padding!,
          child: content,
        );
      }
      content = DefaultTextStyle.merge(
        style: TextStyle(color: effectiveForegroundColor),
        child: IconTheme.merge(
          data: IconThemeData(color: effectiveForegroundColor),
          child: Align(
            alignment: alignment,
            child: content,
          ),
        ),
      );
    }

    return Container(
      width: _effectiveSize,
      height: _effectiveSize,
      decoration: BoxDecoration(
        color: backgroundImage == null ? effectiveBackgroundColor : null,
        borderRadius: effectiveBorderRadius,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImage == null) buildPlaceholder(),
          if (backgroundImage != null) buildBackgroundImage()!,
          if (content != null) content,
        ],
      ),
    );
  }
}
