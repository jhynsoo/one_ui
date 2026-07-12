import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

const Color _materialPrimary = Color(0xff9c27b0);

void main() {
  group('One UI control colors', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets(
        'uses One UI semantic colors by default in ${brightness.name}',
        (WidgetTester tester) async {
          final _RecordingSliderTrackShape sliderShape =
              _RecordingSliderTrackShape();

          await tester.pumpWidget(
            _ControlTestApp(
              brightness: brightness,
              sliderShape: sliderShape,
              child: const _Controls(),
            ),
          );

          final OneUIColorScheme expectedColors = brightness == Brightness.dark
              ? OneUIColorScheme.dark
              : OneUIColorScheme.light;

          expect(
            sliderShape.sliderTheme.activeTrackColor,
            expectedColors.primary,
          );
          expect(
            sliderShape.sliderTheme.inactiveTrackColor,
            expectedColors.primary.withValues(alpha: 0.24),
          );
          expect(
            sliderShape.sliderTheme.disabledInactiveTrackColor,
            expectedColors.primary.withValues(alpha: 0.24),
          );
          expect(
            sliderShape.sliderTheme.inactiveTickMarkColor,
            expectedColors.primary.withValues(alpha: 0.54),
          );
          expect(sliderShape.sliderTheme.thumbColor, expectedColors.primary);
          expect(
            sliderShape.sliderTheme.valueIndicatorColor,
            expectedColors.primary,
          );
          expect(
            _switchPainter(tester).activeTrackColor,
            expectedColors.controlActivated,
          );
          expect(
            _switchPainter(tester).activeThumbBorderColor,
            expectedColors.controlActivated,
          );
        },
      );

      testWidgets(
        'uses ambient primary in Material You mode in ${brightness.name}',
        (WidgetTester tester) async {
          final _RecordingSliderTrackShape sliderShape =
              _RecordingSliderTrackShape();

          await tester.pumpWidget(
            _ControlTestApp(
              brightness: brightness,
              colorMode: OneUIColorMode.materialYou,
              sliderShape: sliderShape,
              child: const _Controls(),
            ),
          );

          expect(sliderShape.sliderTheme.activeTrackColor, _materialPrimary);
          expect(
            sliderShape.sliderTheme.inactiveTrackColor,
            _materialPrimary.withValues(alpha: 0.24),
          );
          expect(
            sliderShape.sliderTheme.disabledInactiveTrackColor,
            _materialPrimary.withValues(alpha: 0.24),
          );
          expect(
            sliderShape.sliderTheme.inactiveTickMarkColor,
            _materialPrimary.withValues(alpha: 0.54),
          );
          expect(sliderShape.sliderTheme.thumbColor, _materialPrimary);
          expect(sliderShape.sliderTheme.valueIndicatorColor, _materialPrimary);
          expect(_switchPainter(tester).activeTrackColor, _materialPrimary);
          expect(
            _switchPainter(tester).activeThumbBorderColor,
            _materialPrimary,
          );
        },
      );
    }

    testWidgets('widget and component themes override semantic colors', (
      WidgetTester tester,
    ) async {
      const Color sliderTrack = Color(0xff111111);
      const Color sliderThumb = Color(0xff222222);
      const Color sliderIndicator = Color(0xff333333);
      const Color switchTrack = Color(0xff444444);
      const Color switchThumb = Color(0xff555555);
      final _RecordingSliderTrackShape sliderShape =
          _RecordingSliderTrackShape();

      await tester.pumpWidget(
        _ControlTestApp(
          colorMode: OneUIColorMode.materialYou,
          sliderShape: sliderShape,
          sliderTheme: const SliderThemeData(
            activeTrackColor: sliderTrack,
            thumbColor: sliderThumb,
            valueIndicatorColor: sliderIndicator,
          ),
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              return states.contains(WidgetState.selected) ? switchTrack : null;
            }),
            thumbColor: const WidgetStatePropertyAll<Color>(switchThumb),
          ),
          child: const _Controls(),
        ),
      );

      expect(sliderShape.sliderTheme.activeTrackColor, sliderTrack);
      expect(sliderShape.sliderTheme.thumbColor, sliderThumb);
      expect(sliderShape.sliderTheme.valueIndicatorColor, sliderIndicator);
      expect(_switchPainter(tester).activeTrackColor, switchTrack);
      expect(_switchPainter(tester).thumbColor, switchThumb);

      const Color widgetSlider = Color(0xff666666);
      const Color widgetSwitchTrack = Color(0xff777777);
      const Color widgetSwitchActive = Color(0xff888888);
      const Color widgetSwitchThumb = Color(0xff999999);
      final _RecordingSliderTrackShape explicitSliderShape =
          _RecordingSliderTrackShape();

      await tester.pumpWidget(
        _ControlTestApp(
          colorMode: OneUIColorMode.materialYou,
          sliderShape: explicitSliderShape,
          sliderTheme: const SliderThemeData(
            activeTrackColor: sliderTrack,
            thumbColor: sliderThumb,
          ),
          switchTheme: SwitchThemeData(
            trackColor: const WidgetStatePropertyAll<Color>(switchTrack),
            thumbColor: const WidgetStatePropertyAll<Color>(switchThumb),
          ),
          child: _Controls(
            sliderActiveColor: widgetSlider,
            switchActiveColor: widgetSwitchActive,
            switchTrackColor: const WidgetStatePropertyAll<Color>(
              widgetSwitchTrack,
            ),
            switchThumbColor: widgetSwitchThumb,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(explicitSliderShape.sliderTheme.activeTrackColor, widgetSlider);
      expect(explicitSliderShape.sliderTheme.thumbColor, widgetSlider);
      expect(_switchPainter(tester).activeTrackColor, widgetSwitchTrack);
      expect(_switchPainter(tester).activeThumbBorderColor, widgetSwitchActive);
      expect(_switchPainter(tester).thumbColor, widgetSwitchThumb);
    });

    testWidgets('deprecated color flag does not override the global mode', (
      WidgetTester tester,
    ) async {
      final _RecordingSliderTrackShape sliderShape =
          _RecordingSliderTrackShape();

      await tester.pumpWidget(
        _ControlTestApp(
          colorMode: OneUIColorMode.materialYou,
          sliderShape: sliderShape,
          child: const _Controls(useOneUIColor: true),
        ),
      );

      expect(sliderShape.sliderTheme.activeTrackColor, _materialPrimary);
      expect(_switchPainter(tester).activeTrackColor, _materialPrimary);
    });
  });
}

class _ControlTestApp extends StatelessWidget {
  const _ControlTestApp({
    required this.child,
    required this.sliderShape,
    this.brightness = Brightness.light,
    this.colorMode,
    this.sliderTheme,
    this.switchTheme,
  });

  final Widget child;
  final _RecordingSliderTrackShape sliderShape;
  final Brightness brightness;
  final OneUIColorMode? colorMode;
  final SliderThemeData? sliderTheme;
  final SwitchThemeData? switchTheme;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _materialPrimary,
      brightness: brightness,
    ).copyWith(primary: _materialPrimary);

    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        colorScheme: colorScheme,
        extensions: <ThemeExtension<dynamic>>[
          if (colorMode case final OneUIColorMode mode)
            OneUIThemeData(colorMode: mode),
        ],
        sliderTheme: (sliderTheme ?? const SliderThemeData()).copyWith(
          trackShape: sliderShape,
        ),
        switchTheme: switchTheme,
      ),
      home: Scaffold(body: Center(child: child)),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    this.sliderActiveColor,
    this.switchActiveColor,
    this.switchTrackColor,
    this.switchThumbColor,
    this.useOneUIColor = false,
  });

  final Color? sliderActiveColor;
  final Color? switchActiveColor;
  final WidgetStateProperty<Color?>? switchTrackColor;
  final Color? switchThumbColor;
  final bool useOneUIColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OneUISlider(
          value: 0.5,
          label: 'Value',
          activeColor: sliderActiveColor,
          // ignore: deprecated_member_use_from_same_package
          useOneUIColor: useOneUIColor,
          onChanged: (_) {},
        ),
        OneUISwitch(
          value: true,
          activeColor: switchActiveColor,
          trackColor: switchTrackColor,
          thumbColor: switchThumbColor,
          // ignore: deprecated_member_use_from_same_package
          useOneUIColor: useOneUIColor,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

dynamic _switchPainter(WidgetTester tester) {
  final Finder paints = find.descendant(
    of: find.byType(OneUISwitch),
    matching: find.byType(CustomPaint),
  );
  for (final CustomPaint paint in tester.widgetList<CustomPaint>(paints)) {
    final CustomPainter? painter = paint.painter;
    if (painter != null && painter.runtimeType.toString() == '_SwitchPainter') {
      return painter;
    }
  }
  throw TestFailure('Could not find the One UI switch painter.');
}

class _RecordingSliderTrackShape extends SliderTrackShape {
  static const SliderTrackShape _delegate = RoundedRectSliderTrackShape();

  late SliderThemeData sliderTheme;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    return _delegate.getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    this.sliderTheme = sliderTheme;
    _delegate.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );
  }
}
