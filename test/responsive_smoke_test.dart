import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

import 'test_app.dart';

void main() {
  final List<_SmokeCase> cases = <_SmokeCase>[
    for (final Brightness brightness in Brightness.values)
      for (final TextDirection textDirection in TextDirection.values)
        for (final Size size in const <Size>[Size(390, 844), Size(1024, 768)])
          for (final double textScale in const <double>[1, 2])
            _SmokeCase(
              size: size,
              brightness: brightness,
              textDirection: textDirection,
              textScale: textScale,
            ),
  ];

  for (final _SmokeCase smokeCase in cases) {
    testWidgets('${smokeCase.name} renders without overflow or exceptions', (
      WidgetTester tester,
    ) async {
      setTestViewSize(tester, smokeCase.size);

      await tester.pumpWidget(
        TestApp(
          brightness: smokeCase.brightness,
          textDirection: smokeCase.textDirection,
          textScale: smokeCase.textScale,
          home: const _ResponsiveGallery(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(one_ui.OneUIView), findsOneWidget);
      expect(find.byType(one_ui.OneUIAppBar), findsOneWidget);
      expect(find.byType(one_ui.OneUIBottomNavigationBar), findsOneWidget);
      expect(find.byType(one_ui.OneUIBackButton), findsOneWidget);
      expect(find.byType(one_ui.OneUIContainedButton), findsOneWidget);
      expect(find.byType(one_ui.OneUIFlatButton), findsOneWidget);
      expect(find.byType(one_ui.OneUIIconButton), findsNWidgets(2));
      expect(find.byType(one_ui.OneUIPopupMenuButton<String>), findsOneWidget);
      expect(find.byType(one_ui.OneUISwitch), findsOneWidget);
      expect(find.byType(one_ui.OneUISlider), findsOneWidget);
      expectNoFlutterException(tester);

      final Finder popupButton = find.byKey(const Key('responsive-popup'));
      await tester.ensureVisible(popupButton);
      await tester.pumpAndSettle();
      await tester.tap(popupButton);
      await tester.pumpAndSettle();

      expect(find.byType(one_ui.OneUIPopupMenuItem<String>), findsOneWidget);
      expect(find.text('Popup item'), findsOneWidget);
      expectNoFlutterException(tester);

      await tester.tap(find.text('Popup item'));
      await tester.pumpAndSettle();
      expect(find.byType(one_ui.OneUIPopupMenuItem<String>), findsNothing);
      expectNoFlutterException(tester);

      final Finder rawDialogButton = find.byKey(
        const Key('open-responsive-raw-dialog'),
      );
      await tester.ensureVisible(rawDialogButton);
      await tester.pumpAndSettle();
      await tester.tap(rawDialogButton);
      await tester.pumpAndSettle();

      expect(find.byType(one_ui.OneUIDialog), findsOneWidget);
      expect(find.text('Responsive raw dialog'), findsOneWidget);
      expectNoFlutterException(tester);

      await tester.tap(find.byKey(const Key('close-responsive-raw-dialog')));
      await tester.pumpAndSettle();
      expect(find.byType(one_ui.OneUIDialog), findsNothing);
      expectNoFlutterException(tester);

      final Finder alertDialogButton = find.byKey(
        const Key('open-responsive-alert-dialog'),
      );
      await tester.ensureVisible(alertDialogButton);
      await tester.pumpAndSettle();
      await tester.tap(alertDialogButton);
      await tester.pumpAndSettle();

      expect(find.byType(one_ui.OneUIAlertDialog), findsOneWidget);
      expect(find.text('Responsive alert'), findsOneWidget);
      expectNoFlutterException(tester);

      await tester.tap(find.byKey(const Key('close-responsive-alert-dialog')));
      await tester.pumpAndSettle();
      expect(find.byType(one_ui.OneUIAlertDialog), findsNothing);
      expectNoFlutterException(tester);
    });
  }
}

class _ResponsiveGallery extends StatelessWidget {
  const _ResponsiveGallery();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: one_ui.OneUIView(
        title: const Text('Catalog'),
        largeTitle: const Text('One UI'),
        expandedHeight: 190,
        actions: <Widget>[
          one_ui.OneUIIconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: one_ui.OneUIBackButton(onPressed: () {}),
            ),
            one_ui.OneUIContainedButton(
              key: const Key('open-responsive-raw-dialog'),
              onPressed: () => _showRawDialog(context),
              child: const Text('Open raw dialog'),
            ),
            one_ui.OneUIFlatButton(
              key: const Key('open-responsive-alert-dialog'),
              onPressed: () => _showAlertDialog(context),
              child: const Text('Open alert dialog'),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: one_ui.OneUIPopupMenuButton<String>(
                key: const Key('responsive-popup'),
                itemBuilder: (BuildContext context) =>
                    const <one_ui.OneUIPopupMenuItem<String>>[
                      one_ui.OneUIPopupMenuItem<String>(
                        value: 'item',
                        child: Text('Popup item'),
                      ),
                    ],
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Popup'),
                ),
              ),
            ),
            one_ui.OneUISwitch(value: true, onChanged: (bool value) {}),
            one_ui.OneUISlider(value: 0.5, onChanged: (double value) {}),
            const SizedBox(height: 300),
          ],
        ),
      ),
      bottomNavigationBar: one_ui.OneUIBottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {},
        items: const <one_ui.OneUIBottomNavigationBarItem>[
          one_ui.OneUIBottomNavigationBarItem(label: 'Home'),
          one_ui.OneUIBottomNavigationBarItem(label: 'More'),
        ],
      ),
    );
  }

  void _showRawDialog(BuildContext context) {
    one_ui.showOneUIDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return one_ui.OneUIDialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Responsive raw dialog'),
                one_ui.OneUIFlatButton(
                  key: const Key('close-responsive-raw-dialog'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close raw dialog'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context) {
    one_ui.showOneUIDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return one_ui.OneUIAlertDialog(
          title: const Text('Responsive alert'),
          content: const Text('Alert dialog content'),
          actions: <one_ui.OneUIDialogAction>[
            one_ui.OneUIDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Close alert dialog',
                key: Key('close-responsive-alert-dialog'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmokeCase {
  const _SmokeCase({
    required this.size,
    required this.brightness,
    required this.textDirection,
    required this.textScale,
  });

  final Size size;
  final Brightness brightness;
  final TextDirection textDirection;
  final double textScale;

  String get name {
    final String brightnessName = brightness.name;
    final String directionName = textDirection.name.toUpperCase();
    final String dimensions = '${size.width.toInt()}x${size.height.toInt()}';
    final int percentScale = (textScale * 100).round();
    return '$brightnessName $directionName $dimensions at $percentScale percent text';
  }
}
