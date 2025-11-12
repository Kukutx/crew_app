import 'package:flutter/material.dart';

class EventImagePlaceholder extends StatelessWidget {
  final double? aspectRatio;
  final IconData icon;

  const EventImagePlaceholder({
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

