import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

import 'test_app.dart';

void main() {
  group('One UI buttons', () {
    testWidgets('contained button keeps its required nullable child API', (
      WidgetTester tester,
    ) async {
      int taps = 0;

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: one_ui.OneUIContainedButton(
              key: const Key('nullable-child-button'),
              onPressed: () => taps += 1,
              child: null,
            ),
          ),
        ),
      );

      final one_ui.OneUIContainedButton button = tester.widget(
        find.byKey(const Key('nullable-child-button')),
      );
      expect(button.child, isA<SizedBox>());

      await tester.tap(find.byKey(const Key('nullable-child-button')));
      await tester.pump();

      expect(taps, 1);
      expectNoFlutterException(tester);
    });

    testWidgets('dispatch enabled, disabled, and long-press callbacks', (
      WidgetTester tester,
    ) async {
      int containedTaps = 0;
      int containedLongPresses = 0;
      int flatTaps = 0;
      int iconTaps = 0;

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                one_ui.OneUIContainedButton(
                  key: const Key('contained-enabled'),
                  onPressed: () => containedTaps += 1,
                  onLongPress: () => containedLongPresses += 1,
                  child: const Text('Contained enabled'),
                ),
                const one_ui.OneUIContainedButton(
                  key: Key('contained-disabled'),
                  onPressed: null,
                  child: Text('Contained disabled'),
                ),
                one_ui.OneUIFlatButton(
                  key: const Key('flat-enabled'),
                  onPressed: () => flatTaps += 1,
                  child: const Text('Flat enabled'),
                ),
                const one_ui.OneUIFlatButton(
                  key: Key('flat-disabled'),
                  onPressed: null,
                  child: Text('Flat disabled'),
                ),
                one_ui.OneUIIconButton(
                  key: const Key('icon-enabled'),
                  tooltip: 'Enabled icon',
                  onPressed: () => iconTaps += 1,
                  icon: const Icon(Icons.add),
                ),
                const one_ui.OneUIIconButton(
                  key: Key('icon-disabled'),
                  tooltip: 'Disabled icon',
                  onPressed: null,
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('contained-enabled')));
      await tester.tap(find.byKey(const Key('flat-enabled')));
      await tester.tap(find.byKey(const Key('icon-enabled')));
      await tester.tap(find.byKey(const Key('contained-disabled')));
      await tester.tap(find.byKey(const Key('flat-disabled')));
      await tester.tap(find.byKey(const Key('icon-disabled')));
      await tester.pump();

      expect(containedTaps, 1);
      expect(flatTaps, 1);
      expect(iconTaps, 1);

      await tester.longPress(find.byKey(const Key('contained-enabled')));
      await tester.pumpAndSettle();

      expect(containedLongPresses, 1);
      expect(containedTaps, 1);
      expectNoFlutterException(tester);
    });

    testWidgets('themed font size does not change default button padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 20)),
          ),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                one_ui.OneUIContainedButton(
                  key: const Key('contained-themed-font'),
                  onPressed: () {},
                  child: const Text('Contained'),
                ),
                one_ui.OneUIFlatButton(
                  key: const Key('flat-themed-font'),
                  onPressed: () {},
                  child: const Text('Flat'),
                ),
              ],
            ),
          ),
        ),
      );

      final Finder contained = find.byKey(const Key('contained-themed-font'));
      final Finder flat = find.byKey(const Key('flat-themed-font'));

      expect(
        tester
            .widget<one_ui.OneUIContainedButton>(contained)
            .defaultStyleOf(tester.element(contained))
            .padding
            ?.resolve(<WidgetState>{}),
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(
        tester
            .widget<one_ui.OneUIFlatButton>(flat)
            .defaultStyleOf(tester.element(flat))
            .padding
            ?.resolve(<WidgetState>{}),
        const EdgeInsets.all(8),
      );
    });

    testWidgets('exposes enabled and disabled button semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                one_ui.OneUIContainedButton(
                  key: const Key('enabled-button'),
                  onPressed: () {},
                  child: const Text('Save'),
                ),
                const one_ui.OneUIIconButton(
                  key: Key('disabled-button'),
                  onPressed: null,
                  tooltip: 'Unavailable',
                  icon: Icon(Icons.block),
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byKey(const Key('enabled-button'))),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const Key('disabled-button'))),
        matchesSemantics(isButton: true, hasEnabledState: true),
      );
      semantics.dispose();
      expectNoFlutterException(tester);
    });
  });

  group('One UI navigation', () {
    testWidgets('bottom navigation reports and renders selection changes', (
      WidgetTester tester,
    ) async {
      int currentIndex = 0;
      int? tappedIndex;

      await tester.pumpWidget(
        TestApp(
          home: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                bottomNavigationBar: one_ui.OneUIBottomNavigationBar(
                  key: const Key('bottom-navigation'),
                  currentIndex: currentIndex,
                  onTap: (int value) {
                    setState(() => currentIndex = value);
                    tappedIndex = value;
                  },
                  items: const <one_ui.OneUIBottomNavigationBarItem>[
                    one_ui.OneUIBottomNavigationBarItem(label: 'Home'),
                    one_ui.OneUIBottomNavigationBarItem(label: 'Library'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
      expect(
        tester
            .widget<one_ui.OneUIBottomNavigationBar>(
              find.byKey(const Key('bottom-navigation')),
            )
            .currentIndex,
        1,
      );
      expectNoFlutterException(tester);
    });

    testWidgets('bottom navigation applies its background color', (
      WidgetTester tester,
    ) async {
      const Color backgroundColor = Color(0xff123456);

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            bottomNavigationBar: one_ui.OneUIBottomNavigationBar(
              backgroundColor: backgroundColor,
              items: const <one_ui.OneUIBottomNavigationBarItem>[
                one_ui.OneUIBottomNavigationBarItem(label: 'Home'),
                one_ui.OneUIBottomNavigationBarItem(label: 'More'),
              ],
            ),
          ),
        ),
      );

      final Material material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(one_ui.OneUIBottomNavigationBar),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, backgroundColor);
    });

    test('bottom navigation items require exactly one label source', () {
      expect(() => one_ui.OneUIBottomNavigationBarItem(), throwsAssertionError);
      expect(
        () => one_ui.OneUIBottomNavigationBarItem(
          title: const Text('Legacy'),
          label: 'Current',
        ),
        throwsAssertionError,
      );
      expect(
        () => const one_ui.OneUIBottomNavigationBarItem(label: 'Current'),
        returnsNormally,
      );
    });

    testWidgets('back button pops a route or invokes its override', (
      WidgetTester tester,
    ) async {
      int overrideCalls = 0;

      await tester.pumpWidget(
        TestApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Column(
                  children: <Widget>[
                    ElevatedButton(
                      key: const Key('push-route'),
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => Scaffold(
                              body: Center(
                                child: one_ui.OneUIBackButton(
                                  key: const Key('pop-route'),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Push'),
                    ),
                    one_ui.OneUIBackButton(
                      key: const Key('override-back'),
                      onPressed: () => overrideCalls += 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('override-back')));
      expect(overrideCalls, 1);

      await tester.tap(find.byKey(const Key('push-route')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pop-route')), findsOneWidget);

      await tester.tap(find.byKey(const Key('pop-route')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pop-route')), findsNothing);
      expect(find.byKey(const Key('push-route')), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('app bar renders title, leading, and actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            appBar: one_ui.OneUIAppBar(
              leading: const Icon(Icons.menu),
              title: const Text('Inbox'),
              actions: <Widget>[
                one_ui.OneUIIconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(one_ui.OneUIAppBar), findsOneWidget);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets(
      'app bar honors theme centering and includes its bottom height',
      (WidgetTester tester) async {
        final one_ui.OneUIAppBar appBar = one_ui.OneUIAppBar(
          toolbarHeight: 70,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(30),
            child: SizedBox(),
          ),
        );
        expect(appBar.preferredSize.height, 100);
        expect(
          () => one_ui.OneUIAppBar(toolbarOpacity: -0.1),
          throwsAssertionError,
        );
        expect(
          () => one_ui.OneUIAppBar(bottomOpacity: 1.1),
          throwsAssertionError,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              appBarTheme: const AppBarThemeData(centerTitle: true),
            ),
            home: Scaffold(
              appBar: one_ui.OneUIAppBar(title: const Text('Centered')),
            ),
          ),
        );

        expect(
          tester
              .widget<NavigationToolbar>(find.byType(NavigationToolbar))
              .centerMiddle,
          isTrue,
        );
        expectNoFlutterException(tester);
      },
    );

    testWidgets('view expands and collapses while its body scrolls', (
      WidgetTester tester,
    ) async {
      setTestViewSize(tester, const Size(390, 844));
      final GlobalKey<NestedScrollViewState> viewKey =
          GlobalKey<NestedScrollViewState>();

      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: one_ui.OneUIView(
              globalKey: viewKey,
              expandedHeight: 280,
              title: const Text('Collapsed title'),
              largeTitle: const Text('Large title'),
              child: ListView.builder(
                key: const Key('view-list'),
                padding: EdgeInsets.zero,
                itemCount: 40,
                itemBuilder: (BuildContext context, int index) =>
                    SizedBox(height: 56, child: Text('Row $index')),
              ),
            ),
          ),
        ),
      );

      expect(viewKey.currentState!.outerController.offset, 0);
      await tester.drag(
        find.byKey(const Key('view-list')),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();

      expect(viewKey.currentState!.outerController.offset, greaterThan(0));
      expect(find.text('Collapsed title'), findsOneWidget);
      expect(find.text('Large title'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    test('view requires exactly one body source', () {
      expect(
        () => one_ui.OneUIView(title: const Text('Missing body')),
        throwsAssertionError,
      );
      expect(
        () => one_ui.OneUIView(
          title: const Text('Ambiguous body'),
          slivers: const <Widget>[],
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
      expect(
        () => one_ui.OneUIView(
          title: const Text('Child body'),
          child: const SizedBox(),
        ),
        returnsNormally,
      );
      expect(
        () => one_ui.OneUIView(
          title: const Text('Sliver body'),
          slivers: const <Widget>[],
        ),
        returnsNormally,
      );
      expect(
        () => one_ui.OneUIView(
          title: const Text('Invalid spacing'),
          actionSpacing: -1,
          child: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('view renders a sliver body', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: one_ui.OneUIView(
              title: const Text('Sliver view'),
              expandedHeight: 200,
              slivers: const <Widget>[
                SliverToBoxAdapter(child: Text('Sliver content')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sliver content'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('view inserts the requested spacing between actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          home: Scaffold(
            body: one_ui.OneUIView(
              title: const Text('Spaced actions'),
              actionSpacing: 12,
              actions: const <Widget>[
                SizedBox(key: Key('first-action'), width: 20),
                SizedBox(key: Key('second-action'), width: 20),
              ],
              child: ListView(),
            ),
          ),
        ),
      );

      final Rect firstAction = tester.getRect(
        find.byKey(const Key('first-action')),
      );
      final Rect secondAction = tester.getRect(
        find.byKey(const Key('second-action')),
      );

      expect(secondAction.left - firstAction.right, 12);
      expectNoFlutterException(tester);
    });
  });
}
