import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:one_ui_example/catalog.dart';
import 'package:one_ui_example/main.dart' as app;

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Let Chrome render every requested frame. Bounded pumps below avoid the
    // indefinite settling that a continuously live WebDriver tab can cause.
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  testWidgets('visits all catalog sections and exercises core interactions', (
    WidgetTester tester,
  ) async {
    final Set<String> visitedSectionIds = <String>{};
    final Set<String> visitedWidgetIds = <String>{};

    app.main();
    debugPrint('Catalog integration: app launched');
    await _pumpFrames(tester);
    debugPrint('Catalog integration: home settled');
    _expectNoException(tester);

    await _openSection(
      tester,
      CatalogSectionIds.appBarAndView,
      visitedSectionIds,
    );
    _markWidgetVisited(tester, CatalogWidgetIds.view, visitedWidgetIds);
    _markWidgetVisited(tester, CatalogWidgetIds.appBar, visitedWidgetIds);
    _markWidgetVisited(tester, CatalogWidgetIds.backButton, visitedWidgetIds);
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.backButton)),
    );
    await tester.pump();
    expect(find.text('Back button pressed'), findsOneWidget);
    await tester.drag(
      find.byKey(CatalogKeys.viewScroll),
      const Offset(0, -260),
    );
    await _pumpFrames(tester);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(
      tester,
      CatalogSectionIds.bottomNavigation,
      visitedSectionIds,
    );
    _markWidgetVisited(
      tester,
      CatalogWidgetIds.bottomNavigationBar,
      visitedWidgetIds,
    );
    await tester.tap(find.text('Library').last);
    await _pumpFrames(tester);
    expect(find.text('Selected: Library'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.buttons, visitedSectionIds);
    _markWidgetVisited(
      tester,
      CatalogWidgetIds.containedButton,
      visitedWidgetIds,
    );
    _markWidgetVisited(tester, CatalogWidgetIds.flatButton, visitedWidgetIds);
    _markWidgetVisited(tester, CatalogWidgetIds.iconButton, visitedWidgetIds);
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.containedButton)),
    );
    await tester.pump();
    expect(find.text('Contained button pressed'), findsOneWidget);
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.flatButton)),
    );
    await tester.pump();
    expect(find.text('Flat button pressed'), findsOneWidget);
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.iconButton)),
    );
    await _pumpFrames(tester);
    expect(find.text('Icon button pressed'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.dialogs, visitedSectionIds);
    await tester.tap(find.byKey(CatalogKeys.action('dialog.raw.open')));
    await _pumpFrames(tester);
    expect(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.dialog)),
      findsOneWidget,
    );
    _markWidgetVisited(tester, CatalogWidgetIds.dialog, visitedWidgetIds);
    await tester.tap(find.byKey(CatalogKeys.action('dialog.raw.close')));
    await _pumpFrames(tester);
    expect(find.text('Raw dialog: closed'), findsOneWidget);
    await tester.tap(find.byKey(CatalogKeys.action('dialog.alert.open')));
    await _pumpFrames(tester);
    expect(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.alertDialog)),
      findsOneWidget,
    );
    _markWidgetVisited(tester, CatalogWidgetIds.alertDialog, visitedWidgetIds);
    await tester.tap(find.byKey(CatalogKeys.action('dialog.alert.accept')));
    await _pumpFrames(tester);
    expect(find.text('Alert dialog: accepted'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.popupMenus, visitedSectionIds);
    _markWidgetVisited(
      tester,
      CatalogWidgetIds.popupMenuButton,
      visitedWidgetIds,
    );
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.popupMenuButton)),
    );
    await _pumpFrames(tester);
    expect(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.popupMenuItem)),
      findsOneWidget,
    );
    _markWidgetVisited(
      tester,
      CatalogWidgetIds.popupMenuItem,
      visitedWidgetIds,
    );
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.popupMenuItem)),
    );
    await _pumpFrames(tester);
    expect(find.text('Selected: first'), findsOneWidget);
    await tester.tap(find.byKey(CatalogKeys.action('popup.direct.open')));
    await _pumpFrames(tester);
    await tester.tap(find.byKey(CatalogKeys.action('popup.direct.item')));
    await _pumpFrames(tester);
    expect(find.text('Selected: direct'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.switches, visitedSectionIds);
    _markWidgetVisited(
      tester,
      CatalogWidgetIds.switchControl,
      visitedWidgetIds,
    );
    await tester.tap(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.switchControl)),
    );
    await _pumpFrames(tester);
    expect(find.text('Enabled switch: on'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.sliders, visitedSectionIds);
    _markWidgetVisited(tester, CatalogWidgetIds.slider, visitedWidgetIds);
    await tester.drag(
      find.byKey(CatalogKeys.widget(CatalogWidgetIds.slider)),
      const Offset(100, 0),
    );
    await _pumpFrames(tester);
    expect(find.textContaining('Continuous ended:'), findsOneWidget);
    _expectNoException(tester);
    await _returnHome(tester);

    await _openSection(tester, CatalogSectionIds.inkEffects, visitedSectionIds);
    await tester.tap(find.byKey(CatalogKeys.action('ink.ripple')));
    await _pumpFrames(tester);
    expect(find.text('OneUIInkRipple completed'), findsOneWidget);
    await tester.tap(find.byKey(CatalogKeys.action('ink.splash')));
    await _pumpFrames(tester);
    expect(find.text('OneUIInkSplash completed'), findsOneWidget);
    _expectNoException(tester);

    expect(
      visitedSectionIds,
      catalogSections.map((CatalogSection section) => section.id).toSet(),
      reason: 'The smoke flow must stay in sync with the section registry.',
    );
    expect(
      visitedWidgetIds,
      requiredCatalogWidgetIds,
      reason: 'The smoke flow must render every required public widget.',
    );
  });
}

Future<void> _openSection(
  WidgetTester tester,
  String sectionId,
  Set<String> visitedSectionIds,
) async {
  final Finder sectionButton = find.byKey(CatalogKeys.openSection(sectionId));
  await tester.scrollUntilVisible(
    sectionButton,
    240,
    scrollable: find.descendant(
      of: find.byKey(CatalogKeys.homeList),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(sectionButton);
  await _pumpFrames(tester);
  debugPrint('Catalog integration: opened $sectionId');
  expect(find.byKey(CatalogKeys.page(sectionId)), findsOneWidget);
  visitedSectionIds.add(sectionId);
  _expectNoException(tester);
}

Future<void> _returnHome(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator).first).pop();
  await _pumpFrames(tester);
  expect(find.byKey(CatalogKeys.homeList), findsOneWidget);
  _expectNoException(tester);
}

Future<void> _pumpFrames(WidgetTester tester) async {
  if (kIsWeb) {
    await tester.pump(const Duration(seconds: 1));
  } else {
    await tester.pumpAndSettle();
  }
}

void _expectNoException(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

void _markWidgetVisited(
  WidgetTester tester,
  String widgetId,
  Set<String> visitedWidgetIds,
) {
  expect(find.byKey(CatalogKeys.widget(widgetId)), findsOneWidget);
  visitedWidgetIds.add(widgetId);
}
