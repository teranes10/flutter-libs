import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:te_widgets/te_widgets.dart';

class TImage extends StatefulWidget with TPopupMixin {
  final String? url;
  final double size;
  final double previewSize;
  final double aspectRatio;
  final String placeholder;
  final ShapeBorder border;
  final double padding;
  final BoxFit fit;
  final Color? color;

  final String? title;
  final String? subTitle;
  final Color? titleColor;
  final Color? subTitleColor;

  @override
  final bool disabled;
  @override
  final VoidCallback? onShow;
  @override
  final VoidCallback? onHide;

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
  });

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
  });

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPackageAsset = widget.placeholder.startsWith('package:');

    String assetPath = widget.placeholder;
    String? package;
    if (isPackageAsset) {
      final parts = widget.placeholder.substring(8).split('/');
      package = parts.first;
      assetPath = parts.sublist(1).join('/');
    }

    final fallbackImage = Image.asset(
      assetPath,
      package: package,
      width: widget.size - widget.padding,
      height: (widget.size - widget.padding) / widget.aspectRatio,
      fit: widget.fit,
    );

    final image = widget.url == null || widget.url!.isEmpty
        ? fallbackImage
        : Image.network(
            widget.url!,
            width: widget.size - widget.padding,
            height: (widget.size - widget.padding) / widget.aspectRatio,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => fallbackImage,
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
      imageProvider: NetworkImage(widget.url!),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
    );
    return shouldCenteredOverlay
        ? content
        : SizedBox(width: widget.previewSize, height: widget.previewSize / widget.aspectRatio, child: content);
  }
}
