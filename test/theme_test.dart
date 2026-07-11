import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart';

void main() {
  group('OneUIColorScheme', () {
    test('exposes the official light and dark semantic palettes', () {
      expect(OneUIColorScheme.light.primaryDark, const Color(0xff0072de));
      expect(OneUIColorScheme.light.primary, const Color(0xff0381fe));
      expect(OneUIColorScheme.light.controlActivated, const Color(0xff3e91ff));

      expect(OneUIColorScheme.dark.primaryDark, const Color(0xff3e91ff));
      expect(OneUIColorScheme.dark.primary, const Color(0xff0381fe));
      expect(OneUIColorScheme.dark.controlActivated, const Color(0xff3e91ff));
    });

    for (final Brightness brightness in Brightness.values) {
      testWidgets('resolves ${brightness.name} One UI colors by default', (
        WidgetTester tester,
      ) async {
        late OneUIThemeData configuration;
        late OneUIColorScheme colors;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Builder(
              builder: (BuildContext context) {
                configuration = OneUIThemeData.of(context);
                colors = OneUIColorScheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(configuration.colorMode, OneUIColorMode.oneUI);
        expect(
          colors,
          same(
            brightness == Brightness.dark
                ? OneUIColorScheme.dark
                : OneUIColorScheme.light,
          ),
        );
      });
    }

    testWidgets('maps every semantic accent to Material You primary', (
      WidgetTester tester,
    ) async {
      const Color materialPrimary = Color(0xff6750a4);
      late OneUIColorScheme colors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: materialPrimary,
            ).copyWith(primary: materialPrimary),
            extensions: const <ThemeExtension<dynamic>>[
              OneUIThemeData(colorMode: OneUIColorMode.materialYou),
            ],
          ),
          home: Builder(
            builder: (BuildContext context) {
              colors = OneUIColorScheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(colors.primaryDark, materialPrimary);
      expect(colors.primary, materialPrimary);
      expect(colors.controlActivated, materialPrimary);
    });
  });

  test('OneUIThemeData supports copying and discrete interpolation', () {
    const OneUIThemeData oneUI = OneUIThemeData();
    const OneUIThemeData materialYou = OneUIThemeData(
      colorMode: OneUIColorMode.materialYou,
    );

    expect(oneUI.copyWith().colorMode, OneUIColorMode.oneUI);
    expect(
      oneUI.copyWith(colorMode: OneUIColorMode.materialYou).colorMode,
      OneUIColorMode.materialYou,
    );
    expect(oneUI.lerp(materialYou, 0.49).colorMode, OneUIColorMode.oneUI);
    expect(oneUI.lerp(materialYou, 0.5).colorMode, OneUIColorMode.materialYou);
    expect(oneUI.lerp(null, 1), same(oneUI));
  });

  group('One UI button color modes', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('uses ${brightness.name} One UI primary dark by default', (
        WidgetTester tester,
      ) async {
        await _pumpButtons(tester, brightness: brightness);

        final Color expected = brightness == Brightness.dark
            ? OneUIColorScheme.dark.primaryDark
            : OneUIColorScheme.light.primaryDark;
        expect(_buttonMaterial(tester, const Key('contained')).color, expected);
        expect(
          _buttonMaterial(tester, const Key('flat')).textStyle?.color,
          expected,
        );
      });
    }

    testWidgets('uses ambient primary in Material You mode', (
      WidgetTester tester,
    ) async {
      const Color materialPrimary = Color(0xff6750a4);
      await _pumpButtons(
        tester,
        colorScheme: ColorScheme.fromSeed(
          seedColor: materialPrimary,
        ).copyWith(primary: materialPrimary),
        colorMode: OneUIColorMode.materialYou,
      );

      expect(
        _buttonMaterial(tester, const Key('contained')).color,
        materialPrimary,
      );
      expect(
        _buttonMaterial(tester, const Key('flat')).textStyle?.color,
        materialPrimary,
      );
    });

    testWidgets('widget styles override button themes and semantic colors', (
      WidgetTester tester,
    ) async {
      const Color themeColor = Color(0xff123456);
      const Color widgetColor = Color(0xffabcdef);
      await _pumpButtons(
        tester,
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(themeColor),
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color>(themeColor),
          ),
        ),
        containedStyle: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(widgetColor),
        ),
        flatStyle: const ButtonStyle(
          foregroundColor: WidgetStatePropertyAll<Color>(widgetColor),
        ),
      );

      expect(
        _buttonMaterial(tester, const Key('contained')).color,
        widgetColor,
      );
      expect(
        _buttonMaterial(tester, const Key('flat')).textStyle?.color,
        widgetColor,
      );
    });

    testWidgets('button themes override semantic colors', (
      WidgetTester tester,
    ) async {
      const Color themeColor = Color(0xff123456);
      await _pumpButtons(
        tester,
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(themeColor),
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color>(themeColor),
          ),
        ),
      );

      expect(_buttonMaterial(tester, const Key('contained')).color, themeColor);
      expect(
        _buttonMaterial(tester, const Key('flat')).textStyle?.color,
        themeColor,
      );
    });
  });
}

Future<void> _pumpButtons(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  ColorScheme? colorScheme,
  OneUIColorMode colorMode = OneUIColorMode.oneUI,
  ElevatedButtonThemeData? elevatedButtonTheme,
  TextButtonThemeData? textButtonTheme,
  ButtonStyle? containedStyle,
  ButtonStyle? flatStyle,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        colorScheme: colorScheme,
        elevatedButtonTheme:
            elevatedButtonTheme ?? const ElevatedButtonThemeData(),
        textButtonTheme: textButtonTheme ?? const TextButtonThemeData(),
        extensions: <ThemeExtension<dynamic>>[
          OneUIThemeData(colorMode: colorMode),
        ],
      ),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            OneUIContainedButton(
              key: const Key('contained'),
              onPressed: () {},
              style: containedStyle,
              child: const Text('Contained'),
            ),
            OneUIFlatButton(
              key: const Key('flat'),
              onPressed: () {},
              style: flatStyle,
              child: const Text('Flat'),
            ),
          ],
        ),
      ),
    ),
  );
}

Material _buttonMaterial(WidgetTester tester, Key key) {
  return tester.widget<Material>(
    find.descendant(of: find.byKey(key), matching: find.byType(Material)),
  );
}
