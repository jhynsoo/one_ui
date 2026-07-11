import 'package:flutter/material.dart';

/// Selects how One UI widgets resolve their semantic colors.
enum OneUIColorMode {
  /// Uses the semantic colors from Samsung's One UI color system.
  oneUI,

  /// Uses the ambient Material [ColorScheme].
  materialYou,
}

/// Theme configuration shared by One UI widgets.
@immutable
final class OneUIThemeData extends ThemeExtension<OneUIThemeData> {
  const OneUIThemeData({this.colorMode = OneUIColorMode.oneUI});

  /// The color source used by One UI widgets.
  final OneUIColorMode colorMode;

  /// Returns the nearest One UI theme configuration.
  ///
  /// One UI colors are used when no extension has been installed on the
  /// ambient [ThemeData].
  static OneUIThemeData of(BuildContext context) {
    return Theme.of(context).extension<OneUIThemeData>() ??
        const OneUIThemeData();
  }

  @override
  OneUIThemeData copyWith({OneUIColorMode? colorMode}) {
    return OneUIThemeData(colorMode: colorMode ?? this.colorMode);
  }

  @override
  OneUIThemeData lerp(covariant OneUIThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return OneUIThemeData(colorMode: t < 0.5 ? colorMode : other.colorMode);
  }
}

/// Semantic colors defined by Samsung's One UI color system.
///
/// See <https://developer.samsung.com/one-ui/color/system.html>.
@immutable
final class OneUIColorScheme {
  const OneUIColorScheme._({
    required this.primaryDark,
    required this.primary,
    required this.controlActivated,
  });

  /// The official One UI semantic colors for light themes.
  static const OneUIColorScheme light = OneUIColorScheme._(
    primaryDark: Color(0xff0072de),
    primary: Color(0xff0381fe),
    controlActivated: Color(0xff3e91ff),
  );

  /// The official One UI semantic colors for dark themes.
  static const OneUIColorScheme dark = OneUIColorScheme._(
    primaryDark: Color(0xff3e91ff),
    primary: Color(0xff0381fe),
    controlActivated: Color(0xff3e91ff),
  );

  /// Resolves the semantic colors for the ambient theme and One UI mode.
  ///
  /// In [OneUIColorMode.materialYou], every One UI accent role resolves to the
  /// ambient [ColorScheme.primary]. Otherwise, the official light or dark One
  /// UI palette is returned.
  static OneUIColorScheme of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (OneUIThemeData.of(context).colorMode == OneUIColorMode.materialYou) {
      final Color primary = theme.colorScheme.primary;
      return OneUIColorScheme._(
        primaryDark: primary,
        primary: primary,
        controlActivated: primary,
      );
    }
    return theme.brightness == Brightness.dark ? dark : light;
  }

  /// High-emphasis backgrounds and secondary action text.
  final Color primaryDark;

  /// Primary accents such as sliders and floating action buttons.
  final Color primary;

  /// The active color for selection controls.
  final Color controlActivated;
}
