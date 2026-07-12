import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestApp extends StatelessWidget {
  const TestApp({
    super.key,
    required this.home,
    this.brightness = Brightness.light,
    this.textDirection = TextDirection.ltr,
    this.textScale = 1.0,
  });

  final Widget home;
  final Brightness brightness;
  final TextDirection textDirection;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness, useMaterial3: true),
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mediaQuery = MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale));
        return MediaQuery(
          data: mediaQuery,
          child: Directionality(textDirection: textDirection, child: child!),
        );
      },
      home: home,
    );
  }
}

void setTestViewSize(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

void expectNoFlutterException(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
