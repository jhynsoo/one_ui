import 'package:flutter/material.dart';
import 'dart:math' as math;

class OneUIScrollSimulation extends Simulation {
  OneUIScrollSimulation({
    required this.position,
    required this.velocity,
    required this.expandedHeight,
    this.friction = 0.015,
    Tolerance tolerance = Tolerance.defaultTolerance,
  })  : assert(_flingVelocityPenetration(0.0) == _initialVelocityPenetration),
        super(tolerance: tolerance) {
    _duration = _flingDuration(velocity);
    _distance = (velocity * _duration! / _initialVelocityPenetration).abs();
  }

  /// The position of the particle at the beginning of the simulation.
  final double position;

  /// The velocity at which the particle is traveling at the beginning of the
  /// simulation.
  final double velocity;

  /// The expanded height of [OneUiScrollView].
  final double expandedHeight;

  /// The amount of friction the particle experiences as it travels.
  ///
  /// The more friction the particle experiences, the sooner it stops.
  final double friction;

  double? _duration;
  double? _distance;

  // See DECELERATION_RATE.
  static final double _kDecelerationRate = math.log(0.78) / math.log(0.9);

  // See computeDeceleration().
  static double _decelerationForFriction(double friction) {
    return friction * 61774.04968;
  }

  // See getSplineFlingDuration(). Returns a value in seconds.
  double _flingDuration(double velocity) {
    // See mPhysicalCoeff
    final double scaledFriction = friction * _decelerationForFriction(0.84);

    // See getSplineDeceleration().
    final double deceleration =
        math.log(0.35 * velocity.abs() / scaledFriction);

    return math.exp(deceleration / (_kDecelerationRate - 1.0));
  }

  // Based on a cubic curve fit to the Scroller.computeScrollOffset() values
  // produced for an initial velocity of 4000. The value of Scroller.getDuration()
  // and Scroller.getFinalY() were 686ms and 961 pixels respectively.
  //
  // Algebra courtesy of Wolfram Alpha.
  //
  // f(x) = scrollOffset, x is time in milliseconds
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x - 3.15307
  // f(x) = 3.60882×10^-6 x^3 - 0.00668009 x^2 + 4.29427 x, so f(0) is 0
  // f(686ms) = 961 pixels
  // Scale to f(0 <= t <= 1.0), x = t * 686
  // f(t) = 1165.03 t^3 - 3143.62 t^2 + 2945.87 t
  // Scale f(t) so that 0.0 <= f(t) <= 1.0
  // f(t) = (1165.03 t^3 - 3143.62 t^2 + 2945.87 t) / 961.0
  //      = 1.2 t^3 - 3.27 t^2 + 3.065 t
  static const double _initialVelocityPenetration = 3.065;
  static double _flingDistancePenetration(double t) {
    return (1.2 * t * t * t) -
        (3.27 * t * t) +
        (_initialVelocityPenetration * t);
  }

  // The derivative of the _flingDistancePenetration() function.
  static double _flingVelocityPenetration(double t) {
    return (3.6 * t * t) - (6.54 * t) + _initialVelocityPenetration;
  }

  @override
  double x(double time) {
    final double t = (time / _duration!).clamp(0.0, 1.0);
    return position + _distance! * _flingDistancePenetration(t) * velocity.sign;
  }

  @override
  double dx(double time) {
    final double t = (time / _duration!).clamp(0.0, 1.0);
    return _distance! *
        _flingVelocityPenetration(t) *
        velocity.sign /
        _duration!;
  }

  @override
  bool isDone(double time) {
    // If scroll direction was upward, and didn't reached the top of the scroll
    // when tapped down, scrolling stops at the top except when dragging.
    return (position > expandedHeight && velocity.isNegative) ||
        time >= _duration!;
  }
}
