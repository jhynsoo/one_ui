import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

import 'test_app.dart';

void main() {
  group('One UI switch', () {
    testWidgets('tap toggles an enabled switch and disabled switch is inert', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp(home: _SwitchHarness()));

      await tester.tap(find.byKey(const Key('enabled-switch')));
      await tester.pumpAndSettle();
      expect(find.text('enabled:true'), findsOneWidget);
      expect(find.text('changes:1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('disabled-switch')));
      await tester.pumpAndSettle();
      expect(find.text('disabled changes:0'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('horizontal drag changes the switch value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp(home: _DragSwitchHarness()));

      await tester.drag(
        find.byKey(const Key('drag-switch')),
        const Offset(48, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('dragged:true'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('semantics expose toggle and enabled state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(const TestApp(home: _SwitchHarness()));

      expect(
        tester.getSemantics(find.byKey(const Key('enabled-switch'))),
        matchesSemantics(
          hasEnabledState: true,
          isEnabled: true,
          hasToggledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const Key('disabled-switch'))),
        matchesSemantics(hasEnabledState: true, hasToggledState: true),
      );
      semantics.dispose();
      expectNoFlutterException(tester);
    });
  });

  group('One UI slider', () {
    testWidgets('continuous drag reports start, changes, and end', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(home: _SliderHarness(initialValue: 0.2)),
      );
      final _SliderHarnessState state = tester.state<_SliderHarnessState>(
        find.byType(_SliderHarness),
      );

      await tester.drag(find.byKey(const Key('slider')), const Offset(140, 0));
      await tester.pumpAndSettle();

      expect(state.starts, <double>[0.2]);
      expect(state.changes, isNotEmpty);
      expect(state.ends, hasLength(1));
      expect(state.value, greaterThan(0.2));
      expectNoFlutterException(tester);
    });

    testWidgets('discrete slider snaps to a division', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          home: _SliderHarness(
            initialValue: 0.5,
            divisions: 4,
            label: 'Discrete value',
          ),
        ),
      );
      final _SliderHarnessState state = tester.state<_SliderHarnessState>(
        find.byType(_SliderHarness),
      );
      final Rect sliderRect = tester.getRect(find.byKey(const Key('slider')));

      await tester.tapAt(
        Offset(sliderRect.left + sliderRect.width * 0.75, sliderRect.center.dy),
      );
      await tester.pumpAndSettle();

      expect(state.value * 4, closeTo((state.value * 4).round(), 0.0001));
      expect(state.value, greaterThan(0.5));
      expectNoFlutterException(tester);
    });

    testWidgets('disabled slider ignores pointer interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(home: _SliderHarness(initialValue: 0.4, enabled: false)),
      );
      final _SliderHarnessState state = tester.state<_SliderHarnessState>(
        find.byType(_SliderHarness),
      );

      await tester.drag(find.byKey(const Key('slider')), const Offset(180, 0));
      await tester.pumpAndSettle();

      expect(state.value, 0.4);
      expect(state.changes, isEmpty);
      expect(state.starts, isEmpty);
      expect(state.ends, isEmpty);
      expectNoFlutterException(tester);
    });

    testWidgets('onDrag value indicator follows the interaction lifecycle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          home: _SliderHarness(
            initialValue: 0.5,
            label: 'Dragging',
            showValueIndicator: ShowValueIndicator.onDrag,
          ),
        ),
      );
      final _SliderHarnessState state = tester.state<_SliderHarnessState>(
        find.byType(_SliderHarness),
      );

      expect(find.byType(CompositedTransformFollower), findsNothing);

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('slider'))),
      );
      await gesture.moveBy(const Offset(48, 0));
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(CompositedTransformFollower), findsOneWidget);

      await gesture.up();
      expect(state.ends, hasLength(1));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.pump();
      expect(find.byType(CompositedTransformFollower), findsNothing);
      expectNoFlutterException(tester);
    });

    testWidgets('onDrag indicator ignores hover but appears for focus', (
      WidgetTester tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      final _RecordingSliderOverlayShape overlayShape =
          _RecordingSliderOverlayShape();
      final FocusHighlightStrategy previousHighlightStrategy =
          FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() {
        FocusManager.instance.highlightStrategy = previousHighlightStrategy;
        focusNode.dispose();
      });

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: Center(
              child: SliderTheme(
                data: SliderThemeData(
                  overlayShape: overlayShape,
                  showValueIndicator: ShowValueIndicator.onDrag,
                ),
                child: one_ui.OneUISlider(
                  key: const Key('hover-slider'),
                  value: 0.5,
                  label: 'Focused',
                  focusNode: focusNode,
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      final Rect sliderRect = tester.getRect(
        find.byKey(const Key('hover-slider')),
      );

      await mouse.moveTo(sliderRect.center);
      await tester.pumpAndSettle();

      expect(overlayShape.activationValue, 1.0);
      expect(find.byType(CompositedTransformFollower), findsNothing);

      await mouse.moveTo(Offset(sliderRect.left + 1, sliderRect.center.dy));
      await tester.pumpAndSettle();

      expect(overlayShape.activationValue, 0.0);
      expect(find.byType(CompositedTransformFollower), findsNothing);

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(overlayShape.activationValue, 1.0);
      expect(find.byType(CompositedTransformFollower), findsOneWidget);

      focusNode.unfocus();
      await tester.pumpAndSettle();
      await mouse.removePointer();

      expect(find.byType(CompositedTransformFollower), findsNothing);
      expectNoFlutterException(tester);
    });

    testWidgets('alwaysVisible value indicator is removed when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(
          home: _SliderHarness(
            initialValue: 0.5,
            label: 'Always',
            showValueIndicator: ShowValueIndicator.alwaysVisible,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompositedTransformFollower), findsOneWidget);

      await tester.pumpWidget(
        const TestApp(
          home: _SliderHarness(
            initialValue: 0.5,
            label: 'Always',
            enabled: false,
            showValueIndicator: ShowValueIndicator.alwaysVisible,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompositedTransformFollower), findsNothing);
      expectNoFlutterException(tester);
    });

    testWidgets('keyboard arrows adjust a focused slider', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const TestApp(home: _SliderHarness(initialValue: 0.5, autofocus: true)),
      );
      await tester.pump();
      final _SliderHarnessState state = tester.state<_SliderHarnessState>(
        find.byType(_SliderHarness),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();

      expect(state.value, greaterThan(0.5));
      expect(state.changes, isNotEmpty);
      expectNoFlutterException(tester);
    });

    testWidgets('semantics expose value and adjustment actions', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        const TestApp(
          home: _SliderHarness(initialValue: 0.5, formatSemantics: true),
        ),
      );

      expect(
        tester.getSemantics(find.byKey(const Key('slider'))),
        matchesSemantics(
          value: '50 percent',
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          isSlider: true,
          hasFocusAction: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      semantics.dispose();
      expectNoFlutterException(tester);
    });
  });
}

class _SwitchHarness extends StatefulWidget {
  const _SwitchHarness();

  @override
  State<_SwitchHarness> createState() => _SwitchHarnessState();
}

class _SwitchHarnessState extends State<_SwitchHarness> {
  bool enabledValue = false;
  int enabledChanges = 0;
  int disabledChanges = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          one_ui.OneUISwitch(
            key: const Key('enabled-switch'),
            value: enabledValue,
            onChanged: (bool value) {
              setState(() {
                enabledValue = value;
                enabledChanges += 1;
              });
            },
          ),
          one_ui.OneUISwitch(
            key: const Key('disabled-switch'),
            value: false,
            onChanged: null,
          ),
          Text('enabled:$enabledValue'),
          Text('changes:$enabledChanges'),
          Text('disabled changes:$disabledChanges'),
        ],
      ),
    );
  }
}

class _DragSwitchHarness extends StatefulWidget {
  const _DragSwitchHarness();

  @override
  State<_DragSwitchHarness> createState() => _DragSwitchHarnessState();
}

class _DragSwitchHarnessState extends State<_DragSwitchHarness> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          one_ui.OneUISwitch(
            key: const Key('drag-switch'),
            value: value,
            onChanged: (bool nextValue) => setState(() => value = nextValue),
          ),
          Text('dragged:$value'),
        ],
      ),
    );
  }
}

class _SliderHarness extends StatefulWidget {
  const _SliderHarness({
    required this.initialValue,
    this.divisions,
    this.label,
    this.enabled = true,
    this.autofocus = false,
    this.formatSemantics = false,
    this.showValueIndicator,
  });

  final double initialValue;
  final int? divisions;
  final String? label;
  final bool enabled;
  final bool autofocus;
  final bool formatSemantics;
  final ShowValueIndicator? showValueIndicator;

  @override
  State<_SliderHarness> createState() => _SliderHarnessState();
}

class _SliderHarnessState extends State<_SliderHarness> {
  late double value;
  final List<double> changes = <double>[];
  final List<double> starts = <double>[];
  final List<double> ends = <double>[];

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  void _handleChanged(double nextValue) {
    setState(() => value = nextValue);
    changes.add(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final Widget slider = one_ui.OneUISlider(
      key: const Key('slider'),
      value: value,
      divisions: widget.divisions,
      label: widget.label,
      autofocus: widget.autofocus,
      semanticFormatterCallback: widget.formatSemantics
          ? (double sliderValue) => '${(sliderValue * 100).round()} percent'
          : null,
      onChanged: widget.enabled ? _handleChanged : null,
      onChangeStart: starts.add,
      onChangeEnd: ends.add,
    );

    return Scaffold(
      body: Center(
        child: widget.showValueIndicator == null
            ? slider
            : SliderTheme(
                data: SliderTheme.of(
                  context,
                ).copyWith(showValueIndicator: widget.showValueIndicator),
                child: slider,
              ),
      ),
    );
  }
}

class _RecordingSliderOverlayShape extends SliderComponentShape {
  double activationValue = 0.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    activationValue = activationAnimation.value;
  }
}
