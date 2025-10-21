import 'dart:math' as math;

import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      // 可按需配置：facing: CameraFacing.back,
      // detectionSpeed: DetectionSpeed.normal,
      // formats: [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(loc.qr_scanner_title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              // onDetect: (capture) { ... } // 如需回调在此处理
            ),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final cutOut = math.min(size.width * 0.72, 320.0);
                return CustomPaint(
                  painter: _ScannerOverlayPainter(
                    boxSize: cutOut,
                    overlayColor: Colors.black.withValues(alpha: 0.55),
                    borderColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 180 + bottomPadding,
            left: 0,
            right: 0,
            child: _TorchHint(controller: _controller, text: loc.qr_scanner_torch_hint),
          ),
          Positioned(
            bottom: 120 + bottomPadding,
            left: 0,
            right: 0,
            child: Text(
              loc.qr_scanner_instruction,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Row(
          children: [
            _BottomActionButton(
              icon: Icons.qr_code_rounded,
              label: loc.qr_scanner_my_code,
              onTap: () => _showUnavailableMessage(context),
            ),
            const SizedBox(width: 16),
            _BottomActionButton(
              icon: Icons.photo_outlined,
              label: loc.qr_scanner_album,
              onTap: () => _showUnavailableMessage(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnavailableMessage(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.feature_not_ready)),
    );
  }
}

class _TorchHint extends StatelessWidget {
  const _TorchHint({
    required this.controller,
    required this.text,
  });

  final MobileScannerController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = Colors.black.withValues(alpha: 0.6);

    return Center(
      child: GestureDetector(
        onTap: () => controller.toggleTorch(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 监听 controller（而非 controller.torchState）
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, state, _) {
                    final torchOn = state.torchState == TorchState.on;
                    return Icon(
                      torchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white24),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white.withValues(alpha: 0.08),
        ),
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.boxSize,
    required this.overlayColor,
    required this.borderColor,
  });

  final double boxSize;
  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = boxSize / 2;
    final cutOutRect = RRect.fromRectXY(
      Rect.fromCenter(center: center, width: boxSize, height: boxSize),
      24,
      24,
    );

    // 蒙层
    final overlayPath = Path()..addRect(Offset.zero & size);
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawPath(
      overlayPath,
      Paint()..color = overlayColor,
    );
    canvas.drawRRect(
      cutOutRect,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();

    // 边角
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 28;

    final left = center.dx - half;
    final right = center.dx + half;
    final top = center.dy - half;
    final bottom = center.dy + half;

    void drawCorner(double startX, double startY, double dx, double dy) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + dx * cornerLength, startY + dy * cornerLength),
        borderPaint,
      );
    }

    drawCorner(left, top + cornerLength, 0, -1);
    drawCorner(left, top, 1, 0);

    drawCorner(right - cornerLength, top, 1, 0);
    drawCorner(right, top, 0, 1);

    drawCorner(right, bottom - cornerLength, 0, 1);
    drawCorner(right, bottom, -1, 0);

    drawCorner(left + cornerLength, bottom, -1, 0);
    drawCorner(left, bottom, 0, -1);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return boxSize != oldDelegate.boxSize ||
        overlayColor != oldDelegate.overlayColor ||
        borderColor != oldDelegate.borderColor;
  }
}
