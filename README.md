# one_ui

Unofficial implementation of Samsung One UI for [Flutter](https://flutter.dev).

## Requirements

- Flutter 3.35 or later
- Dart 3.9 or later

## Installation

Add `one_ui` to your application:

```yaml
dependencies:
  one_ui: ^0.4.0
```

Import the public library:

```dart
import 'package:one_ui/one_ui.dart';
```

The included example is a complete catalog of the public widgets. Run it with:

```shell
cd example
flutter run
```

## Resources

- [Samsung Developers | One UI Design Guidelines](https://developer.samsung.com/one-ui/index.html)
- [Samsung Design | One UI Design Guidelines](https://design.samsung.com/global/contents/one-ui/download/oneui_design_guide_eng.pdf)

## Color theme

One UI semantic colors are the default. If `OneUIThemeData` is omitted, One UI
widgets use the official light or dark palette selected from the ambient
`ThemeData.brightness`:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      OneUIThemeData(),
    ],
  ),
)
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
)
```

`OneUISlider.useOneUIColor` and `OneUISwitch.useOneUIColor` are deprecated and
no longer select colors locally. Remove those arguments and configure
`OneUIThemeData.colorMode` once at the application theme level instead.

## Widgets

### Bottom Navigation Bar

An One UI style [bottom navigation bar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html).

- Example

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

Buttons allow users to take actions, and make choices, with a single tap. [Learn more](https://developer.samsung.com/one-ui/comp/button.html)

#### Back Button

[One UI Icon Button](#icon-button) with back icon.

- Example

```dart
OneUIBackButton()
```

#### Contained Button

An One UI style [Elevated Button](https://api.flutter.dev/flutter/material/ElevatedButton-class.html).

- Example

```dart
OneUIContainedButton(
  onPressed: () {},
  child: Text("Contained button"),
)
```

#### Flat Button

An One UI style [Text Button](https://api.flutter.dev/flutter/material/TextButton-class.html).

- Example

```dart
OneUIFlatButton(
  onPressed: () {},
  child: Text("Flat button"),
)
```

#### Icon Button

An One UI style [Icon Button](https://api.flutter.dev/flutter/material/IconButton-class.html).

- Example

```dart
OneUIIconButton(
  onPressed: () {},
  icon: Icon(Icons.home),
)
```

### Dialog

An One UI style [Alert Dialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html).

- Example

```dart
ListTile(
  title: Text("Show dialog"),
  onTap: () {
    showOneUIDialog(
      context: context,
      builder: (context) {
        return OneUIAlertDialog(
          title: Text("title"),
          content: Text("This is a demo alert dialog."),
          actions: [
            OneUIDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            OneUIDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Accept")
            ),
          ],
        );
      },
    );
  },
)
```

### Popup Menu

An One UI style [Popup Menu Button](https://api.flutter.dev/flutter/material/PopupMenuButton-class.html).

- Example

```dart
OneUIPopupMenuButton(
  itemBuilder: (context) => <PopupMenuEntry>[
    const OneUIPopupMenuItem(child: Text('Option 1')),
    const OneUIPopupMenuItem(child: Text('Option 2')),
    const OneUIPopupMenuItem(child: Text('Option 3')),
  ],
),
```

### Switch

An One UI Style [Switch](https://api.flutter.dev/flutter/material/Switch-class.html).

- Example

```dart
OneUISwitch(
  value: _value,
  onChanged: (value) {
    setState(() {
      _value = value;
    });
  },
)
```

### Slider

An One UI Style [Slider](https://api.flutter.dev/flutter/material/Slider-class.html).

- Example

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

An One UI Style scroll view.

- Example

```dart
@override
Widget build(BuildContext context) {
  return OneUIView(
    title: Text("Title"),
    actions: [
      OneUIPopupMenuButton(
        itemBuilder: (context) => <PopupMenuEntry>[
          const OneUIPopupMenuItem(child: Text('Option 1')),
          const OneUIPopupMenuItem(child: Text('Option 2')),
          const OneUIPopupMenuItem(child: Text('Option 3')),
        ],
      ),
    ],
    child: body,
  );
}
```

## Thanks to

[one_ui_scroll_view](https://github.com/jja08111/one_ui_scroll_view) by [jja08111](https://github.com/jja08111)
