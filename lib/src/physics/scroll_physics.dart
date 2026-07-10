import 'package:flutter/widgets.dart';
import 'package:one_ui/src/physics/scroll_simulation.dart';

class OneUIScrollPhysics extends ScrollPhysics {
  const OneUIScrollPhysics(this.expandedHeight, {super.parent});

  final double expandedHeight;

  @override
  ScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OneUIScrollPhysics(expandedHeight, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final Tolerance tolerance = toleranceFor(position);
    if ((velocity.abs() < tolerance.velocity) ||
        (velocity > 0.0 && position.pixels >= position.maxScrollExtent) ||
        (velocity < 0.0 && position.pixels <= position.minScrollExtent)) {
      return null;
    }
    return OneUIScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      expandedHeight: expandedHeight,
    );
  }
}
