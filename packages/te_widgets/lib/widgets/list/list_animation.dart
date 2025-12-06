import 'package:flutter/material.dart';

/// Builder for list item animations.
typedef TListAnimationBuilder = Widget Function(BuildContext context, Animation<double> animation, Widget child, int index);

/// Collection of predefined list item animations.
///
/// `TListAnimationBuilders` provides standard entrance animations for lists:
/// - slides (left, right, up, down)
/// - fade
/// - bounce
/// - elastic
/// - staggered
///
/// ## Usage
///
/// ```dart
/// TList(
///   animationBuilder: TListAnimationBuilders.slideInLeft,
///   // ...
/// )
/// ```
class TListAnimationBuilders {
  const TListAnimationBuilders._();

  /// Slides items in from the left.
  static const TListAnimationBuilder slideInLeft = _slideInLeft;
  static Widget _slideInLeft(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * 50, 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Slides items in from the right.
  static const TListAnimationBuilder slideInRight = _slideInRight;
  static Widget _slideInRight(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - animation.value) * -50, 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Slides items in from the bottom.
  static const TListAnimationBuilder slideInUp = _slideInUp;
  static Widget _slideInUp(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * 30),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Slides items in from the top.
  static const TListAnimationBuilder slideInDown = _slideInDown;
  static Widget _slideInDown(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * -30),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Fades items in.
  static const TListAnimationBuilder fadeIn = _fadeIn;
  static Widget _fadeIn(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(opacity: animation.value, child: child);
      },
    );
  }

  /// Bounces items in.
  static const TListAnimationBuilder bounceIn = _bounceIn;
  static Widget _bounceIn(BuildContext context, Animation<double> animation, Widget child, int index) {
    final bounceAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    );
    return AnimatedBuilder(
      animation: bounceAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: bounceAnimation.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Slides items in with elastic effect.
  static const TListAnimationBuilder elasticSlide = _elasticSlide;
  static Widget _elasticSlide(BuildContext context, Animation<double> animation, Widget child, int index) {
    final slideAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.elasticOut,
    );
    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - slideAnimation.value) * 80, 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Alternates slide direction based on index (odd/even).
  static const TListAnimationBuilder alternatingSlide = _alternatingSlide;
  static Widget _alternatingSlide(BuildContext context, Animation<double> animation, Widget child, int index) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final slideDirection = index % 2 == 0 ? 50.0 : -50.0;
        return Transform.translate(
          offset: Offset((1 - animation.value) * slideDirection, 0),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  /// Staggers animation based on index.
  static const TListAnimationBuilder staggered = _staggered;
  static Widget _staggered(BuildContext context, Animation<double> animation, Widget child, int index) {
    final delayedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        (0.1 * index).clamp(0.0, 0.8),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset((1 - delayedAnimation.value) * 50, 0),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  /// No animation.
  static const TListAnimationBuilder none = _none;
  static Widget _none(BuildContext context, Animation<double> animation, Widget child, int index) {
    return child;
  }
}
