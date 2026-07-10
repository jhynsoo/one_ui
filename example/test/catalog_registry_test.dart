import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui_example/catalog.dart';

void main() {
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
}
