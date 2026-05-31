import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// An avatar widget that displays an image, initials, or a fallback icon.
///
/// `TAvatar` provides a flexible way to represent users or entities with:
/// - Support for image URLs
/// - Automatic initials generation from names
/// - Custom shapes (circle, rounded rectangle)
/// - Standardized sizes
/// - Background colors for initials
/// - Optional badge support
///
/// ## Basic Usage
///
/// ```dart
/// TAvatar(
///   url: 'https://example.com/avatar.jpg',
///   name: 'John Doe',
///   size: TInputSize.md,
/// )
/// ```
///
/// ## With Initials
///
/// ```dart
/// TAvatar(
///   name: 'Jane Smith',
///   backgroundColor: Colors.blue,
/// )
/// ```
class TAvatar extends StatelessWidget {
  /// The URL of the avatar image.
  final String? url;

  /// The name used to generate initials if [url] is null or fails to load.
  final String? name;

  /// The size of the avatar.
  ///
  /// Defaults to [TInputSize.md].
  final TInputSize size;

  /// The shape of the avatar.
  ///
  /// Defaults to [BoxShape.circle].
  final BoxShape shape;

  /// The border radius for [BoxShape.rectangle].
  final BorderRadius? borderRadius;

  /// The background color when displaying initials or the fallback icon.
  final Color? backgroundColor;

  /// The color of the initials text or fallback icon.
  final Color? foregroundColor;

  /// Optional title text displayed next to the avatar.
  final String? title;

  /// Optional subtitle text displayed below the title.
  final String? subTitle;

  /// Custom color for the title text.
  final Color? titleColor;

  /// Custom color for the subtitle text.
  final Color? subTitleColor;

  /// Spacing between the avatar and the text.
  final double spacing;

  /// Creates an avatar.
  const TAvatar({
    super.key,
    this.url,
    this.name,
    this.size = TInputSize.md,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.title,
    this.subTitle,
    this.titleColor,
    this.subTitleColor,
    this.spacing = 8,
  });

  /// Creates a square (rounded) avatar.
  const TAvatar.square({
    super.key,
    this.url,
    this.name,
    this.size = TInputSize.md,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor,
    this.foregroundColor,
    this.title,
    this.subTitle,
    this.titleColor,
    this.subTitleColor,
    this.spacing = 8,
  }) : shape = BoxShape.rectangle;

  double _getAvatarSize() {
    switch (size) {
      case TInputSize.xs:
        return 24;
      case TInputSize.sm:
        return 32;
      case TInputSize.md:
        return 40;
      case TInputSize.lg:
        return 56;
    }
  }

  double _getFontSize() {
    switch (size) {
      case TInputSize.xs:
        return 10;
      case TInputSize.sm:
        return 12;
      case TInputSize.md:
        return 16;
      case TInputSize.lg:
        return 20;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final double avatarSize = _getAvatarSize();
    final Color effectiveBackgroundColor = backgroundColor ?? colors.primaryContainer;
    final Color effectiveForegroundColor = foregroundColor ?? colors.onPrimaryContainer;

    Widget content;

    if (url != null && url!.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        width: avatarSize,
        height: avatarSize,
        placeholder: (context, url) => _buildFallback(effectiveBackgroundColor, effectiveForegroundColor),
        errorWidget: (context, url, error) => _buildFallback(effectiveBackgroundColor, effectiveForegroundColor),
      );
    } else {
      content = _buildFallback(effectiveBackgroundColor, effectiveForegroundColor);
    }

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : borderRadius,
        color: effectiveBackgroundColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: content),
    );

    if (title.isNullOrBlank && subTitle.isNullOrBlank) {
      return avatar;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar,
        SizedBox(width: spacing),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!title.isNullOrBlank)
                Text(
                  title!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _getFontSize(),
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? colors.onSurface,
                  ),
                ),
              if (!subTitle.isNullOrBlank)
                Text(
                  subTitle!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: _getFontSize() * 0.8,
                    fontWeight: FontWeight.w300,
                    color: subTitleColor ?? colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(Color bgColor, Color fgColor) {
    if (name != null && name!.isNotEmpty) {
      return Text(
        _getInitials(name!),
        style: TextStyle(
          color: fgColor,
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Icon(
      Icons.person,
      color: fgColor,
      size: _getAvatarSize() * 0.6,
    );
  }
}
