import 'dart:typed_data';

import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SupportFeedbackPage extends StatefulWidget {
  const SupportFeedbackPage({super.key});

  @override
  State<SupportFeedbackPage> createState() => _SupportFeedbackPageState();
}

class _SupportFeedbackPageState extends State<SupportFeedbackPage> {
  static const int _maxDescriptionLength = 100;
  static const int _maxAttachments = 4;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<XFile> _attachments = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_handleDescriptionChanged);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_handleDescriptionChanged);
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleDescriptionChanged() {
    setState(() {});
  }

  int get _currentDescriptionLength => _descriptionController.text.trim().length;

  bool get _canAddMoreAttachments => _attachments.length < _maxAttachments;

  Future<void> _showAddMediaSheet() async {
    if (!_canAddMoreAttachments) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.support_feedback_max_attachments)),
      );
      return;
    }

    final loc = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(loc.support_feedback_add_photo),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(loc.support_feedback_add_video),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    try {
      final remaining = _maxAttachments - _attachments.length;
      final files = await _picker.pickMultiImage(limit: remaining);
      if (files.isEmpty) {
        return;
      }
      setState(() {
        _attachments.addAll(files.take(remaining));
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to pick images: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final remaining = _maxAttachments - _attachments.length;
      if (remaining <= 0) {
        return;
      }
      final file = await _picker.pickVideo();
      if (file == null) {
        return;
      }
      setState(() {
        _attachments.add(file);
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to pick video: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _isVideo(XFile file) {
    final lower = file.path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.avi');
  }

  Widget _buildAttachmentPreview(XFile file) {
    final isVideo = _isVideo(file);
    if (isVideo) {
      return const Center(
        child: Icon(Icons.videocam_outlined, size: 32),
      );
    }

    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) {
      return;
    }
    final loc = AppLocalizations.of(context)!;
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.support_feedback_description_required)),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.feedback_thanks)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.support_feedback_title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.support_feedback_description_label} *',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${_currentDescriptionLength.clamp(0, _maxDescriptionLength)}/$_maxDescriptionLength',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      maxLength: _maxDescriptionLength,
                      decoration: InputDecoration(
                        hintText: loc.support_feedback_description_hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.support_feedback_media_label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...List.generate(_attachments.length, (index) {
                          final file = _attachments[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                  child: _buildAttachmentPreview(file),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _attachments.removeAt(index);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface.withOpacity(0.9),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (_canAddMoreAttachments)
                          GestureDetector(
                            onTap: _showAddMediaSheet,
                            child: _DashedBorder(
                              borderColor: Theme.of(context).colorScheme.outline,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.3),
                              child: SizedBox(
                                width: 90,
                                height: 90,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 28,
                                      color: Theme.of(context).colorScheme.outline,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_attachments.length}/$_maxAttachments',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      loc.support_feedback_phone_label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: loc.support_feedback_phone_hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(loc.support_feedback_submit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends StatelessWidget {
  const _DashedBorder({
    required this.child,
    required this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final Color borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: borderColor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: backgroundColor,
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.gapLength = 4,
    this.borderRadius = 12,
  });

  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(borderRadius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}
