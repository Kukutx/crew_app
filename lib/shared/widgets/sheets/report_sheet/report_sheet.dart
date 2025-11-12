import 'dart:typed_data';

import 'package:crew_app/shared/utils/media_picker_helper.dart';
import 'package:flutter/material.dart';

typedef ReportSheetSubmission = ({
  String type,
  String description,
  Uint8List? imageBytes,
  String? imageName,
});

class ReportSheet extends StatefulWidget {
  const ReportSheet({
    super.key,
    required this.title,
    required this.description,
    required this.typeLabel,
    required this.typeEmptyHint,
    required this.contentLabel,
    required this.contentHint,
    required this.attachmentLabel,
    required this.attachmentOptional,
    required this.attachmentAddLabel,
    required this.attachmentReplaceLabel,
    required this.attachmentEmptyLabel,
    required this.submitLabel,
    required this.cancelLabel,
    required this.reportTypes,
  }) : assert(reportTypes.length > 0, 'reportTypes cannot be empty');

  final String title;
  final String description;
  final String typeLabel;
  final String typeEmptyHint;
  final String contentLabel;
  final String contentHint;
  final String attachmentLabel;
  final String attachmentOptional;
  final String attachmentAddLabel;
  final String attachmentReplaceLabel;
  final String attachmentEmptyLabel;
  final String submitLabel;
  final String cancelLabel;
  final List<String> reportTypes;

  static Future<ReportSheetSubmission?> show({
    required BuildContext context,
    required String title,
    required String description,
    required String typeLabel,
    required String typeEmptyHint,
    required String contentLabel,
    required String contentHint,
    required String attachmentLabel,
    required String attachmentOptional,
    required String attachmentAddLabel,
    required String attachmentReplaceLabel,
    required String attachmentEmptyLabel,
    required String submitLabel,
    required String cancelLabel,
    required List<String> reportTypes,
  }) {
    return showModalBottomSheet<ReportSheetSubmission>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ReportSheet(
          title: title,
          description: description,
          typeLabel: typeLabel,
          typeEmptyHint: typeEmptyHint,
          contentLabel: contentLabel,
          contentHint: contentHint,
          attachmentLabel: attachmentLabel,
          attachmentOptional: attachmentOptional,
          attachmentAddLabel: attachmentAddLabel,
          attachmentReplaceLabel: attachmentReplaceLabel,
          attachmentEmptyLabel: attachmentEmptyLabel,
          submitLabel: submitLabel,
          cancelLabel: cancelLabel,
          reportTypes: reportTypes,
        );
      },
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  late String _selectedType = widget.reportTypes.first;
  late final TextEditingController _descriptionController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _typeTouched = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handlePickImage() async {
    final file = await MediaPickerHelper.pickImage();
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = file.path.split('/').last.split('\\').last;
    });
  }

  void _handleSubmit() {
    Navigator.of(context).pop<ReportSheetSubmission>((
      type: _selectedType,
      description: _descriptionController.text.trim(),
      imageBytes: _selectedImageBytes,
      imageName: _selectedImageName,
    ));
  }

  bool get _isSubmitEnabled => _descriptionController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha:0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              items: widget.reportTypes
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedType = value;
                  _typeTouched = true;
                });
              },
              decoration: InputDecoration(
                labelText: widget.typeLabel,
                errorText: _typeTouched && _selectedType.isEmpty
                    ? widget.typeEmptyHint
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: widget.contentLabel,
                hintText: widget.contentHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    widget.attachmentLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.attachmentOptional,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _handlePickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _selectedImageBytes == null
                        ? widget.attachmentAddLabel
                        : widget.attachmentReplaceLabel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedImageName ?? widget.attachmentEmptyLabel,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _selectedImageBytes!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(widget.cancelLabel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitEnabled ? _handleSubmit : null,
                    child: Text(widget.submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
