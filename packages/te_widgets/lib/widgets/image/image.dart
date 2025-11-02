import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:te_widgets/te_widgets.dart';

class TImage extends StatefulWidget with TPopupMixin {
  final String? url;

  final double size;
  final double previewSize;
  final String placeholder;
  final Color? backgroundColor;
  final double padding;
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
    this.placeholder = 'package:te_widgets/assets/icons/no_image.png',
    this.backgroundColor,
    this.padding = 0,
    this.disabled = false,
    this.onShow,
    this.onHide,
  });

  @override
  State<TImage> createState() => _TImageState();

  @override
  TPopupAlignment get alignment => TPopupAlignment.rightTop;
}

class _TImageState extends State<TImage> with TPopupStateMixin<TImage> {
  @override
  double get contentMaxWidth => widget.previewSize + 25;
  @override
  double get contentMaxHeight => widget.previewSize + 25;
  @override
  bool get shouldCenteredOverlay => true;

  @override
  Widget build(BuildContext context) {
    final isPackageAsset = widget.placeholder.startsWith('package:');
    String assetPath = widget.placeholder;
    String? package;
    if (isPackageAsset) {
      final parts = widget.placeholder.substring(8).split('/');
      package = parts.first;
      assetPath = parts.sublist(1).join('/');
    }

    return buildWithDropdownTarget(
      child: InkWell(
        onTap: widget.disabled ? null : () => showPopup(context),
        child: Container(
          width: widget.size + widget.padding,
          height: widget.size + widget.padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: widget.backgroundColor, borderRadius: BorderRadius.circular(12.0)),
          child: widget.url == null || widget.url!.isEmpty
              ? Image.asset(assetPath, package: package, width: widget.size, height: widget.size, fit: BoxFit.contain)
              : Image.network(
                  widget.url!,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(assetPath, package: package, width: widget.size, height: widget.size, fit: BoxFit.contain);
                  },
                ),
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
    return shouldCenteredOverlay ? content : SizedBox(width: widget.previewSize, height: widget.previewSize, child: content);
  }
}
