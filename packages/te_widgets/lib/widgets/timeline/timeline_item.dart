import 'package:flutter/material.dart';
import 'package:te_widgets/te_widgets.dart';

/// Represents an entry/node in a [TTimeline].
class TTimelineItem {
  /// The title widget for this timeline item.
  final Widget? title;

  /// Optional plain text title shorthand.
  final String? titleText;

  /// The subtitle widget for this timeline item.
  final Widget? subtitle;

  /// Optional plain text subtitle shorthand.
  final String? subtitleText;

  /// The description widget for this timeline item.
  final Widget? description;

  /// Optional plain text description shorthand.
  final String? descriptionText;

  /// Trailing metadata or timestamp widget (e.g., date, time, status badge).
  final Widget? trailing;

  /// Optional plain text trailing timestamp shorthand.
  final String? timeText;

  /// Icon displayed inside the indicator circle.
  final Widget? icon;

  /// Shorthand [IconData] for the indicator icon.
  final IconData? iconData;

  /// Size of the icon.
  final double? iconSize;

  /// Color of the icon.
  final Color? iconColor;

  /// Custom color for the indicator, ring, and active text.
  final Color? color;

  /// Custom color override for the outer ring.
  final Color? ringColor;

  /// Custom color override for the inner circle fill.
  final Color? innerColor;

  /// Custom color for the connecting line following this item.
  final Color? lineColor;

  /// Custom line style for the connecting line following this item (dashed, solid, dotted, none).
  final TTimelineLineStyle? lineStyle;

  /// Custom indicator widget overriding the default ring indicator.
  final Widget? indicator;

  /// Visual variant of the indicator (solid, tonal, outline, softOutline, etc.).
  final TVariant? variant;

  /// Extra custom content displayed below the description (e.g., cards, action buttons, image previews).
  final Widget? content;

  /// Whether this timeline step is currently active / in-progress.
  final bool isActive;

  /// Whether this timeline step is completed.
  final bool isCompleted;

  /// Callback when this timeline item or its indicator is tapped.
  final VoidCallback? onTap;

  const TTimelineItem({
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.description,
    this.descriptionText,
    this.trailing,
    this.timeText,
    this.icon,
    this.iconData,
    this.iconSize,
    this.iconColor,
    this.color,
    this.ringColor,
    this.innerColor,
    this.lineColor,
    this.lineStyle,
    this.indicator,
    this.variant,
    this.content,
    this.isActive = false,
    this.isCompleted = false,
    this.onTap,
  });

  /// Factory constructor for a plain text-driven timeline item.
  factory TTimelineItem.text({
    required String title,
    String? subtitle,
    String? description,
    String? time,
    IconData? icon,
    Color? color,
    Color? ringColor,
    Color? innerColor,
    TTimelineLineStyle? lineStyle,
    TVariant? variant,
    Widget? content,
    bool isActive = false,
    bool isCompleted = false,
    VoidCallback? onTap,
  }) {
    return TTimelineItem(
      titleText: title,
      subtitleText: subtitle,
      descriptionText: description,
      timeText: time,
      iconData: icon,
      color: color,
      ringColor: ringColor,
      innerColor: innerColor,
      lineStyle: lineStyle,
      variant: variant,
      content: content,
      isActive: isActive,
      isCompleted: isCompleted,
      onTap: onTap,
    );
  }
}

