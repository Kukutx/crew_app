import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _picker = ImagePicker();

  final List<XFile> _attachments = [];
  bool _isSubmitting = false;

  bool get _canAddMoreAttachments => _attachments.length < _maxAttachments;

  Future<void> _pickImages() async {
    try {
      final remaining = _maxAttachments - _attachments.length;
      final files = await _picker.pickMultiImage(limit: remaining);
      if (!mounted || files.isEmpty) return;
      setState(() => _attachments.addAll(files.take(remaining)));
    } catch (e, st) {
      debugPrint('pickMultiImage error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("图片错误")),
      );
    }
  }

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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(loc.support_feedback_add_photo),
              onTap: () {
                Navigator.of(context).pop();
                _pickImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview(XFile file) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          return Image.memory(snap.data!, fit: BoxFit.cover);
        }
        if (snap.hasError) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }
        return const Center(
          child: SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;
    final loc = AppLocalizations.of(context)!;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    // TODO: 替换为真实提交逻辑
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.feedback_thanks)));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.support_feedback_title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${loc.support_feedback_description_label} *',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 6,
                        maxLength: _maxDescriptionLength,
                        decoration: InputDecoration(
                          hintText: loc.support_feedback_description_hint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        ),
                        validator: (v) {
                          final text = (v ?? '').trim();
                          if (text.isEmpty) {
                            return loc.support_feedback_description_required;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(loc.support_feedback_media_label,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ...List.generate(_attachments.length, (i) {
                            final file = _attachments[i];
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 90, height: 90,
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    child: _buildAttachmentPreview(file),
                                  ),
                                ),
                                Positioned(
                                  top: 4, right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _attachments.removeAt(i)),
                                    child: CrewAvatar(
                                      radius: 12,
                                      backgroundColor: theme.colorScheme.surface
                                          .withValues(alpha: 0.9),
                                      foregroundColor: theme.colorScheme.onSurface,
                                      child: const Icon(Icons.close, size: 16),
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
                                borderColor: theme.colorScheme.outline,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                                child: SizedBox(
                                  width: 90, height: 90,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add, size: 28),
                                      const SizedBox(height: 6),
                                      Text('${_attachments.length}/$_maxAttachments',
                                          style: theme.textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(loc.support_feedback_phone_label,
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: loc.support_feedback_phone_hint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                        ),
                        validator: (v) {
                          final t = (v ?? '').trim();
                          if (t.isEmpty) return null; // 可选
                          // 简单校验，可按需替换为更严格的正则
                          final ok = RegExp(r'^[\d\s+\-()]{6,}$').hasMatch(t);
                          return ok ? null : "输入格式不正确";
                        },
                      ),
                    ],
                  ),
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
                          width: 20, height: 20,
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
        child: Container(color: backgroundColor, child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
  });

  final Color color;
  final double strokeWidth = 1.5;
  final double dashLength = 6;
  final double gapLength = 4;
  final double borderRadius = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length);
        final extractPath = metric.extractPath(distance, end.toDouble());
        canvas.drawPath(extractPath, paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength ||
        old.borderRadius != borderRadius;
  }
}
