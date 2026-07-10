# one_ui_example

A Flutter application showcasing every public `one_ui` widget.

## Run the catalog

```shell
flutter pub get
flutter run
```

The catalog includes dedicated pages for app bars and views, bottom
navigation, buttons, dialogs, popup menus, switches, sliders, and ink effects.
Each interaction displays an observable status so it can be checked manually
and by the integration test.

## Test the catalog

Run the widget tests normally:

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
