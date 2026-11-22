// ignore: deprecated_member_use
import 'package:flutter/material.dart' as sdk;
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

void main() {
  testWidgets('showMenu returns the value of an SDK PopupMenuItem', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const sdk.MaterialApp(home: sdk.Scaffold()));
    final Future<int?> result = one_ui.showMenu<int>(
      context: tester.element(find.byType(sdk.Scaffold)),
      position: const sdk.RelativeRect.fromLTRB(16, 16, 0, 0),
      items: const <sdk.PopupMenuEntry<int>>[
        sdk.PopupMenuItem<int>(value: 42, child: sdk.Text('Forty two')),
      ],
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Forty two'));
    await tester.pumpAndSettle();
    expect(await result, 42);
  });

  test('OneUIIconButton can be assigned to an SDK IconButton', () {
    bool pressed = false;
    final sdk.IconButton button = one_ui.OneUIIconButton(
      onPressed: () => pressed = true,
      icon: const sdk.Icon(sdk.Icons.add),
    );
    button.onPressed!();
    expect(pressed, isTrue);
  });

  testWidgets('OneUISwitch accepts the SDK tap target size', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      sdk.MaterialApp(
        theme: sdk.ThemeData(
          materialTapTargetSize: sdk.MaterialTapTargetSize.padded,
        ),
        home: const sdk.Material(
          child: sdk.Center(
            child: one_ui.OneUISwitch(
              value: false,
              onChanged: null,
              materialTapTargetSize: sdk.MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(one_ui.OneUISwitch)).height, 40);
  });

  testWidgets('OneUISlider paints the thumb color from the SDK SliderTheme', (
    WidgetTester tester,
  ) async {
    const sdk.Color thumbColor = sdk.Color(0xffad1753);
    await tester.pumpWidget(
      sdk.MaterialApp(
        home: sdk.Material(
          child: sdk.Center(
            child: sdk.SliderTheme(
              data: const sdk.SliderThemeData(thumbColor: thumbColor),
              child: one_ui.OneUISlider(value: 0.5, onChanged: (_) {}),
            ),
          ),
        ),
      ),
    );
    final sdk.MaterialInkController material = sdk.Material.of(
      tester.element(find.byType(one_ui.OneUISlider)),
    );
    expect(material, paints..circle(color: thumbColor));
  });
}
