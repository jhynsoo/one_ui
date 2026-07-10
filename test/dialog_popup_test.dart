import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

import 'test_app.dart';

void main() {
  group('One UI dialogs', () {
    testWidgets('honors a locked barrier and returns an action result', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp(home: _DialogHarness()));

      await tester.tap(find.byKey(const Key('open-locked-dialog')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('locked-dialog-route')), findsOneWidget);
      expect(find.byType(one_ui.OneUIAlertDialog), findsOneWidget);
      expect(find.text('Delete item?'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('Delete item?'), findsOneWidget);
      expect(find.text('locked:pending'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete item?'), findsNothing);
      expect(find.text('locked:accepted'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('raw dialog can be canceled through its barrier', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp(home: _DialogHarness()));

      await tester.tap(find.byKey(const Key('open-raw-dialog')));
      await tester.pumpAndSettle();

      expect(find.byType(one_ui.OneUIDialog), findsOneWidget);
      expect(find.text('Raw dialog body'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('Raw dialog body'), findsNothing);
      expect(find.text('raw:canceled'), findsOneWidget);
      expectNoFlutterException(tester);
    });
  });

  group('One UI popup menus', () {
    testWidgets(
      'custom child selects an enabled item and ignores disabled item',
      (WidgetTester tester) async {
        await tester.pumpWidget(const TestApp(home: _PopupHarness()));

        await tester.tap(find.byKey(const Key('custom-popup')));
        await tester.pumpAndSettle();
        expect(find.text('Unavailable'), findsOneWidget);
        expect(find.text('Choose me'), findsOneWidget);

        await tester.tap(find.text('Unavailable'));
        await tester.pump();
        expect(find.text('Unavailable'), findsOneWidget);
        expect(find.text('selected:none'), findsOneWidget);

        await tester.tap(find.text('Choose me'));
        await tester.pumpAndSettle();
        expect(find.text('Choose me'), findsNothing);
        expect(find.text('selected:chosen'), findsOneWidget);
        expectNoFlutterException(tester);
      },
    );

    testWidgets('icon menu reports cancel and disabled button stays inert', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TestApp(home: _PopupHarness()));

      await tester.tap(find.byKey(const Key('disabled-popup')));
      await tester.pump();
      expect(find.text('Should not build'), findsNothing);
      expect(find.text('disabled builds:0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('icon-popup')));
      await tester.pumpAndSettle();
      expect(find.text('Icon option'), findsOneWidget);

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('canceled:1'), findsOneWidget);
      expectNoFlutterException(tester);
    });

    testWidgets('showMenu returns a typed value', (WidgetTester tester) async {
      await tester.pumpWidget(const TestApp(home: _PopupHarness()));

      await tester.tap(find.byKey(const Key('show-raw-menu')));
      await tester.pumpAndSettle();
      expect(find.text('Forty two'), findsOneWidget);

      await tester.tap(find.text('Forty two'));
      await tester.pumpAndSettle();
      expect(find.text('raw:42'), findsOneWidget);
      expectNoFlutterException(tester);
    });
  });
}

class _DialogHarness extends StatefulWidget {
  const _DialogHarness();

  @override
  State<_DialogHarness> createState() => _DialogHarnessState();
}

class _DialogHarnessState extends State<_DialogHarness> {
  String lockedResult = 'pending';
  String rawResult = 'pending';

  Future<void> _openLockedDialog() async {
    final String? result = await one_ui.showOneUIDialog<String>(
      key: const Key('locked-dialog-route'),
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return one_ui.OneUIAlertDialog(
          title: const Text('Delete item?'),
          content: const Text('This action can be confirmed.'),
          actions: <one_ui.OneUIDialogAction>[
            one_ui.OneUIDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop('accepted'),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (mounted) {
      setState(() => lockedResult = result ?? 'canceled');
    }
  }

  Future<void> _openRawDialog() async {
    final String? result = await one_ui.showOneUIDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const one_ui.OneUIDialog(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Raw dialog body'),
          ),
        );
      },
    );
    if (mounted) {
      setState(() => rawResult = result ?? 'canceled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          ElevatedButton(
            key: const Key('open-locked-dialog'),
            onPressed: _openLockedDialog,
            child: const Text('Open locked'),
          ),
          ElevatedButton(
            key: const Key('open-raw-dialog'),
            onPressed: _openRawDialog,
            child: const Text('Open raw'),
          ),
          Text('locked:$lockedResult'),
          Text('raw:$rawResult'),
        ],
      ),
    );
  }
}

class _PopupHarness extends StatefulWidget {
  const _PopupHarness();

  @override
  State<_PopupHarness> createState() => _PopupHarnessState();
}

class _PopupHarnessState extends State<_PopupHarness> {
  String selected = 'none';
  int canceled = 0;
  int disabledBuilds = 0;
  int? rawResult;

  Future<void> _showRawMenu() async {
    final int? result = await one_ui.showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(20, 80, 200, 200),
      items: const <one_ui.OneUIPopupMenuItem<int>>[
        one_ui.OneUIPopupMenuItem<int>(value: 42, child: Text('Forty two')),
      ],
    );
    if (mounted) {
      setState(() => rawResult = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          one_ui.OneUIPopupMenuButton<String>(
            key: const Key('custom-popup'),
            tooltip: 'Open custom menu',
            onSelected: (String value) => setState(() => selected = value),
            itemBuilder: (BuildContext context) =>
                const <one_ui.OneUIPopupMenuItem<String>>[
                  one_ui.OneUIPopupMenuItem<String>(
                    value: 'unavailable',
                    enabled: false,
                    child: Text('Unavailable'),
                  ),
                  one_ui.OneUIPopupMenuItem<String>(
                    value: 'chosen',
                    child: Text('Choose me'),
                  ),
                ],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Custom menu'),
            ),
          ),
          one_ui.OneUIPopupMenuButton<String>(
            key: const Key('icon-popup'),
            onCanceled: () => setState(() => canceled += 1),
            itemBuilder: (BuildContext context) =>
                const <one_ui.OneUIPopupMenuItem<String>>[
                  one_ui.OneUIPopupMenuItem<String>(
                    value: 'icon',
                    child: Text('Icon option'),
                  ),
                ],
          ),
          one_ui.OneUIPopupMenuButton<String>(
            key: const Key('disabled-popup'),
            enabled: false,
            itemBuilder: (BuildContext context) {
              disabledBuilds += 1;
              return const <one_ui.OneUIPopupMenuItem<String>>[
                one_ui.OneUIPopupMenuItem<String>(
                  value: 'impossible',
                  child: Text('Should not build'),
                ),
              ];
            },
          ),
          ElevatedButton(
            key: const Key('show-raw-menu'),
            onPressed: _showRawMenu,
            child: const Text('Show raw menu'),
          ),
          Text('selected:$selected'),
          Text('canceled:$canceled'),
          Text('disabled builds:$disabledBuilds'),
          Text('raw:${rawResult ?? 'none'}'),
        ],
      ),
    );
  }
}
