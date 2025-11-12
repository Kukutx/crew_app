import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 显示途径点备注编辑 Sheet
Future<String?> showWaypointNoteSheet({
  required BuildContext context,
  required LatLng waypoint,
  required int index,
  String? currentNote,
  required String title, // "去程" 或 "返程"
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _WaypointNoteSheet(
      waypoint: waypoint,
      index: index,
      currentNote: currentNote,
      title: title,
    ),
  );
}

class _WaypointNoteSheet extends StatefulWidget {
  const _WaypointNoteSheet({
    required this.waypoint,
    required this.index,
    this.currentNote,
    required this.title,
  });

  final LatLng waypoint;
  final int index;
  final String? currentNote;
  final String title;

  @override
  State<_WaypointNoteSheet> createState() => _WaypointNoteSheetState();
}

class _WaypointNoteSheetState extends State<_WaypointNoteSheet> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNote ?? '');
    // 延迟聚焦，等待动画完成
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    final note = _controller.text.trim();
    Navigator.of(context).pop(note.isEmpty ? null : note);
  }

  void _delete() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽手柄
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.title} - 途径点 ${widget.index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.waypoint.latitude.toStringAsFixed(6)}, ${widget.waypoint.longitude.toStringAsFixed(6)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 输入区域
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText: '添加备注（如：休息点、加油站、景点等）',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // 删除按钮
                      if (widget.currentNote != null && widget.currentNote!.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _delete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('删除备注'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (widget.currentNote != null && widget.currentNote!.isNotEmpty)
                        const SizedBox(width: 12),
                      // 保存按钮
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check),
                          label: const Text('保存'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

