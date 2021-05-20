# one_ui

Unofficial implementation of Samsung One UI for [Flutter](https://flutter.dev).

## Resources

- [Samsung Developers | One UI Design Guidelines](https://developer.samsung.com/one-ui/index.html)
- [One UI Design Guidelines](https://design.samsung.com/global/contents/one-ui/download/oneui_design_guide_eng.pdf)

## Widgets

### Bottom Navigation Bar

An One UI style [bottom navigation bar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html).

- Example

```dart
Scaffold(
  bottomNavigationBar: OneUIBottomNavigationBar(
    currentIndex: _index,
    onTap: (value) {
      setState(() {
        _index = value;
      });
    },
  ),
)
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
OneUISlider(
  value: _value,
  onChanged: (value)
)
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
    children: body,
  );
}
```

## Thanks to

[one_ui_scroll_view](https://github.com/jja08111/one_ui_scroll_view) by [jja08111](https://github.com/jja08111)
