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
/// - Click to preview with zoom (using PhotoView)
/// - Custom shapes (rounded, circle)
/// - Title and subtitle support
/// - Aspect ratio control
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
/// ## Force-cached Image (IndexedDB / app documents dir)
///
/// ```dart
/// TImage(
///   url: 'https://example.com/image.jpg',
///   size: 100,
///   forceCache: true,   // stores in IndexedDB (web) or documents dir (mobile)
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
  /// Defaults to 80.
  final double size;

  /// The size of the preview when clicked.
  ///
  /// Defaults to 350.
  final double previewSize;

  /// The aspect ratio of the image.
  ///
  /// Defaults to 1 (square).
  final double aspectRatio;

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
  /// Allows you to provide a custom [BaseCacheManager] implementation
  /// for fine-grained control over caching behavior.
  final BaseCacheManager? cacheManager;

  final TextOverflow? textOverflow;
  final int? maxLines;

  /// When `true`, the image is downloaded once and stored persistently in
  /// **IndexedDB** (web) or the **app documents directory** (Android/iOS/desktop)
  /// via [TImageStorage].
  ///
  /// This provides more stable long-term storage than the OS HTTP cache or
  /// `flutter_cache_manager`, which can be evicted at any time by the browser
  /// or OS.  Subsequent loads skip the network entirely and read from the
  /// local store.
  ///
  /// When `false` (the default) the existing [CachedNetworkImage] behaviour
  /// is used unchanged.
  final bool forceCache;

  /// Creates an image widget.
  const TImage({
    super.key,
    this.url,
    this.size = 80,
    this.previewSize = 350,
    this.aspectRatio = 1,
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
  });

  /// Creates a circular image widget.
  const TImage.circle({
    super.key,
    this.url,
    this.size = 80,
    this.previewSize = 350,
    this.aspectRatio = 1,
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
  });

  /// Creates a profile image with default styling.
  ///
  /// Uses a circular shape with a profile placeholder.
  static TImage profile({
    String? url,
    String? name,
    String? role,
    double size = 42,
    double padding = 5,
    bool forceCache = false,
  }) {
    return TImage.circle(
      url: url,
      placeholder: 'package:te_widgets/assets/icons/profile.png',
      title: name,
      subTitle: role,
      size: size,
      padding: padding,
      disabled: true,
      forceCache: forceCache,
    );
  }

  @override
  State<TImage> createState() => _TImageState();

  @override
  TPopupAlignment get alignment => TPopupAlignment.rightTop;
}

// ---------------------------------------------------------------------------
// In-memory map: url → resolved bytes (avoids re-downloading on rebuild).
// Lives for the app lifetime, which is fine — these are thumbnail/image bytes.
// ---------------------------------------------------------------------------
final Map<String, Uint8List> _forceCacheMemory = {};

class _TImageState extends State<TImage> with TPopupStateMixin<TImage> {
  @override
  double get contentMinWidth => (widget.previewSize / widget.aspectRatio);
  @override
  double get contentMinHeight => (widget.previewSize / widget.aspectRatio);

  /// Future that resolves image bytes when [TImage.forceCache] is true.
  /// Kept as a field so rebuilds re-use the same Future (no re-download).
  Future<Uint8List?>? _forceCacheFuture;

  @override
  void initState() {
    super.initState();
    _initForceCacheFuture();
  }

  @override
  void didUpdateWidget(TImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url || old.forceCache != widget.forceCache) {
      _initForceCacheFuture();
    }
  }

  void _initForceCacheFuture() {
    if (widget.forceCache && widget.url != null && widget.url!.isNotEmpty) {
      _forceCacheFuture = _resolveBytes(widget.url!);
    } else {
      _forceCacheFuture = null;
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
      width: widget.size - widget.padding,
      height: (widget.size - widget.padding) / widget.aspectRatio,
      fit: widget.fit,
    );
  }

  /// Custom [AnimatedSwitcher] transition: fade + scale-up for the incoming
  /// widget; fade-only for the outgoing widget (prevents double-scale).
  static Widget _revealTransition(Widget child, Animation<double> animation) {
    // `animation` runs 0→1 for incoming, 1→0 for outgoing.
    // We only scale-up the incoming child by checking the key.
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  /// Builds the actual image widget.
  ///
  /// When [forceCache] is true and [bytes] are available, uses [Image.memory].
  /// While [forceCache] is true but bytes are still loading (null), shows the
  /// shimmer placeholder — never [CachedNetworkImage] — so no network request
  /// is fired while waiting for the persistent store to respond.
  Widget _buildImage({Uint8List? bytes}) {
    if (widget.url == null || widget.url!.isEmpty) {
      return fallbackImage;
    }

    if (bytes != null) {
      return Image.memory(
        key: const ValueKey('loaded'),
        bytes,
        width: widget.size - widget.padding,
        height: (widget.size - widget.padding) / widget.aspectRatio,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => fallbackImage,
      );
    }

    // forceCache=true but bytes haven't resolved yet — shimmer while we wait.
    if (widget.forceCache) {
      return _ImageShimmer(
        key: const ValueKey('shimmer'),
        width: widget.size - widget.padding,
        height: (widget.size - widget.padding) / widget.aspectRatio,
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.url!,
      cacheKey: widget.cacheKey,
      cacheManager: widget.cacheManager,
      width: widget.size - widget.padding,
      height: (widget.size - widget.padding) / widget.aspectRatio,
      fit: widget.fit,
      fadeInDuration: const Duration(milliseconds: 400),
      fadeOutDuration: const Duration(milliseconds: 200),
      placeholder: (context, url) => _ImageShimmer(
        width: widget.size - widget.padding,
        height: (widget.size - widget.padding) / widget.aspectRatio,
      ),
      errorWidget: (context, error, stackTrace) => fallbackImage,
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
        imageChild = _buildImage(bytes: cachedBytes);
      } else {
        // AnimatedSwitcher lives INSIDE the FutureBuilder so it sees the keyed
        // child swap (shimmer → loaded) and fires the reveal animation.
        imageChild = FutureBuilder<Uint8List?>(
          future: _forceCacheFuture,
          builder: (context, snap) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: _revealTransition,
              child: _buildImage(bytes: snap.data),
            );
          },
        );
      }
    } else {
      imageChild = _buildImage();
    }

    final imageFrame = Container(
      width: widget.size,
      height: widget.size / widget.aspectRatio,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: widget.color ?? colors.surfaceContainerLow, shape: widget.border),
      child: ClipPath(clipper: ShapeBorderClipper(shape: widget.border), child: imageChild),
    );

    return buildWithDropdownTarget(
      child: InkWell(
        onTap: widget.disabled || widget.url.isNullOrBlank ? null : () => showPopup(context),
        customBorder: widget.border,
        hoverColor: colors.primaryContainer,
        splashColor: colors.primary,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 7.5,
          children: [
            imageFrame,
            if (!widget.title.isNullOrBlank || !widget.subTitle.isNullOrBlank)
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: widget.titleColor ?? colors.onSurface),
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
        ),
      ),
    );
  }

  @override
  Widget getContentWidget(BuildContext context) {
    // For the zoom preview, use Image.memory bytes if already cached in memory.
    final cachedBytes = widget.forceCache && widget.url != null ? _forceCacheMemory[widget.url!] : null;

    ImageProvider imageProvider;
    if (cachedBytes != null) {
      imageProvider = MemoryImage(cachedBytes);
    } else {
      imageProvider = CachedNetworkImageProvider(
        widget.url!,
        cacheKey: widget.cacheKey,
        cacheManager: widget.cacheManager,
      );
    }

    final photoView = ClipPath(
        clipper: ShapeBorderClipper(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
        child: PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        ));

    final content = shouldCenteredOverlay
        ? photoView
        : SizedBox(width: widget.previewSize, height: widget.previewSize / widget.aspectRatio, child: photoView);

    return content;
  }
}

/// A looping shimmer animation displayed while a [TImage] loads its content.
///
/// Renders a sweeping highlight gradient that travels left→right over the
/// container's surface color, giving the classic "skeleton loading" feel
/// without any third-party package.
class _ImageShimmer extends StatefulWidget {
  final double width;
  final double height;

  const _ImageShimmer({super.key, required this.width, required this.height});

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
    final base = scheme.surfaceContainerLow;
    final highlight = scheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Sweep the highlight band across the full width over one period.
        final t = _controller.value; // 0.0 → 1.0
        final start = Alignment(-1.5 + t * 3.5, 0);
        final end = Alignment(start.x + 1.0, 0);

        return Container(
          width: widget.width,
          height: widget.height,
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
