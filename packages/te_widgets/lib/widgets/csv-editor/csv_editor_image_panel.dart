part of 'csv_editor.dart';

/// Represents a locally picked image with its filename, raw bytes, and link status.
class _PickedImage {
  final String filename;
  final Uint8List bytes;
  final String extension;
  bool isReferenced = false;

  _PickedImage({
    required this.filename,
    required this.bytes,
    required this.extension,
  });
}

/// Manages bulk image picking, ZIP extraction, filename matching, and pre-upload.
/// Activated automatically when any column is [TCsvColumnType.image].
mixin _TCsvEditorImagePanel on _TCsvEditorStateContract, _TCsvEditorActions {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// All locally picked images, keyed by lowercased filename.
  final Map<String, _PickedImage> _pickedImages = {};

  bool _imagePanelExpanded = true;

  bool get _hasImageColumns => widget.columns.any((c) => c.type == TCsvColumnType.image);

  // ---------------------------------------------------------------------------
  // Image Picking & ZIP Extraction
  // ---------------------------------------------------------------------------

  Future<void> pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'zip'],
        allowMultiple: true,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      for (final f in result.files) {
        if (f.bytes == null) continue;
        if (f.extension?.toLowerCase() == 'zip') {
          _extractZip(f.bytes!);
        } else {
          _addPickedImage(f.name, f.bytes!, f.extension ?? 'jpg');
        }
      }
      _refreshImageReferences();
      setState(() {});
    } catch (e) {
      if (mounted) TToastService.error(context, 'Error picking images: $e');
    }
  }

  void _extractZip(Uint8List zipBytes) {
    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);
      int extractedCount = 0;
      for (final file in archive) {
        if (!file.isFile) continue;
        final name = file.name.split('/').last; // strip directory path
        if (name.isEmpty || name.startsWith('.')) continue; // ignore hidden files
        final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
        const imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
        if (!imageExts.contains(ext)) continue;

        final content = file.content;
        if (content is List<int>) {
          _addPickedImage(name, Uint8List.fromList(content), ext);
          extractedCount++;
        }
      }
      if (mounted && extractedCount > 0) {
        TToastService.success(context, 'Extracted $extractedCount images from ZIP archive.');
      }
    } catch (e) {
      if (mounted) TToastService.warning(context, 'Could not extract ZIP: $e');
    }
  }

  void _addPickedImage(String name, Uint8List bytes, String ext) {
    final key = name.toLowerCase().trim();
    _pickedImages[key] = _PickedImage(filename: name, bytes: bytes, extension: ext);
  }

  void removePickedImage(String filename) {
    _pickedImages.remove(filename.toLowerCase().trim());
    _refreshImageReferences();
    setState(() {});
  }

  void clearAllImages() {
    _pickedImages.clear();
    _refreshImageReferences();
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Filename Matching — Fallback Chain: Exact -> SKU -> Barcode -> Handle/Name
  // ---------------------------------------------------------------------------

  List<_PickedImage?> resolveImagesForRowColumn(TCsvRow row, TCsvColumn col) {
    final raw = row.getValue(col.key)?.toString() ?? '';
    if (raw.trim().isEmpty) return [];
    final filenames = raw.split(col.imageSeparator).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return filenames.map((fname) {
      final lowerName = fname.toLowerCase();

      // 1. Exact filename match (with or without extension)
      if (_pickedImages.containsKey(lowerName)) {
        return _pickedImages[lowerName];
      }
      for (final ext in ['jpg', 'jpeg', 'png', 'webp']) {
        if (_pickedImages.containsKey('$lowerName.$ext')) {
          return _pickedImages['$lowerName.$ext'];
        }
      }

      // 2. SKU-based match
      final sku = row.getValue('sku')?.toString().toLowerCase().trim();
      if (sku != null && sku.isNotEmpty) {
        final skuMatch = _pickedImages.entries.where((e) => e.key.startsWith(sku)).map((e) => e.value).firstOrNull;
        if (skuMatch != null) return skuMatch;
      }

      // 3. Barcode-based match
      final barcode = row.getValue('barcode')?.toString().toLowerCase().trim();
      if (barcode != null && barcode.isNotEmpty) {
        final barcodeMatch =
            _pickedImages[barcode] ?? _pickedImages['$barcode.jpg'] ?? _pickedImages['$barcode.png'] ?? _pickedImages['$barcode.webp'];
        if (barcodeMatch != null) return barcodeMatch;
      }

      // 4. Handle/name-based match
      final handle =
          (row.getValue('handle') ?? row.getValue('slug') ?? row.getValue('name'))?.toString().toLowerCase().replaceAll(' ', '-').trim();
      if (handle != null && handle.isNotEmpty) {
        final handleMatch = _pickedImages.entries.where((e) => e.key.startsWith(handle)).map((e) => e.value).firstOrNull;
        if (handleMatch != null) return handleMatch;
      }

      return null;
    }).toList();
  }

  void _refreshImageReferences() {
    for (final img in _pickedImages.values) {
      img.isReferenced = false;
    }
    for (final row in rows) {
      for (final col in widget.columns.where((c) => c.type == TCsvColumnType.image)) {
        final resolved = resolveImagesForRowColumn(row, col);
        for (final img in resolved) {
          img?.isReferenced = true;
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pre-Upload Handling
  // ---------------------------------------------------------------------------

  @override
  Future<void> uploadAndReplaceImageUrls() async {
    if (_pickedImages.isEmpty) return;

    final imageColsWithUpload = widget.columns.where(
      (c) => c.type == TCsvColumnType.image && c.uploadCallback != null,
    );
    if (imageColsWithUpload.isEmpty) return;

    final toUpload = <String, _PickedImage>{};
    for (final row in rows) {
      for (final col in imageColsWithUpload) {
        final resolved = resolveImagesForRowColumn(row, col);
        for (final img in resolved) {
          if (img != null) {
            toUpload[img.filename.toLowerCase()] = img;
          }
        }
      }
    }

    if (toUpload.isEmpty) return;

    final defaultCol = imageColsWithUpload.first;
    final urlMap = <String, String>{};

    for (final entry in toUpload.entries) {
      final img = entry.value;
      try {
        final file = PlatformFile(
          name: img.filename,
          size: img.bytes.length,
          bytes: img.bytes,
        );
        final serverUrl = await defaultCol.uploadCallback!(file);
        urlMap[img.filename.toLowerCase()] = serverUrl;
      } catch (e) {
        debugPrint('Image upload failed for ${img.filename}: $e');
      }
    }

    // Replace filenames with server URLs in all rows
    for (final row in rows) {
      for (final col in widget.columns.where((c) => c.type == TCsvColumnType.image)) {
        final raw = row.getValue(col.key)?.toString() ?? '';
        if (raw.trim().isEmpty) continue;
        final filenames = raw.split(col.imageSeparator).map((s) => s.trim()).toList();
        final resolved = filenames.map((fname) => urlMap[fname.toLowerCase()] ?? fname).toList();
        row.setValue(col.key, resolved.join(col.imageSeparator));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // UI Builders
  // ---------------------------------------------------------------------------

  Widget buildImagePanel(ColorScheme colors, bool isDark) {
    if (!_hasImageColumns) return const SizedBox.shrink();

    final unreferencedCount = _pickedImages.values.where((img) => !img.isReferenced).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        InkWell(
          onTap: () => setState(() => _imagePanelExpanded = !_imagePanelExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: TAlignedRow(
              wrapperModeThreshold: 1,
              left: [
                Icon(Icons.photo_library_outlined, size: 18, color: colors.primary),
                Text(
                  'Images & Media (${_pickedImages.length})',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: colors.onSurface),
                ),
                if (unreferencedCount > 0)
                  TChip(
                    text: '$unreferencedCount unmapped in CSV',
                    color: AppColors.warning,
                    type: TVariant.tonal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
              ],
              right: [
                if (_pickedImages.isNotEmpty)
                  TButton(
                    text: 'Clear All',
                    icon: Icons.delete_outline_rounded,
                    type: TButtonType.softText,
                    color: AppColors.danger,
                    size: TButtonSize.xxs,
                    onPressed: (_) => clearAllImages(),
                  ),
                TButton(
                  text: 'Add Images / ZIP',
                  icon: Icons.add_photo_alternate_outlined,
                  type: TButtonType.tonal,
                  size: TButtonSize.xs,
                  onPressed: (_) => pickImages(),
                ),
                Icon(
                  _imagePanelExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_imagePanelExpanded) ...[
          const SizedBox(height: 8),
          if (_pickedImages.isEmpty) _buildImageDropzone(colors, isDark) else _buildImageGallery(colors, isDark),
        ],
      ],
    );
  }

  Widget _buildImageDropzone(ColorScheme colors, bool isDark) {
    return InkWell(
      onTap: pickImages,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 28, color: colors.primary.withValues(alpha: 0.7)),
              const SizedBox(height: 8),
              Text(
                'Drop images or a ZIP here, or click to browse',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Auto-matches CSV rows by filename → SKU → barcode → handle/name',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(ColorScheme colors, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceContainerHigh : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _pickedImages.entries.map((entry) {
          final img = entry.value;
          return _buildImageTile(img, colors);
        }).toList(),
      ),
    );
  }

  Widget _buildImageTile(_PickedImage img, ColorScheme colors) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                img.bytes,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: colors.surfaceContainerHigh,
                  child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: img.isReferenced ? AppColors.success.withValues(alpha: 0.85) : AppColors.warning.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                img.isReferenced ? 'Linked' : 'Unmapped',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Text(
                img.filename,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => removePickedImage(img.filename),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 11, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildImageCell(TCsvRow row, TCsvColumn col, ColorScheme colors) {
    final raw = row.getValue(col.key)?.toString() ?? '';
    if (raw.trim().isEmpty) {
      return Text('—', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12));
    }

    final resolved = resolveImagesForRowColumn(row, col);
    final filenames = raw.split(col.imageSeparator).map((s) => s.trim()).toList();
    final hasUnmatched = resolved.any((img) => img == null);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...resolved.take(3).indexed.map((entry) {
          final i = entry.$1;
          final img = entry.$2;
          final fname = i < filenames.length ? filenames[i] : '';

          if (img == null) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TTooltip(
                message: 'No uploaded image matches "$fname"',
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.image_not_supported_outlined, size: 16, color: AppColors.warning),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TTooltip(
              message: img.filename,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.memory(
                  img.bytes,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 32,
                    height: 32,
                    color: colors.surfaceContainerHigh,
                    child: Icon(Icons.broken_image_outlined, size: 14, color: colors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          );
        }),
        if (resolved.length > 3) Text('+${resolved.length - 3}', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
        if (hasUnmatched)
          TTooltip(
            message: 'Some images in this row have no match in the image gallery',
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
            ),
          ),
      ],
    );
  }
}
