import 'package:dynamic_color/samples.dart';
import 'package:dynamic_color/test_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;
import 'package:one_ui_example/catalog.dart';

void main() {
  setUp(DynamicColorTestingUtils.setMockDynamicColors);

  test('catalog registry covers every required public widget exactly once', () {
    final List<String> declaredWidgetIds = catalogSections
        .expand((CatalogSection section) => section.widgetIds)
        .toList(growable: false);

    expect(catalogSections, hasLength(8));
    expect(
      catalogSections.map((CatalogSection section) => section.id).toSet(),
      hasLength(catalogSections.length),
      reason: 'Every catalog section needs a stable, unique ID.',
    );
    expect(declaredWidgetIds.toSet(), requiredCatalogWidgetIds);
    expect(
      declaredWidgetIds,
      hasLength(requiredCatalogWidgetIds.length),
      reason: 'A public widget should have one canonical catalog section.',
    );
  });

  testWidgets('all registered sections are reachable at phone size', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const OneUICatalogApp());
    await tester.pumpAndSettle();

    expect(find.byKey(CatalogKeys.homeStatus), findsOneWidget);
    expect(
      find.text('Theme: light · Material You: off · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).extension<one_ui.OneUIThemeData>()?.colorMode,
      one_ui.OneUIColorMode.oneUI,
    );
    expect(tester.takeException(), isNull);

    for (final CatalogSection section in catalogSections) {
      final Finder sectionButton = find.byKey(
        CatalogKeys.openSection(section.id),
      );
      await tester.scrollUntilVisible(
        sectionButton,
        240,
        scrollable: find.descendant(
          of: find.byKey(CatalogKeys.homeList),
          matching: find.byType(Scrollable),
        ),
      );
      expect(sectionButton, findsOneWidget);
    }

    await tester.tap(find.byKey(CatalogKeys.themeMode));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Use light theme'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Material You uses the seed fallback in light and dark modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneUICatalogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(CatalogKeys.materialYouMode));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme: light · Material You: on (seed fallback) · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).colorScheme.primary,
      ColorScheme.fromSeed(seedColor: const Color(0xff0381fe)).primary,
    );
    expect(
      _catalogTheme(tester).extension<one_ui.OneUIThemeData>()?.colorMode,
      one_ui.OneUIColorMode.materialYou,
    );

    await tester.tap(find.byKey(CatalogKeys.themeMode));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme: dark · Material You: on (seed fallback) · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).colorScheme.primary,
      ColorScheme.fromSeed(
        seedColor: const Color(0xff0381fe),
        brightness: Brightness.dark,
      ).primary,
    );

    await tester.tap(find.byKey(CatalogKeys.materialYouMode));
    await tester.pumpAndSettle();
    expect(
      find.text('Theme: dark · Material You: off · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).extension<one_ui.OneUIThemeData>()?.colorMode,
      one_ui.OneUIColorMode.oneUI,
    );
  });

  testWidgets('Material You uses mocked dynamic light and dark schemes', (
    WidgetTester tester,
  ) async {
    DynamicColorTestingUtils.setMockDynamicColors(
      corePalette: SampleCorePalettes.green,
    );
    await tester.pumpWidget(const OneUICatalogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(CatalogKeys.materialYouMode));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme: light · Material You: on (dynamic) · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).colorScheme,
      SampleColorSchemes.green(Brightness.light),
    );

    await tester.tap(find.byKey(CatalogKeys.themeMode));
    await tester.pumpAndSettle();

    expect(
      find.text('Theme: dark · Material You: on (dynamic) · 8 sections'),
      findsOneWidget,
    );
    expect(
      _catalogTheme(tester).colorScheme,
      SampleColorSchemes.green(Brightness.dark),
    );
  });

  testWidgets('theme choices remain selected after section navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OneUICatalogApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(CatalogKeys.materialYouMode));
    await tester.pumpAndSettle();
    final Finder buttonsSection = find.byKey(
      CatalogKeys.openSection(CatalogSectionIds.buttons),
    );
    await tester.scrollUntilVisible(
      buttonsSection,
      240,
      scrollable: find.descendant(
        of: find.byKey(CatalogKeys.homeList),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(buttonsSection);
    await tester.pumpAndSettle();
    expect(
      find.byKey(CatalogKeys.page(CatalogSectionIds.buttons)),
      findsOneWidget,
    );

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byKey(CatalogKeys.homeList),
            matching: find.byType(Scrollable),
          ),
        )
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();

    expect(
      find.text('Theme: light · Material You: on (seed fallback) · 8 sections'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(CatalogKeys.materialYouMode))
          .value,
      isTrue,
    );
  });

  testWidgets('popup menu uses a contained button and still opens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PopupMenusCatalogPage()));

    final Finder popupButton = find.byKey(
      CatalogKeys.widget(CatalogWidgetIds.popupMenuButton),
    );
    final Finder containedButton = find.descendant(
      of: popupButton,
      matching: find.byType(one_ui.OneUIContainedButton),
    );
    expect(containedButton, findsOneWidget);
    expect(
      find.ancestor(of: containedButton, matching: find.byType(InkWell)),
      findsNothing,
    );

    await tester.tap(popupButton);
    await tester.pumpAndSettle();

    expect(find.text('First option'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

ThemeData _catalogTheme(WidgetTester tester) {
  return Theme.of(tester.element(find.byKey(CatalogKeys.homeStatus)));
}
