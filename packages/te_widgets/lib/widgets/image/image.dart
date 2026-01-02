import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
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
  });

  /// Creates a profile image with default styling.
  ///
  /// Uses a circular shape with a profile placeholder.
  static TImage profile({String? url, String? name, String? role, double size = 42, double padding = 5}) {
    return TImage.circle(
      url: url,
      placeholder: 'package:te_widgets/assets/icons/profile.png',
      title: name,
      subTitle: role,
      size: size,
      padding: padding,
      disabled: true,
    );
  }

  @override
  State<TImage> createState() => _TImageState();

  @override
  TPopupAlignment get alignment => TPopupAlignment.rightTop;
}

class _TImageState extends State<TImage> with TPopupStateMixin<TImage> {
  @override
  double get contentMaxWidth => widget.previewSize + 25;
  @override
  double get contentMaxHeight => (widget.previewSize + 25) / widget.aspectRatio;
  @override
  bool get shouldCenteredOverlay => true;

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final image = widget.url == null || widget.url!.isEmpty
        ? fallbackImage
        : CachedNetworkImage(
            imageUrl: widget.url!,
            cacheKey: widget.cacheKey,
            cacheManager: widget.cacheManager,
            width: widget.size - widget.padding,
            height: (widget.size - widget.padding) / widget.aspectRatio,
            fit: widget.fit,
            placeholder: (context, url) => fallbackImage,
            errorWidget: (context, error, stackTrace) => fallbackImage,
          );

    final imageFrame = Container(
      width: widget.size,
      height: widget.size / widget.aspectRatio,
      alignment: Alignment.center,
      decoration: ShapeDecoration(color: widget.color ?? colors.surfaceContainerLowest, shape: widget.border),
      child: ClipPath(clipper: ShapeBorderClipper(shape: widget.border), child: image),
    );

    return buildWithDropdownTarget(
      child: InkWell(
        onTap: widget.disabled || widget.url.isNullOrBlank ? null : () => showPopup(context),
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: widget.titleColor ?? colors.onSurface),
                      ),
                    if (!widget.subTitle.isNullOrBlank)
                      Text(
                        widget.subTitle!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
    final content = PhotoView(
      imageProvider: CachedNetworkImageProvider(
        widget.url!,
        cacheKey: widget.cacheKey,
        cacheManager: widget.cacheManager,
      ),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
    );
    return shouldCenteredOverlay
        ? content
        : SizedBox(width: widget.previewSize, height: widget.previewSize / widget.aspectRatio, child: content);
  }
}
