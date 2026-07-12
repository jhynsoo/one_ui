# one_ui_example

A Flutter app that demonstrates every public `one_ui` widget and ink effect.

Run all commands below from the `example` directory.

## Run the catalog

```shell
flutter pub get
flutter run
```

The catalog includes dedicated pages for app bars and views, bottom
navigation, buttons, dialogs, popup menus, switches, sliders, and ink effects.
Each interaction displays an observable status so it can be checked manually
and by the integration test.

The color controls switch between light and dark themes and between the built-in
One UI palette and Material You. Material You uses the device's dynamic colors
when available, with a configurable seeded `ColorScheme` fallback.

## Test the catalog

To run the widget tests:

```shell
flutter test
```

For the web integration test, start ChromeDriver in the first terminal and
leave it running:

```shell
chromedriver --port=4444
```

Then run the catalog flow from the `example` directory in a second terminal:

```shell
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/widget_catalog_test.dart \
  -d web-server \
  --browser-name=chrome \
  --release
```

The Chrome flow requires a matching ChromeDriver on `PATH`. The Flutter
[integration-testing guide](https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser)
documents how to install it with `@puppeteer/browsers`.
