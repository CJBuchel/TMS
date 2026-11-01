import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tms_client/widgets/signature_pad.dart';

const _pngMagic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

void main() {
  test('controller starts empty and clears', () {
    final c = SignaturePadController();
    expect(c.isEmpty, isTrue);
    c.startStroke(const Offset(1, 1));
    c.extendStroke(const Offset(5, 5));
    expect(c.isEmpty, isFalse);
    expect(c.strokes.single.length, 2);
    c.clear();
    expect(c.isEmpty, isTrue);
  });

  testWidgets('dragging on the pad records a stroke', (tester) async {
    final c = SignaturePadController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SignaturePad(controller: c)),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SignaturePad)),
    );
    await gesture.moveBy(const Offset(20, 10));
    await gesture.moveBy(const Offset(20, -10));
    await gesture.up();
    await tester.pump();

    expect(c.isEmpty, isFalse);
    expect(c.strokes.single.length, greaterThanOrEqualTo(3));
  });

  testWidgets('toPngBytes returns null when blank and a PNG once signed', (
    tester,
  ) async {
    final c = SignaturePadController();
    await tester.runAsync(() async {
      expect(await c.toPngBytes(size: const Size(200, 100)), isNull);

      c.startStroke(const Offset(10, 10));
      c.extendStroke(const Offset(100, 50));
      final png = await c.toPngBytes(size: const Size(200, 100));

      expect(png, isNotNull);
      expect(png!.sublist(0, 8), _pngMagic);
    });
  });
}
