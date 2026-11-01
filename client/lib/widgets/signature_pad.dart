import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Holds the strokes drawn on a [SignaturePad] and exports them as a PNG.
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];

  /// The strokes drawn so far (each stroke is a list of points).
  List<List<Offset>> get strokes => List.unmodifiable(_strokes);

  /// True when nothing has been drawn.
  bool get isEmpty => _strokes.isEmpty;

  void startStroke(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void extendStroke(Offset point) {
    if (_strokes.isEmpty) {
      startStroke(point);
      return;
    }
    _strokes.last.add(point);
    notifyListeners();
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }

  /// Renders the signature (black ink on white) as PNG bytes.
  ///
  /// [size] is the logical size of the pad and [pixelRatio] scales the output.
  /// Returns null if nothing has been drawn.
  Future<Uint8List?> toPngBytes({
    required Size size,
    double pixelRatio = 2.0,
    Color inkColor = Colors.black,
    Color backgroundColor = Colors.white,
    double strokeWidth = 3.0,
  }) async {
    if (isEmpty || size.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    paintSignatureStrokes(canvas, _strokes, inkColor, strokeWidth);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }
}

/// Draws [strokes] onto [canvas]. A single-point stroke is drawn as a dot.
void paintSignatureStrokes(
  Canvas canvas,
  List<List<Offset>> strokes,
  Color color,
  double strokeWidth,
) {
  final linePaint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;
  final dotPaint = Paint()..color = color;

  for (final stroke in strokes) {
    if (stroke.length == 1) {
      canvas.drawCircle(stroke.first, strokeWidth / 2, dotPaint);
      continue;
    }
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (final point in stroke.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);
  }
}

class _SignaturePainter extends CustomPainter {
  final SignaturePadController controller;
  final Color color;
  final double strokeWidth;

  _SignaturePainter(this.controller, this.color, this.strokeWidth)
    : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    paintSignatureStrokes(canvas, controller.strokes, color, strokeWidth);
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.controller != controller ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// A drawing surface for capturing a hand-drawn signature (touch, pen or mouse).
class SignaturePad extends StatelessWidget {
  final SignaturePadController controller;
  final double height;
  final Color inkColor;
  final double strokeWidth;

  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 200,
    this.inkColor = Colors.black,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        // Listener (instead of GestureDetector) so drawing isn't stolen by a
        // surrounding scroll view and works the same for touch, pen and mouse.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => controller.startStroke(e.localPosition),
          onPointerMove: (e) => controller.extendStroke(e.localPosition),
          child: CustomPaint(
            painter: _SignaturePainter(controller, inkColor, strokeWidth),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
