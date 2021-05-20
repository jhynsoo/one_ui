import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kUnconfirmedSplashDuration = kThemeAnimationDuration;
const Duration _kSplashFadeDuration = kRadialReactionDuration;

const double _kSplashConfirmedVelocity = 1.0; // logical pixels per millisecond

RectCallback? _getClipCallback(
    RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) return () => Offset.zero & referenceBox.size;
  return null;
}

Size _getTargetSize(RenderBox referenceBox, RectCallback? rectCallback) {
  return rectCallback != null ? rectCallback().size : referenceBox.size;
}

class _OneUIBottomNavigationBarSplashFactory
    extends InteractiveInkFeatureFactory {
  const _OneUIBottomNavigationBarSplashFactory();

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
    return OneUIBottomNavigationBarSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

class OneUIBottomNavigationBarSplash extends InteractiveInkFeature {
  OneUIBottomNavigationBarSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required TextDirection textDirection,
    Offset? position,
    required Color color,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  })  : _borderRadius = BorderRadius.circular(18.0),
        _customBorder = customBorder,
        _targetSize = _getTargetSize(referenceBox, rectCallback),
        _clipCallback =
            _getClipCallback(referenceBox, containedInkWell, rectCallback),
        _textDirection = textDirection,
        super(
            controller: controller,
            referenceBox: referenceBox,
            color: color,
            onRemoved: onRemoved) {
    _scaleController = AnimationController(
        duration: _kUnconfirmedSplashDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _scale = _scaleController.drive(Tween<double>(begin: .8, end: 1.0));
    _alphaController = AnimationController(
        duration: _kSplashFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _alpha = _alphaController.drive(IntTween(
      // begin: color.alpha,
      // end: 0,
      begin: 0,
      end: color.alpha,
    ));

    controller.addInkFeature(this);
  }

  final BorderRadius _borderRadius;
  final ShapeBorder? _customBorder;
  final Size _targetSize;
  final RectCallback? _clipCallback;
  final TextDirection _textDirection;
  late Animation<double> _scale;
  late AnimationController _scaleController;
  late Animation<int> _alpha;
  late AnimationController _alphaController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse],
  /// material [Theme], or [ButtonStyle].
  static const InteractiveInkFeatureFactory splashFactory =
      _OneUIBottomNavigationBarSplashFactory();

  @override
  void confirm() {
    final int duration = (math.max(_targetSize.width, _targetSize.height) /
            _kSplashConfirmedVelocity)
        .floor();
    _scaleController
      ..duration = Duration(milliseconds: duration)
      ..forward();
    _alphaController.reverse();
  }

  @override
  void cancel() {
    _alphaController.reverse();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _alphaController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = color.withAlpha(_alpha.value);
    Offset center = referenceBox.size.center(Offset.zero);

    paintInkRRect(
      canvas: canvas,
      transform: transform,
      paint: paint,
      center: center,
      scale: _scale.value,
      textDirection: _textDirection,
      size: _targetSize,
      customBorder: _customBorder,
      borderRadius: _borderRadius,
      clipCallback: _clipCallback,
    );
  }
}

void paintInkRRect({
  required Canvas canvas,
  required Matrix4 transform,
  required Paint paint,
  required Offset center,
  required Size size,
  required double scale,
  TextDirection? textDirection,
  ShapeBorder? customBorder,
  BorderRadius borderRadius = BorderRadius.zero,
  RectCallback? clipCallback,
}) {
  final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
  canvas.save();
  if (originOffset == null) {
    canvas.transform(transform.storage);
  } else {
    canvas.translate(originOffset.dx, originOffset.dy);
  }

  if (clipCallback != null) {
    final Rect rect = clipCallback();
    if (customBorder != null) {
      canvas.clipPath(
          customBorder.getOuterPath(rect, textDirection: textDirection));
    } else if (borderRadius != BorderRadius.zero) {
      canvas.clipRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ));
    } else {
      canvas.clipRect(rect);
    }
  }

  final Rect inkRect = Rect.fromCenter(
      center: center, width: size.width * scale, height: size.height * scale);
  final RRect inkRRect =
      RRect.fromRectAndRadius(inkRect, const Radius.circular(18.0));
  canvas.drawRRect(inkRRect, paint);
  canvas.restore();
}
