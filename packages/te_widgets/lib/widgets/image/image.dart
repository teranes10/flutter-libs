import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:te_widgets/helpers/image-storage/image_storage.dart';
import 'package:te_widgets/te_widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// An image widget with preview, fallback, and optional title/subtitle.
///
/// `TImage` provides an advanced image display with:
/// - Network image loading with fallback
/// - Explicit [width], [height], and [size] controls
/// - Aspect ratio calculation and auto-dimensions (width-only or height-only)
/// - Custom cropping behavior and alignment ([alignment], e.g. [Alignment.topCenter], [Alignment.bottomCenter], [Alignment.center])
/// - Click to preview with zoom (using PhotoView)
/// - Custom shapes (rounded, circle)
/// - Title and subtitle support (inline or hover overlay)
/// - Placeholder images
/// - Stable persistent caching via [TImageStorage] (set [forceCache] to `true`)
///
/// ## Basic Usage
///
/// ```dart
/// TImage(
///   url: 'https://example.com/image.jpg',
///   size: 100,
/// )
/// ```
///
/// ## Width with auto height or aspect ratio
///
/// ```dart
/// TImage(
///   url: 'https://example.com/image.jpg',
///   width: 200,
///   aspectRatio: 16 / 9,
///   alignment: Alignment.topCenter, // crops keeping top visible
/// )
/// ```
///
/// ## Circle Image
///
/// ```dart
/// TImage.circle(
///   url: user.avatarUrl,
///   size: 60,
///   title: user.name,
///   subTitle: user.role,
/// )
/// ```
///
/// ## Profile Image
///
/// ```dart
/// TImage.profile(
///   url: user.avatarUrl,
///   name: user.name,
///   role: user.role,
///   size: 42,
/// )
/// ```
///
/// See also:
/// - [TIcon] for icon display
class TImage extends StatefulWidget with TPopupMixin {
  /// The URL of the image to display.
  final String? url;

  /// The size of the image (width and height for square images).
  ///
  /// Defaults to 80 when [width] and [height] are not specified.
  final double? size;

  /// Explicit width of the image. If [height] is null:
  /// - If [aspectRatio] is provided, height is calculated as `width / aspectRatio`.
  /// - If [aspectRatio] is null, height adapts automatically to the content.
  final double? width;

  /// Explicit height of the image. If [width] is null:
  /// - If [aspectRatio] is provided, width is calculated as `height * aspectRatio`.
  /// - If [aspectRatio] is null, width adapts automatically to the content.
  final double? height;

  /// The size of the preview when clicked.
  ///
  /// Defaults to 350.
  final double previewSize;

  /// The aspect ratio of the image (width / height).
  ///
  /// When used with [width], height is computed as `width / aspectRatio`.
  /// When used with [height], width is computed as `height * aspectRatio`.
  /// When used with [size], height is computed as `size / aspectRatio`.
  final double? aspectRatio;

  /// How to align and crop the image within its bounds.
  ///
  /// Defaults to [Alignment.center]. Use [Alignment.topCenter], [Alignment.bottomCenter],
  /// [Alignment.centerLeft], [Alignment.centerRight], etc. for custom cropping.
  final AlignmentGeometry alignment;

  /// The placeholder image path (supports package assets).
  ///
  /// Defaults to 'package:te_widgets/assets/icons/no_image.png'.
  final String placeholder;

  /// The border shape of the image.
  final ShapeBorder border;

  /// Padding around the image.
  ///
  /// Defaults to 5.
  final double padding;

  /// How the image should fit within its bounds.
  ///
  /// Defaults to [BoxFit.cover].
  final BoxFit fit;

  /// Background color for the image container.
  final Color? color;

  /// Optional title text displayed next to the image.
  final String? title;

  /// Optional subtitle text displayed below the title.
  final String? subTitle;

  /// Custom color for the title text.
  final Color? titleColor;

  /// Custom color for the subtitle text.
  final Color? subTitleColor;

  /// Whether the image preview is disabled.
  @override
  final bool disabled;

  /// Callback fired when the preview is shown.
  @override
  final VoidCallback? onShow;

  /// Callback fired when the preview is hidden.
  @override
  final VoidCallback? onHide;

  /// Custom cache key for the image.
  ///
  /// If null, uses the image URL as the cache key.
  final String? cacheKey;

  /// Custom cache manager for advanced cache control.
  ///
  /// If null, uses the default cache manager from CachedNetworkImage.
  final BaseCacheManager? cacheManager;

  final TextOverflow? textOverflow;
  final int? maxLines;

  /// When `true`, the image is downloaded once and stored persistently in
  /// **IndexedDB** (web) or the **app documents directory** (Android/iOS/desktop)
  /// via [TImageStorage].
  final bool forceCache;

  /// Direct raw bytes for the image (optional).
  final Uint8List? bytes;

  /// Whether to show the title and subtitle in a translucent hover overlay on top of the image.
  final bool showTitleSubtitleOverlayOnHover;

  /// Alias for [showTitleSubtitleOverlayOnHover].
  final bool overlayTitleSubtitle;

  final VoidCallback? onTap;

  /// Creates an image widget.
  const TImage({
    super.key,
    this.url,
    this.bytes,
    this.size,
    this.width,
    this.height,
    this.aspectRatio,
    this.alignment = Alignment.center,
    this.previewSize = 350,
    this.placeholder = 'package:te_widgets/assets/icons/no_image.png',
    this.border = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    this.padding = 5,
    this.fit = BoxFit.cover,
    this.color,
    this.title,
    this.subTitle,
    this.titleColor,
    this.subTitleColor,
    this.disabled = false,
    this.onShow,
    this.onHide,
    this.cacheKey,
    this.cacheManager,
    this.textOverflow,
    this.maxLines,
    this.forceCache = false,
    this.showTitleSubtitleOverlayOnHover = false,
    this.overlayTitleSubtitle = false,
    this.onTap,
  });

  /// Creates a circular image widget.
  const TImage.circle({
    super.key,
    this.url,
    this.bytes,
    this.size,
    this.width,
    this.height,
    this.aspectRatio,
    this.alignment = Alignment.center,
    this.previewSize = 350,
    this.placeholder = 'package:te_widgets/assets/icons/no_image.png',
    this.border = const CircleBorder(),
    this.padding = 5,
    this.fit = BoxFit.contain,
    this.color,
    this.title,
    this.subTitle,
    this.titleColor,
    this.subTitleColor,
    this.disabled = false,
    this.onShow,
    this.onHide,
    this.cacheKey,
    this.cacheManager,
    this.maxLines,
    this.textOverflow,
    this.forceCache = false,
    this.showTitleSubtitleOverlayOnHover = false,
    this.overlayTitleSubtitle = false,
    this.onTap,
  });

  /// Creates a profile image with default styling.
  ///
  /// Uses a circular shape with a profile placeholder.
  static TImage profile({
    String? url,
    String? name,
    String? role,
    double? size = 42,
    double? width,
    double? height,
    double? aspectRatio,
    AlignmentGeometry alignment = Alignment.center,
    double padding = 5,
    bool forceCache = false,
  }) {
    return TImage.circle(
      url: url,
      placeholder: 'package:te_widgets/assets/icons/profile.png',
      title: name,
      subTitle: role,
      size: size,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      alignment: alignment,
      padding: padding,
      disabled: true,
      forceCache: forceCache,
    );
  }

  @override
  State<TImage> createState() => _TImageState();

  @override
  TPopupAlignment get popupAlignment => TPopupAlignment.rightTop;
}

// ---------------------------------------------------------------------------
// In-memory map: url → resolved bytes (avoids re-downloading on rebuild).
// Lives for the app lifetime, which is fine — these are thumbnail/image bytes.
// Used only by the forceCache path, which stores raw bytes it fully owns.
// ---------------------------------------------------------------------------
final Map<String, Uint8List> _forceCacheMemory = {};

class _TImageState extends State<TImage> with TPopupStateMixin<TImage> {
  @override
  double get contentMinWidth => widget.aspectRatio != null ? (widget.previewSize / widget.aspectRatio!) : widget.previewSize;
  @override
  double get contentMinHeight => widget.aspectRatio != null ? (widget.previewSize / widget.aspectRatio!) : widget.previewSize;

  double? get effectiveWidth {
    if (widget.width != null) {
      return widget.width;
    }
    if (widget.height != null) {
      if (widget.aspectRatio != null) {
        return widget.height! * widget.aspectRatio!;
      }
      return null; // auto width
    }
    return widget.size ?? 80.0;
  }

  double? get effectiveHeight {
    if (widget.height != null) {
      return widget.height;
    }
    if (widget.width != null) {
      if (widget.aspectRatio != null) {
        return widget.width! / widget.aspectRatio!;
      }
      return null; // auto height
    }
    final s = widget.size ?? 80.0;
    if (widget.aspectRatio != null) {
      return s / widget.aspectRatio!;
    }
    return s;
  }

  double? get effectiveImageWidth {
    final w = effectiveWidth;
    if (w == null) return null;
    return math.max(0.0, w - widget.padding);
  }

  double? get effectiveImageHeight {
    final h = effectiveHeight;
    if (h == null) return null;
    return math.max(0.0, h - widget.padding);
  }

  Alignment get _resolvedAlignment {
    if (widget.alignment is Alignment) {
      return widget.alignment as Alignment;
    }
    return widget.alignment.resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
  }

  /// Future that resolves image bytes when [TImage.forceCache] is true.
  /// Kept as a field so rebuilds re-use the same Future (no re-download).
  Future<Uint8List?>? _forceCacheFuture;

  /// Future that resolves once the default (non-forceCache) network image has
  /// been precached into Flutter's own [ImageCache]. Kept as a field, and
  /// only recreated when the URL actually changes (see [didUpdateWidget]),
  /// so incidental rebuilds — e.g. from InkWell's hover/tap state changes —
  /// do NOT retrigger a decode or re-touch the image's texture upload.
  Future<void>? _precacheFuture;

  /// The provider backing [_precacheFuture]. Re-used by the actual `Image`
  /// widget so we resolve the exact same provider we precached, keeping a
  /// single decode pipeline instead of racing two provider instances.
  ImageProvider? _networkProvider;

  /// The url/cacheKey/forceCache combination that [_networkProvider] and
  /// [_precacheFuture] were last resolved for. Used to detect when a real
  /// re-precache is needed (url changed) vs. an incidental rebuild.
  String? _precachedFor;

  @override
  void initState() {
    super.initState();
    _initForceCacheFuture();
    // NOTE: precache is intentionally NOT started here. `precacheImage`
    // calls `createLocalImageConfiguration(context)`, which does an
    // inherited-widget lookup (MediaQuery) — illegal before initState()
    // has finished. It's kicked off from didChangeDependencies() instead,
    // which runs right after initState() completes and re-runs whenever
    // an inherited dependency (e.g. MediaQuery) actually changes.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.forceCache) {
      _maybeInitPrecache();
    }
  }

  @override
  void didUpdateWidget(TImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.forceCache != widget.forceCache) {
      _initForceCacheFuture();
    }
    if (!widget.forceCache) {
      _maybeInitPrecache();
    }
  }

  void _initForceCacheFuture() {
    if (widget.forceCache && widget.url != null && widget.url!.isNotEmpty) {
      _forceCacheFuture = _resolveBytes(widget.url!);
    } else {
      _forceCacheFuture = null;
    }
  }

  /// Sets up precaching for the default (non-forceCache) network image path,
  /// but only if the effective (url, cacheKey) pair actually changed since
  /// the last time we resolved it — safe to call from both
  /// [didChangeDependencies] (which can fire repeatedly, e.g. on theme or
  /// MediaQuery changes) and [didUpdateWidget], without re-triggering a
  /// decode on every incidental rebuild.
  ///
  /// Uses Flutter's own [ImageCache] via [precacheImage] rather than a
  /// hand-rolled provider cache. A hand-rolled cache of raw [ImageProvider]
  /// instances has no lifecycle management, so reusing a provider whose
  /// underlying image stream/codec has already been disposed can lead to
  /// the renderer trying to upload an empty/disposed frame as a texture.
  /// Deferring to [ImageCache] avoids that: it's the single source of truth
  /// the renderer itself reads from.
  void _maybeInitPrecache() {
    final url = widget.url;
    final identity = url != null && url.isNotEmpty ? '$url|${widget.cacheKey}' : null;

    if (identity == _precachedFor) {
      return; // Nothing changed — keep the existing provider/future as-is.
    }
    _precachedFor = identity;

    if (url != null && url.isNotEmpty) {
      final provider = CachedNetworkImageProvider(
        url,
        cacheKey: widget.cacheKey,
        cacheManager: widget.cacheManager,
      );
      _networkProvider = provider;
      _precacheFuture = precacheImage(provider, context).catchError((_) {
        // Swallow here; the FutureBuilder's `hasError`/`done` state combo
        // in _buildImage() drives the fallback UI. We don't want an
        // unhandled rejection surfacing as a Zone error.
      });
      // No manual setState() needed: didChangeDependencies()/didUpdateWidget()
      // are always followed synchronously by build() in the same pipeline
      // pass, so build() will already see the freshly-set fields above.
    } else {
      _networkProvider = null;
      _precacheFuture = null;
    }
  }

  /// Resolves image bytes from the persistent store, downloading if needed.
  Future<Uint8List?> _resolveBytes(String url) async {
    // 1. Hot path: already decoded this session.
    if (_forceCacheMemory.containsKey(url)) {
      return _forceCacheMemory[url];
    }

    final key = TImageStorage.urlToKey(url);

    // 2. Try loading from the persistent store.
    Uint8List? bytes = await TImageStorage.loadImageByKey(key);

    // 3. Not cached yet — download, persist, then load bytes.
    bytes ??= await _resolveLocalRef(url, key);

    if (bytes != null) {
      _forceCacheMemory[url] = bytes;
    }

    return bytes;
  }

  Future<Uint8List?> _resolveLocalRef(String url, String key) async {
    final localRef = await TImageStorage.downloadAndCacheImage(url);
    if (localRef == null || localRef == url) return null;
    return await TImageStorage.loadImage(localRef);
  }

  Widget get fallbackImage {
    final isPackageAsset = widget.placeholder.startsWith('package:');

    String assetPath = widget.placeholder;
    String? package;
    if (isPackageAsset) {
      final parts = widget.placeholder.substring(8).split('/');
      package = parts.first;
      assetPath = parts.sublist(1).join('/');
    }

    return Image.asset(
      assetPath,
      package: package,
      width: effectiveImageWidth,
      height: effectiveImageHeight,
      fit: widget.fit,
      alignment: _resolvedAlignment,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = effectiveImageWidth;
    final h = effectiveImageHeight;
    final iconSize = (w != null && h != null) ? math.min(w, h) * 0.45 : 24.0;

    return Container(
      width: w,
      height: h,
      color: widget.color ?? (isDark ? colors.surfaceContainer : colors.surfaceContainerLow),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: iconSize,
        color: colors.onSurfaceVariant.withAlpha(120),
      ),
    );
  }

  /// Custom [AnimatedSwitcher] transition: fade + scale-up for the incoming
  /// widget; keeps outgoing widget visible during cross-fade to prevent background blackout.
  static Widget _revealTransition(Widget child, Animation<double> animation) {
    final isIncoming = animation.status != AnimationStatus.reverse;

    if (isIncoming) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    } else {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: child,
      );
    }
  }

  bool _isHovered = false;
  bool _isTappedVisible = false;

  Widget _buildLoadedImage(Uint8List bytes) {
    return Image.memory(
      key: ValueKey(bytes),
      bytes,
      width: effectiveImageWidth,
      height: effectiveImageHeight,
      fit: widget.fit,
      alignment: _resolvedAlignment,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => KeyedSubtree(
        key: const ValueKey('error_fallback'),
        child: fallbackImage,
      ),
    );
  }

  /// Builds the actual image widget for the default (non-forceCache,
  /// non-bytes) network path.
  ///
  /// Rather than letting `CachedNetworkImage` drive its own internal
  /// placeholder/image crossfade (which re-runs its async cache lookup on
  /// every rebuild — including incidental ones from hover/tap state changes
  /// elsewhere in the tree — causing a shimmer flash even when the image is
  /// already loaded), this precaches the resolved [ImageProvider] into
  /// Flutter's [ImageCache] once per URL and paints from that cache
  /// directly. [RepaintBoundary] isolates this subtree's compositing layer
  /// so parent-driven repaints (e.g. InkWell's hover overlay) never force
  /// the renderer to re-touch the image's texture.
  Widget _buildImage() {
    final effectiveBytes = widget.bytes;
    final imgW = effectiveImageWidth;
    final imgH = effectiveImageHeight;

    if (effectiveBytes != null) {
      return _buildLoadedImage(effectiveBytes);
    }

    if (widget.url == null || widget.url!.isEmpty) {
      return KeyedSubtree(key: const ValueKey('fallback'), child: fallbackImage);
    }

    final provider = _networkProvider;
    if (provider == null) {
      return KeyedSubtree(key: const ValueKey('fallback'), child: fallbackImage);
    }

    return RepaintBoundary(
      child: FutureBuilder<void>(
        future: _precacheFuture,
        builder: (context, snap) {
          Widget child;

          if (snap.connectionState == ConnectionState.done && snap.error == null) {
            child = Image(
              key: const ValueKey('loaded'),
              image: provider,
              width: imgW,
              height: imgH,
              fit: widget.fit,
              alignment: _resolvedAlignment,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => KeyedSubtree(
                key: const ValueKey('error_fallback'),
                child: fallbackImage,
              ),
            );
          } else if (snap.connectionState == ConnectionState.done && snap.error != null) {
            child = KeyedSubtree(
              key: const ValueKey('error_fallback'),
              child: fallbackImage,
            );
          } else {
            child = _ImageShimmer(
              key: const ValueKey('shimmer'),
              width: imgW,
              height: imgH,
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: _revealTransition,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget imageChild;

    if (widget.forceCache && _forceCacheFuture != null) {
      // Synchronous hot path: bytes already decoded this session — render
      // directly, no FutureBuilder or AnimatedSwitcher needed.
      final cachedBytes = widget.url != null ? _forceCacheMemory[widget.url!] : null;
      if (cachedBytes != null) {
        imageChild = _buildLoadedImage(cachedBytes);
      } else {
        final imgW = effectiveImageWidth;
        final imgH = effectiveImageHeight;

        // AnimatedSwitcher lives INSIDE the FutureBuilder so it sees the keyed
        // child swap (shimmer → loaded / shimmer → error_fallback) and fires the reveal animation.
        imageChild = RepaintBoundary(
          child: FutureBuilder<Uint8List?>(
            future: _forceCacheFuture,
            builder: (context, snap) {
              Widget child;
              if (snap.connectionState == ConnectionState.done) {
                if (snap.data != null && snap.data!.isNotEmpty) {
                  child = _buildLoadedImage(snap.data!);
                } else {
                  // Future finished and image was not found / failed to load -> move to placeholder
                  child = KeyedSubtree(
                    key: const ValueKey('error_fallback'),
                    child: fallbackImage,
                  );
                }
              } else {
                // Still loading -> show shimmer animation
                child = _ImageShimmer(
                  key: const ValueKey('shimmer'),
                  width: imgW,
                  height: imgH,
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: _revealTransition,
                child: child,
              );
            },
          ),
        );
      }
    } else {
      imageChild = _buildImage();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final frameColor = widget.color ?? (isDark ? colors.surfaceContainer : colors.surfaceContainerLow);

    final imageFrame = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: frameColor, shape: widget.border),
      child: ClipPath(clipper: ShapeBorderClipper(shape: widget.border), child: imageChild),
    );

    final hasText = !widget.title.isNullOrBlank || !widget.subTitle.isNullOrBlank;
    final bool shouldOverlay = (widget.showTitleSubtitleOverlayOnHover || widget.overlayTitleSubtitle) && hasText;
    final bool isOverlayVisible = widget.overlayTitleSubtitle || _isHovered || _isTappedVisible;

    Widget frameWithOverlay = imageFrame;
    if (shouldOverlay) {
      frameWithOverlay = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Stack(
          children: [
            imageFrame,
            Positioned.fill(
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: widget.border),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isOverlayVisible ? 1.0 : 0.0,
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.3, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.title.isNullOrBlank)
                          Text(
                            widget.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: widget.titleColor ?? Colors.white,
                            ),
                          ),
                        if (!widget.subTitle.isNullOrBlank)
                          Text(
                            widget.subTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: widget.subTitleColor ?? Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final content = (hasText && !shouldOverlay)
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 7.5,
            children: [
              imageFrame,
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    if (!widget.title.isNullOrBlank)
                      Text(
                        widget.title!,
                        overflow: widget.textOverflow,
                        maxLines: widget.maxLines,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: widget.titleColor ?? colors.onSurface),
                      ),
                    if (!widget.subTitle.isNullOrBlank)
                      Text(
                        widget.subTitle!,
                        overflow: widget.textOverflow,
                        maxLines: widget.maxLines,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300, color: widget.subTitleColor ?? colors.onSurfaceVariant),
                      ),
                  ],
                ),
              )
            ],
          )
        : frameWithOverlay;

    final bool canInteract = !widget.disabled && (!widget.url.isNullOrBlank || widget.bytes != null);

    return buildWithDropdownTarget(
      child: InkWell(
        onTap: () {
          if (widget.showTitleSubtitleOverlayOnHover && !widget.overlayTitleSubtitle) {
            setState(() => _isTappedVisible = !_isTappedVisible);
          }
          if (canInteract) {
            showPopup(context);
          }
          widget.onTap?.call();
        },
        customBorder: widget.border,
        hoverColor: colors.primaryContainer,
        splashColor: colors.primary,
        child: content,
      ),
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    ImageProvider imageProvider;
    if (widget.bytes != null) {
      imageProvider = MemoryImage(widget.bytes!);
    } else {
      final cachedBytes = widget.forceCache && widget.url != null ? _forceCacheMemory[widget.url!] : null;
      if (cachedBytes != null) {
        imageProvider = MemoryImage(cachedBytes);
      } else if (!widget.forceCache && _networkProvider != null) {
        // Re-use the exact provider we already precached, so the preview
        // resolves from the same ImageCache entry instead of kicking off a
        // second, independent decode.
        imageProvider = _networkProvider!;
      } else {
        imageProvider = CachedNetworkImageProvider(
          widget.url!,
          cacheKey: widget.cacheKey,
          cacheManager: widget.cacheManager,
        );
      }
    }

    final photoView = ClipPath(
        clipper: ShapeBorderClipper(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
        child: PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        ));

    final previewW = widget.previewSize;
    final previewH = widget.aspectRatio != null ? widget.previewSize / widget.aspectRatio! : widget.previewSize;

    final content = shouldCenteredOverlay ? photoView : SizedBox(width: previewW, height: previewH, child: photoView);

    return content;
  }
}

/// A looping shimmer animation displayed while a [TImage] loads its content.
///
/// Renders a sweeping highlight gradient that travels left→right over the
/// container's surface color, giving the classic "skeleton loading" feel
/// without any third-party package.
class _ImageShimmer extends StatefulWidget {
  final double? width;
  final double? height;

  const _ImageShimmer({super.key, this.width, this.height});

  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final base = isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow;
    final highlight = isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep the highlight band across the full width over one period.
        final t = _controller.value; // 0.0 → 1.0
        final start = Alignment(-1.5 + t * 3.5, 0);
        final end = Alignment(start.x + 1.0, 0);

        return Container(
          width: widget.width ?? 80,
          height: widget.height ?? 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: start,
              end: end,
              colors: [base, highlight, base],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
