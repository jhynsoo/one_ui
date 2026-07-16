# one_ui

This package provides an unofficial implementation of Samsung One UI for
[Flutter](https://flutter.dev).

[Explore the live widget catalog](https://jhynsoo.github.io/one_ui/).

| App Bar & View | Bottom Navigation |
| --- | --- |
| ![One UI app bar and expandable view in the light theme](https://raw.githubusercontent.com/jhynsoo/one_ui/master/screenshots/app-bar-and-view-light.png) | ![One UI bottom navigation in the dark theme](https://raw.githubusercontent.com/jhynsoo/one_ui/master/screenshots/bottom-navigation-dark.png) |
| Buttons | Alert Dialog |
| ![One UI buttons in the light theme](https://raw.githubusercontent.com/jhynsoo/one_ui/master/screenshots/buttons-light.png) | ![One UI alert dialog in the light theme](https://raw.githubusercontent.com/jhynsoo/one_ui/master/screenshots/alert-dialog-light.png) |

![One UI sliders in the dark theme](https://raw.githubusercontent.com/jhynsoo/one_ui/master/screenshots/sliders-dark.png)

## Requirements

- Flutter 3.35 or later
- Dart 3.9 or later

## Installation

Add `one_ui` to your application:

```yaml
dependencies:
  one_ui: ^0.4.1
```

Import the public library:

```dart
import 'package:one_ui/one_ui.dart';
```

The included example is a complete catalog of the public widgets and ink
effects. Run it with:

```shell
cd example
flutter run
```

## Development checks

Run the same package checks used by CI:

```shell
flutter pub get --no-example
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
dart run tool/check_coverage.dart --minimum 85
dart run tool/check_release.dart --expected-version 0.4.1
```

The example lockfile is generated with the minimum supported Flutter release.
Validate it from `example/` with `flutter pub get --enforce-lockfile` when using
Flutter 3.35.7.

## Resources

- [Samsung Developers | One UI Design Guidelines](https://developer.samsung.com/one-ui/index.html)
- [Samsung Design | One UI Design Guidelines](https://design.samsung.com/global/contents/one-ui/download/oneui_design_guide_eng.pdf)

## Color theme

One UI semantic colors are the default. No theme extension is required; widgets
select the official light or dark palette from the ambient
`ThemeData.brightness`:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
  ),
);
```

To use a custom or device-provided Material You palette, install that
`ColorScheme` on the app theme and explicitly opt in. Configure both the light
and dark themes when the app supports both brightness modes:

```dart
ThemeData materialYouTheme(ColorScheme colorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    extensions: const <ThemeExtension<dynamic>>[
      OneUIThemeData(colorMode: OneUIColorMode.materialYou),
    ],
  );
}

MaterialApp(
  theme: materialYouTheme(lightColorScheme),
  darkTheme: materialYouTheme(darkColorScheme),
);
```

`OneUISlider.useOneUIColor` and `OneUISwitch.useOneUIColor` are deprecated and
no longer select colors locally. Remove those arguments and configure
`OneUIThemeData.colorMode` once at the application theme level instead.
Custom components can use `OneUIColorScheme.of(context)` to resolve the same
semantic colors as the package widgets.

## Widgets

### App Bar

A One UI-style [app bar](https://api.flutter.dev/flutter/material/AppBar-class.html).

```dart
Scaffold(
  appBar: OneUIAppBar(
    title: const Text('Inbox'),
    actions: [
      OneUIIconButton(
        onPressed: () {},
        icon: const Icon(Icons.search),
      ),
    ],
  ),
);
```

### Bottom Navigation Bar

A One UI-style
[bottom navigation bar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html).

```dart
import 'package:flutter/material.dart';
import 'package:one_ui/one_ui.dart';

void main() {
  runApp(const BottomNavigationExample());
}

class BottomNavigationExample extends StatefulWidget {
  const BottomNavigationExample({super.key});

  @override
  State<BottomNavigationExample> createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Selected index: $_index')),
        bottomNavigationBar: OneUIBottomNavigationBar(
          currentIndex: _index,
          items: const [
            OneUIBottomNavigationBarItem(label: 'Home'),
            OneUIBottomNavigationBarItem(label: 'More'),
          ],
          onTap: (value) {
            setState(() {
              _index = value;
            });
          },
        ),
      ),
    );
  }
}
```

### Buttons

Buttons allow users to take actions or make choices with a single tap.
[Learn more](https://developer.samsung.com/one-ui/comp/button.html)

#### Back Button

An [icon button](#icon-button) with a back arrow that pops the current route by
default.

```dart
const OneUIBackButton();
```

#### Contained Button

A One UI-style
[elevated button](https://api.flutter.dev/flutter/material/ElevatedButton-class.html).

```dart
OneUIContainedButton(
  onPressed: () {},
  child: const Text('Contained button'),
);
```

#### Flat Button

A One UI-style [text button](https://api.flutter.dev/flutter/material/TextButton-class.html).

```dart
OneUIFlatButton(
  onPressed: () {},
  child: const Text('Flat button'),
);
```

#### Icon Button

A One UI-style [icon button](https://api.flutter.dev/flutter/material/IconButton-class.html).

```dart
OneUIIconButton(
  onPressed: () {},
  icon: const Icon(Icons.home),
);
```

### Dialogs

`showOneUIDialog` presents either a custom `OneUIDialog` or a One UI-style
`OneUIAlertDialog`.

```dart
ListTile(
  title: const Text('Show dialog'),
  onTap: () {
    showOneUIDialog<void>(
      context: context,
      builder: (context) {
        return OneUIAlertDialog(
          title: const Text('Title'),
          content: const Text('This is a demo alert dialog.'),
          actions: [
            OneUIDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            OneUIDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  },
);
```

### Popup Menu

A One UI-style
[popup menu button](https://api.flutter.dev/flutter/material/PopupMenuButton-class.html).
Use `buttonBuilder` when the menu needs a fully custom interactive trigger. For
imperative menus, import this package with a prefix and call `one_ui.showMenu`.

```dart
OneUIPopupMenuButton<String>(
  itemBuilder: (context) => const <OneUIPopupMenuItem<String>>[
    OneUIPopupMenuItem<String>(value: 'one', child: Text('Option 1')),
    OneUIPopupMenuItem<String>(value: 'two', child: Text('Option 2')),
    OneUIPopupMenuItem<String>(value: 'three', child: Text('Option 3')),
  ],
);
```

### Switch

A One UI-style [switch](https://api.flutter.dev/flutter/material/Switch-class.html).

```dart
OneUISwitch(
  value: _value,
  onChanged: (value) {
    setState(() {
      _value = value;
    });
  },
);
```

### Slider

A One UI-style [slider](https://api.flutter.dev/flutter/material/Slider-class.html).

```dart
import 'package:flutter/material.dart';
import 'package:one_ui/one_ui.dart';

void main() {
  runApp(const SliderExample());
}

class SliderExample extends StatefulWidget {
  const SliderExample({super.key});

  @override
  State<SliderExample> createState() => _SliderExampleState();
}

class _SliderExampleState extends State<SliderExample> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OneUISlider(
            value: _value,
            onChanged: (value) {
              setState(() {
                _value = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
```

### View

A One UI-style scroll view with a collapsible app bar. Exactly one of `child` or
`slivers` must be supplied.

```dart
@override
Widget build(BuildContext context) {
  return OneUIView(
    title: const Text('Title'),
    actionSpacing: 8,
    actions: [
      OneUIPopupMenuButton(
        itemBuilder: (context) => const <OneUIPopupMenuItem<String>>[
          OneUIPopupMenuItem<String>(value: 'one', child: Text('Option 1')),
          OneUIPopupMenuItem<String>(value: 'two', child: Text('Option 2')),
          OneUIPopupMenuItem<String>(value: 'three', child: Text('Option 3')),
        ],
      ),
    ],
    child: body,
  );
}
```

### Ink Effects

One UI buttons and popup menus use the package's ink effects automatically. To
apply one to other Material widgets, set it as the theme's `splashFactory`:

```dart
MaterialApp(
  theme: ThemeData(
    splashFactory: OneUIInkRipple.splashFactory,
  ),
);
```

`OneUIInkSplash.splashFactory` is also available for the expanding splash
variant.

## Acknowledgments

Thanks to [jja08111](https://github.com/jja08111) for
[one_ui_scroll_view](https://github.com/jja08111/one_ui_scroll_view).
