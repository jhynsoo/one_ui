import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/src/physics/scroll_physics.dart';
import 'package:one_ui/src/physics/scroll_simulation.dart';

void main() {
  group('OneUIScrollSimulation', () {
    test('moves and reports velocity in the fling direction', () {
      final OneUIScrollSimulation forward = OneUIScrollSimulation(
        position: 100,
        velocity: 2000,
        expandedHeight: 300,
      );
      final OneUIScrollSimulation reverse = OneUIScrollSimulation(
        position: 100,
        velocity: -2000,
        expandedHeight: 300,
      );

      expect(forward.x(0), 100);
      expect(forward.dx(0), 2000);
      expect(forward.x(0.001), greaterThan(100));
      expect(forward.dx(0.001), greaterThan(0));

      expect(reverse.x(0), 100);
      expect(reverse.dx(0), -2000);
      expect(reverse.x(0.001), lessThan(100));
      expect(reverse.dx(0.001), lessThan(0));
    });

    test('finishes after its spline duration', () {
      final OneUIScrollSimulation simulation = OneUIScrollSimulation(
        position: 100,
        velocity: 2000,
        expandedHeight: 300,
      );

      expect(simulation.isDone(0), isFalse);
      expect(simulation.isDone(60), isTrue);
      expect(simulation.x(60).isFinite, isTrue);
      expect(simulation.dx(60), 0);
    });

    test('stops an upward fling that begins below the expanded app bar', () {
      final OneUIScrollSimulation simulation = OneUIScrollSimulation(
        position: 301,
        velocity: -1000,
        expandedHeight: 300,
      );

      expect(simulation.isDone(0), isTrue);
    });
  });

  group('OneUIScrollPhysics', () {
    const OneUIScrollPhysics physics = OneUIScrollPhysics(300);

    test('preserves its expanded height when applied to an ancestor', () {
      final OneUIScrollPhysics applied =
          physics.applyTo(const BouncingScrollPhysics()) as OneUIScrollPhysics;

      expect(applied.expandedHeight, 300);
      expect(applied.parent, isA<BouncingScrollPhysics>());
    });

    test('does not create simulations for slow or out-of-range flings', () {
      final FixedScrollMetrics middle = _metrics(pixels: 500);
      final double slowVelocity = physics.toleranceFor(middle).velocity / 2;

      expect(physics.createBallisticSimulation(middle, slowVelocity), isNull);
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 1000), 1000),
        isNull,
      );
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 0), -1000),
        isNull,
      );
    });

    test('creates simulations for valid flings in both directions', () {
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 500), 1000),
        isA<OneUIScrollSimulation>(),
      );
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 200), -1000),
        isA<OneUIScrollSimulation>(),
      );
    });

    test('created simulation honors the expanded-height stop contract', () {
      final Simulation simulation = physics.createBallisticSimulation(
        _metrics(pixels: 400),
        -1000,
      )!;

      expect(simulation, isA<OneUIScrollSimulation>());
      expect(simulation.isDone(0), isTrue);
    });
  });
}

FixedScrollMetrics _metrics({required double pixels}) {
  return FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 1000,
    pixels: pixels,
    viewportDimension: 600,
    axisDirection: AxisDirection.down,
    devicePixelRatio: 1,
  );
}
