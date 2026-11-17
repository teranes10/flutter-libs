import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'blurhash.dart';

/// Paints a BlurHash as a smooth blurry image: use it as a placeholder while the real image loads.
///
/// Fills its parent unless [width] / [height] are given. The hash is decoded once (and again only if it changes).
class TBlurHashView extends StatefulWidget {
  final String hash;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Resolution the hash is decoded at; it is stretched to the widget size, so small is fine.
  final int decodeSize;

  const TBlurHashView({super.key, required this.hash, this.width, this.height, this.fit = BoxFit.cover, this.decodeSize = 32});

  @override
  State<TBlurHashView> createState() => _TBlurHashViewState();
}

class _TBlurHashViewState extends State<TBlurHashView> {
  // Decoded previews are shared, so a view that is rebuilt (or a second view of the same hash) paints immediately
  // instead of flashing empty while it decodes again.
  static final _cache = <String, ui.Image>{};

  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _image = _cache[_key];
    if (_image == null) _load();
  }

  String get _key => '${widget.hash}@${widget.decodeSize}';

  @override
  void didUpdateWidget(TBlurHashView old) {
    super.didUpdateWidget(old);
    if (old.hash != widget.hash || old.decodeSize != widget.decodeSize) {
      _image = _cache[_key];
      if (_image == null) _load();
    }
  }

  Future<void> _load() async {
    final hash = widget.hash;
    final img = await TBlurHash.toImage(hash, width: widget.decodeSize, height: widget.decodeSize);
    if (img == null) return;
    _cache[_key] = img;
    if (!mounted || hash != widget.hash) return;
    setState(() => _image = img);
  }

  @override
  Widget build(BuildContext context) {
    final img = _image;
    final child = img == null
        ? const SizedBox.shrink()
        : RawImage(
            key: ValueKey(img),
            image: img,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            filterQuality: FilterQuality.medium);
    // Fades in when the decode finishes, so the first paint is a soft appearance rather than a pop.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      layoutBuilder: (current, previous) => Stack(fit: StackFit.passthrough, children: [...previous, if (current != null) current]),
      child: child,
    );
  }
}
