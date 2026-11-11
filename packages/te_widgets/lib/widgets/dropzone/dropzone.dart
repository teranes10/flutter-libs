import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Wraps any widget so files can be dragged and dropped onto it.
///
/// While a file hovers over the child a "Drop it!" overlay is shown. When the
/// file is released the overlay plays a short "dropping" animation, then
/// [onDrop] is called with the dropped files (filtered by [allowedExtensions]).
///
/// ```dart
/// TDropzone(
///   allowedExtensions: const ['csv', 'json'],
///   onDrop: (files) => print(files.first.name),
///   child: MyUploadArea(),
/// )
/// ```
class TDropzone extends StatefulWidget {
  /// The widget that receives drops.
  final Widget child;

  /// Called with the dropped files after the drop animation starts.
  final ValueChanged<List<TFile>> onDrop;

  /// Called when dropped files are all rejected by [allowedExtensions].
  final VoidCallback? onRejected;

  /// Allowed file extensions (without dot, case-insensitive). Null allows any.
  final List<String>? allowedExtensions;

  /// Whether more than one file may be dropped. Defaults to false (first match only).
  final bool multiple;

  /// Whether the drop target is active.
  final bool enabled;

  /// Text shown while hovering.
  final String hoverText;

  /// Text shown after dropping.
  final String dropText;

  /// Corner radius of the overlay.
  final BorderRadius borderRadius;

  const TDropzone({
    super.key,
    required this.child,
    required this.onDrop,
    this.onRejected,
    this.allowedExtensions,
    this.multiple = false,
    this.enabled = true,
    this.hoverText = 'Drop Here!',
    this.dropText = '',
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<TDropzone> createState() => _TDropzoneState();
}

class _TDropzoneState extends State<TDropzone> with TickerProviderStateMixin {
  late final AnimationController _hover = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
  late final AnimationController _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 980));
  late final AnimationController _drop = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));

  bool _dropping = false;

  @override
  void dispose() {
    _hover.dispose();
    _bounce.dispose();
    _drop.dispose();
    super.dispose();
  }

  void _enter() {
    if (_dropping) return;
    _hover.forward();
    _bounce.repeat(reverse: true);
  }

  void _exit() {
    if (_dropping) return;
    _hover.reverse();
    _bounce.stop();
  }

  Future<void> _done(DropDoneDetails details) async {
    final allowed = widget.allowedExtensions?.map((e) => e.toLowerCase().replaceFirst('.', '')).toSet();
    var files = details.files.where((f) => f.name.isNotEmpty).toList();
    if (allowed != null) {
      files = files.where((f) => allowed.contains(f.name.split('.').last.toLowerCase())).toList();
    }
    if (!widget.multiple && files.length > 1) files = [files.first];

    if (files.isEmpty) {
      _bounce.stop();
      await _hover.reverse();
      widget.onRejected?.call();
      return;
    }

    setState(() => _dropping = true);
    _bounce.stop();
    _hover.value = 1;

    // Play the full drop animation, fade out, and only then hand over the files,
    // so parsing/rebuilding the page can't stall the overlay's closing frames.
    final result = await Future.wait(files.map((f) async => TFile(name: f.name, bytes: await f.readAsBytes())));
    await _drop.forward(from: 0);
    if (!mounted) return;
    await _hover.reverse();
    if (!mounted) return;
    setState(() => _dropping = false);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) widget.onDrop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DropTarget(
      enable: widget.enabled,
      onDragEntered: (_) => _enter(),
      onDragExited: (_) => _exit(),
      onDragDone: _done,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(builder: (context, constraints) {
                // Short targets (e.g. input fields) get an inline icon + text layout.
                final compact = constraints.maxHeight < 110;
                return AnimatedBuilder(
                  animation: Listenable.merge([_hover, _bounce, _drop]),
                  builder: (context, _) {
                    if (_hover.value == 0) return const SizedBox.shrink();
                    final t = Curves.easeOut.transform(_hover.value);
                    final d = _drop.value;
                    // Icon bobs while hovering; on drop it falls in, squashes and flips to a check.
                    final bob = _dropping ? 0.0 : -8 * Curves.easeInOut.transform(_bounce.value);
                    final fall = _dropping ? Curves.easeIn.transform((d / 0.25).clamp(0, 1)) * 14 : 0.0;
                    final scale =
                        _dropping ? (d < 0.25 ? 1 - 0.25 * d / 0.25 : 0.75 + 0.3 * Curves.easeOutBack.transform((d - 0.25) / 0.75)) : 1.0;
                    final ripple = _dropping ? Curves.easeOut.transform(d) : 0.0;

                    return Opacity(
                      opacity: t,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primaryContainer.withValues(alpha: 0.8 + 0.05 * ripple),
                              colors.primaryContainer.withValues(alpha: 0.9 + 0.06 * ripple),
                            ],
                          ),
                          borderRadius: widget.borderRadius,
                          border: Border.all(color: colors.primary.withAlpha(60), width: 1),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_dropping && !compact)
                              Container(
                                width: 60 + 260 * ripple,
                                height: 60 + 260 * ripple,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colors.onPrimaryContainer.withValues(alpha: 0.6 * (1 - ripple)), width: 3),
                                ),
                              ),
                            if (compact)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  Transform.scale(
                                    scale: scale,
                                    child: TIcon.raw(
                                      _dropping && d >= 0.25
                                          ? HugeIcons.strokeRoundedCheckmarkCircle01
                                          : HugeIcons.strokeRoundedFileDownload,
                                      size: 20,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                  Text(
                                    _dropping && d >= 0.25 ? widget.dropText : widget.hoverText,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: colors.onPrimaryContainer),
                                  ),
                                ],
                              )
                            else
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: Center(
                                      child: Transform.translate(
                                        offset: Offset(0, bob + fall),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: TIcon.raw(
                                            _dropping && d >= 0.25
                                                ? HugeIcons.strokeRoundedCheckmarkCircle01
                                                : HugeIcons.strokeRoundedFileDownload,
                                            size: 44,
                                            color: colors.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _dropping && d >= 0.25 ? widget.dropText : widget.hoverText,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colors.onPrimaryContainer),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
