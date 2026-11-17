import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Upload an image and get a tiny base64 thumbnail for `initializeApp(glassImageThumbnail: ...)`: the blurred "fade"
/// stage of the glass background that shows between the BlurHash and the full image.
class ThumbnailPage extends StatefulWidget {
  const ThumbnailPage({super.key});

  @override
  State<ThumbnailPage> createState() => _ThumbnailPageState();
}

class _ThumbnailPageState extends State<ThumbnailPage> {
  Uint8List? _bytes;
  String? _name;
  Uint8List? _thumb;
  String? _base64;
  int _width = 48;
  double _blur = 3;
  bool _busy = false;
  int _run = 0;

  Future<void> _pick() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      final bytes = await files.first.readAsBytes();
      setState(() {
        _bytes = bytes;
        _name = files.first.name;
      });
      await _generate();
    } catch (e) {
      if (mounted) TToastService.error(context, 'Could not read the image: $e');
    }
  }

  Future<void> _generate() async {
    final bytes = _bytes;
    if (bytes == null) return;
    final run = ++_run;
    setState(() => _busy = true);
    final png = await TImageThumbnail.generate(bytes, width: _width);
    if (!mounted || run != _run) return;
    setState(() {
      _thumb = png;
      _base64 = png == null ? null : base64Encode(png);
      _busy = false;
    });
    if (png == null) TToastService.error(context, 'This image could not be decoded.');
  }

  String _kb(int bytes) => bytes < 1024 ? '$bytes B' : '${(bytes / 1024).toStringAsFixed(1)} KB';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final thumb = _thumb;
    final b64 = _base64;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thumbnail Generator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'The glass background loads in stages: BlurHash, then a tiny blurred thumbnail, then the full image. '
            'Generate the thumbnail here and pass it to initializeApp(glassImageThumbnail: ...). It is a few KB of base64 '
            'in your code, so it is in memory at startup and shows instantly, with no storage or network read. '
            'Everything runs locally.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TCard(
            title: 'Image',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TButton(text: _bytes == null ? 'Choose image' : 'Change image', icon: Icons.image_outlined, onTap: _pick),
                    const SizedBox(width: 12),
                    if (_name != null) Flexible(child: Text(_name!, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Thumbnail width: $_width px', style: TextStyle(color: colors.onSurfaceVariant)),
                TSlider(
                  value: _width.toDouble(),
                  min: 16,
                  max: 128,
                  divisions: 14,
                  onValueChanged: (v) {
                    setState(() => _width = v!.round());
                    _generate();
                  },
                ),
                Text(
                  'Smaller is lighter. 32-64 px is plenty for a blurred shade; it is stretched to the screen.',
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text('Preview blur: ${_blur.round()}', style: TextStyle(color: colors.onSurfaceVariant)),
                TSlider(value: _blur, min: 0, max: 30, onValueChanged: (v) => setState(() => _blur = v!)),
              ],
            ),
          ),
          if (_bytes != null) ...[
            const SizedBox(height: 16),
            TCard(
              title: 'Result',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _preview(
                        'Original (tap for full screen)',
                        TImage(bytes: _bytes, width: 240, height: 160, padding: 0, fullScreenPreview: true),
                        colors,
                      ),
                      _preview(
                        'Thumbnail (tap for full screen)',
                        thumb == null
                            ? const SizedBox.shrink()
                            : TImage(bytes: thumb, width: 240, height: 160, padding: 0, fit: BoxFit.contain, fullScreenPreview: true),
                        colors,
                      ),
                      _preview(
                        'As glass background',
                        thumb == null
                            ? const SizedBox.shrink()
                            : ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(sigmaX: _blur, sigmaY: _blur, tileMode: TileMode.mirror),
                                child: Image.memory(thumb, fit: BoxFit.cover, filterQuality: FilterQuality.medium),
                              ),
                        colors,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_busy) const LinearProgressIndicator(),
                  if (thumb != null && b64 != null) ...[
                    Text(
                      'PNG ${_kb(thumb.length)}  ·  base64 ${_kb(b64.length)} (${b64.length} characters)',
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TCopyButton(text: b64, label: 'Copy base64'),
                        const SizedBox(width: 8),
                        TCopyButton(text: _snippet(b64), label: 'Copy initializeApp snippet'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 160),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: colors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                      child: SingleChildScrollView(
                        child: SelectableText(_snippet(b64), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _snippet(String b64) => "await initializeApp(\n  glassImageAsset: 'assets/bg.jpg',\n  glassImageThumbnail: '$b64',\n);";

  Widget _preview(String label, Widget child, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: colors.surfaceContainer,
            child: SizedBox(width: 240, height: 160, child: child),
          ),
        ),
      ],
    );
  }
}
