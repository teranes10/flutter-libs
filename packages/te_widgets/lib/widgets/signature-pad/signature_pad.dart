import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Controls a [TSignaturePad]: clear it, read whether it has ink, export PNG.
class TSignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  Size _size = Size.zero;
  Color _penColor = Colors.black;
  double _penWidth = 3;

  /// Whether nothing has been drawn yet.
  bool get isEmpty => _strokes.every((s) => s.isEmpty);

  /// Whether at least one stroke was drawn.
  bool get isNotEmpty => !isEmpty;

  /// Number of strokes (pen-down to pen-up) drawn so far.
  int get strokeCount => _strokes.length;

  /// Removes the whole signature.
  void clear() {
    if (_strokes.isEmpty) return;
    _strokes.clear();
    notifyListeners();
  }

  /// Removes the last stroke.
  void undo() {
    if (_strokes.isEmpty) return;
    _strokes.removeLast();
    notifyListeners();
  }

  void _startStroke(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _extendStroke(Offset point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  /// Renders the signature to PNG bytes, or `null` when empty.
  ///
  /// [pixelRatio] scales the output resolution. [background] fills the image
  /// (use `Colors.transparent` for a transparent PNG).
  Future<Uint8List?> toPngBytes({double pixelRatio = 2, Color background = Colors.white}) async {
    if (isEmpty || _size.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio);
    canvas.drawRect(Offset.zero & _size, Paint()..color = background);
    _SignaturePainter(strokes: _strokes, color: _penColor, width: _penWidth, repaint: this).paint(canvas, _size);

    final image = await recorder.endRecording().toImage((_size.width * pixelRatio).ceil(), (_size.height * pixelRatio).ceil());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}

/// A touch / stylus signature capture canvas (proof-of-delivery sign-off).
///
/// Claims the drag gesture so it works inside scroll views. Pair it with a
/// [TSignaturePadController] to clear it or export the PNG.
///
/// ```dart
/// final controller = TSignaturePadController();
///
/// TSignaturePad(controller: controller, onChanged: (hasInk) => setState(() => signed = hasInk));
/// // later
/// final png = await controller.toPngBytes();
/// ```
class TSignaturePad extends StatefulWidget {
  /// The controller used to clear / export. Created internally when null.
  final TSignaturePadController? controller;

  /// Pad height. The width fills the parent.
  final double height;

  /// Ink colour.
  final Color? penColor;

  /// Ink thickness.
  final double penWidth;

  /// Hint shown until the first stroke.
  final String hint;

  /// Shows a Clear button inside the pad once there is a signature.
  final bool showClear;

  /// Called whenever the pad changes between empty and signed.
  final ValueChanged<bool>? onChanged;

  /// Creates a signature pad.
  const TSignaturePad({
    super.key,
    this.controller,
    this.height = 200,
    this.penColor,
    this.penWidth = 3,
    this.hint = 'Sign here',
    this.showClear = true,
    this.onChanged,
  });

  @override
  State<TSignaturePad> createState() => _TSignaturePadState();
}

class _TSignaturePadState extends State<TSignaturePad> {
  late TSignaturePadController _controller;
  bool _hadInk = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TSignaturePadController();
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant TSignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onChanged);
      if (oldWidget.controller == null) _controller.dispose();
      _controller = widget.controller ?? TSignaturePadController();
      _controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    final hasInk = _controller.isNotEmpty;
    if (hasInk != _hadInk) {
      _hadInk = hasInk;
      widget.onChanged?.call(hasInk);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pen = widget.penColor ?? colors.onSurface;
    _controller
      .._penColor = pen
      .._penWidth = widget.penWidth;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _controller._size = constraints.biggest;

          return Stack(
            children: [
              RawGestureDetector(
                behavior: HitTestBehavior.opaque,
                gestures: {
                  EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                    EagerGestureRecognizer.new,
                    (_) {},
                  ),
                },
                child: Listener(
                  onPointerDown: (e) => _controller._startStroke(e.localPosition),
                  onPointerMove: (e) => _controller._extendStroke(e.localPosition),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SignaturePainter(
                      strokes: _controller._strokes,
                      color: pen,
                      width: widget.penWidth,
                      repaint: _controller,
                    ),
                  ),
                ),
              ),
              if (_controller.isEmpty)
                IgnorePointer(
                  child: Center(
                    child: Text(widget.hint, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.outline)),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 30,
                child: IgnorePointer(child: Divider(height: 1, color: colors.outlineVariant)),
              ),
              if (widget.showClear && _controller.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: TButton(
                    text: 'Clear',
                    icon: HugeIcons.strokeRoundedRefresh,
                    type: TButtonType.text,
                    color: context.theme.danger,
                    onTap: _controller.clear,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double width;

  _SignaturePainter({required this.strokes, required this.color, required this.width, required Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, width / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
        continue;
      }

      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length - 1; i++) {
        final mid = Offset((stroke[i].dx + stroke[i + 1].dx) / 2, (stroke[i].dy + stroke[i + 1].dy) / 2);
        path.quadraticBezierTo(stroke[i].dx, stroke[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(stroke.last.dx, stroke.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width || oldDelegate.strokes != strokes;
}
