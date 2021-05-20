import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kUnconfirmedRippleDuration = Duration(milliseconds: 225);
const Duration _kFadeInDuration = Duration(milliseconds: 100);
const Duration _kRadiusDuration = Duration(milliseconds: 225);
const Duration _kFadeOutDuration = Duration(milliseconds: 200);
const Duration _kCancelDuration = Duration(milliseconds: 100);

RectCallback? _getClipCallback(
    RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) return () => Offset.zero & referenceBox.size;
  return null;
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell,
    RectCallback? rectCallback, Offset position) {
  final Size size =
      rectCallback != null ? rectCallback().size : referenceBox.size;
  final double d1 = size.bottomRight(Offset.zero).distance;
  final double d2 =
      (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
  return math.max(d1, d2) / 2.0;
}

class _OneUIInkRippleFactory extends InteractiveInkFeatureFactory {
  const _OneUIInkRippleFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return OneUIInkRipple(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

class OneUIInkRipple extends InteractiveInkFeature {
  OneUIInkRipple({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  })  : _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _textDirection = textDirection,
        _targetRadius = radius ??
            _getTargetRadius(
                referenceBox, containedInkWell, rectCallback, position),
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback),
        super(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved) {
    // Immediately begin fading-in the initial splash.
    _fadeInController =
        AnimationController(duration: _kFadeInDuration, vsync: controller.vsync)
          ..addListener(controller.markNeedsPaint)
          ..forward();
    _fadeIn = _fadeInController.drive(IntTween(
      begin: 0,
      end: color.alpha,
    ));

    // Controls the splash radius and its center. Starts upon confirm.
    _radiusController = AnimationController(
        duration: _kUnconfirmedRippleDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    // Initial splash diameter is 60% of the target diameter, final
    // diameter is 10dps larger than the target diameter.
    _radius = _radiusController.drive(
      Tween<double>(
        begin: _targetRadius * 0.30,
        end: _targetRadius + 5.0,
      ).chain(_easeCurveTween),
    );

    // Controls the splash radius and its center. Starts upon confirm however its
    // Interval delays changes until the radius expansion has completed.
    _fadeOutController = AnimationController(
        duration: _kFadeOutDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _fadeOut = _fadeOutController.drive(
      IntTween(
        begin: color.alpha,
        end: 0,
      ).chain(_fadeOutIntervalTween),
    );

    controller.addInkFeature(this);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final ShapeBorder? _customBorder;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final TextDirection _textDirection;

  late Animation<double> _radius;
  late AnimationController _radiusController;

  late Animation<int> _fadeIn;
  late AnimationController _fadeInController;

  late Animation<int> _fadeOut;
  late AnimationController _fadeOutController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse],
  /// material [Theme], or [ButtonStyle].
  static const InteractiveInkFeatureFactory splashFactory =
      _OneUIInkRippleFactory();

  static final Animatable<double> _easeCurveTween =
      CurveTween(curve: Curves.ease);
  static final Animatable<double> _fadeOutIntervalTween =
      CurveTween(curve: const Interval(0.0, 1.0));

  @override
  void confirm() {
    _radiusController
      ..duration = _kRadiusDuration
      ..forward();
    // This confirm may have been preceded by a cancel.
    _fadeInController.forward();
    _fadeOutController.animateTo(1.0, duration: _kFadeOutDuration);
  }

  @override
  void cancel() {
    _fadeInController.stop();
    // Watch out: setting _fadeOutController's value to 1.0 will
    // trigger a call to _handleAlphaStatusChanged() which will
    // dispose _fadeOutController.
    final double fadeOutValue = 1.0 - _fadeInController.value;
    _fadeOutController.value = fadeOutValue;
    if (fadeOutValue < 1.0)
      _fadeOutController.animateTo(1.0, duration: _kCancelDuration);
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) dispose();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final int alpha =
        _fadeInController.isAnimating ? _fadeIn.value : _fadeOut.value;
    final Paint paint = Paint()..color = color.withAlpha(alpha);
    // Splash moves to the center of the reference box.
    final Offset center = Offset.lerp(
      _position,
      referenceBox.size.center(Offset.zero),
      Curves.ease.transform(_radiusController.value),
    )!;
    paintInkCircle(
      canvas: canvas,
      transform: transform,
      paint: paint,
      center: center,
      textDirection: _textDirection,
      radius: _radius.value,
      customBorder: _customBorder,
      borderRadius: _borderRadius,
      clipCallback: _clipCallback,
    );
  }
}
