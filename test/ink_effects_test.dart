import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

import 'test_app.dart';

void main() {
  final Map<String, InteractiveInkFeatureFactory> factories =
      <String, InteractiveInkFeatureFactory>{
        'ripple': one_ui.OneUIInkRipple.splashFactory,
        'splash': one_ui.OneUIInkSplash.splashFactory,
      };

  for (final MapEntry<String, InteractiveInkFeatureFactory> entry
      in factories.entries) {
    testWidgets('${entry.key} confirms and disposes after a completed tap', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      final _InkLifecycle lifecycle = _InkLifecycle();
      await tester.pumpWidget(
        TestApp(
          home: _InkHarness(
            factory: _TrackingInkFactory(entry.value, lifecycle),
            onTap: () => taps += 1,
          ),
        ),
      );

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('ink-target'))),
      );
      await tester.pump(const Duration(milliseconds: 120));

      expect(lifecycle.created, 1);
      expect(lifecycle.removed, 0);
      expect(lifecycle.active, 1);

      await gesture.up();
      await tester.pump(const Duration(milliseconds: 50));

      expect(taps, 1);
      expect(lifecycle.removed, 0);
      expect(lifecycle.active, 1);

      await tester.pumpAndSettle();

      expect(lifecycle.removed, 1);
      expect(lifecycle.active, 0);
      expectNoFlutterException(tester);
    });

    testWidgets('${entry.key} cancels and disposes an interrupted feature', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      final _InkLifecycle lifecycle = _InkLifecycle();
      await tester.pumpWidget(
        TestApp(
          home: _InkHarness(
            factory: _TrackingInkFactory(entry.value, lifecycle),
            onTap: () => taps += 1,
          ),
        ),
      );

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('ink-target'))),
      );
      await tester.pump(const Duration(milliseconds: 60));

      expect(lifecycle.created, 1);
      expect(lifecycle.removed, 0);
      expect(lifecycle.active, 1);

      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(taps, 0);
      expect(lifecycle.removed, 1);
      expect(lifecycle.active, 0);
      expectNoFlutterException(tester);
    });
  }
}

class _InkLifecycle {
  int created = 0;
  int removed = 0;

  int get active => created - removed;
}

class _TrackingInkFactory extends InteractiveInkFeatureFactory {
  const _TrackingInkFactory(this.delegate, this.lifecycle);

  final InteractiveInkFeatureFactory delegate;
  final _InkLifecycle lifecycle;

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
    lifecycle.created += 1;
    return delegate.create(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      textDirection: textDirection,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: () {
        lifecycle.removed += 1;
        onRemoved?.call();
      },
    );
  }
}

class _InkHarness extends StatelessWidget {
  const _InkHarness({required this.factory, required this.onTap});

  final InteractiveInkFeatureFactory factory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Material(
          color: Colors.blue,
          child: InkWell(
            key: const Key('ink-target'),
            splashFactory: factory,
            onTap: onTap,
            child: const SizedBox(
              width: 160,
              height: 80,
              child: Center(child: Text('Ink target')),
            ),
          ),
        ),
      ),
    );
  }
}
