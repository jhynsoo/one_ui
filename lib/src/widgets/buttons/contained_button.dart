import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:one_ui/src/effects/ink_ripple.dart';

class OneUIContainedButton extends ButtonStyleButton {
  const OneUIContainedButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    required Widget? child,
    this.useOneUISplashFactory = true,
  }) : super(child: child ?? const SizedBox.shrink());

  final bool useOneUISplashFactory;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final InteractiveInkFeatureFactory splashFactory = useOneUISplashFactory
        ? OneUIInkRipple.splashFactory
        : theme.splashFactory;

    return styleFrom(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      onSurface: colorScheme.onSurface,
      shadowColor: theme.shadowColor,
      elevation: 0.0,
      textStyle: theme.textTheme.labelLarge,
      padding: _scaledPadding(context),
      minimumSize: const Size(64, 36),
      maximumSize: Size.infinite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.basic,
      visualDensity: theme.visualDensity,
      tapTargetSize: theme.materialTapTargetSize,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: splashFactory,
    );
  }

  static ButtonStyle styleFrom({
    Color? primary,
    Color? onPrimary,
    Color? onSurface,
    Color? shadowColor,
    Color? surfaceTintColor,
    double? elevation,
    TextStyle? textStyle,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    Size? fixedSize,
    Size? maximumSize,
    BorderSide? side,
    OutlinedBorder? shape,
    MouseCursor? enabledMouseCursor,
    MouseCursor? disabledMouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    final WidgetStateProperty<Color?>? backgroundColor =
        (onSurface == null && primary == null)
        ? null
        : _ElevatedButtonDefaultBackground(primary, onSurface);
    final WidgetStateProperty<Color?>? foregroundColor =
        (onSurface == null && onPrimary == null)
        ? null
        : _ElevatedButtonDefaultForeground(onPrimary, onSurface);
    final WidgetStateProperty<Color?>? overlayColor = (onPrimary == null)
        ? null
        : _ElevatedButtonDefaultOverlay(onPrimary);
    final WidgetStateProperty<double>? elevationValue = (elevation == null)
        ? null
        : _ElevatedButtonDefaultElevation(elevation);
    final WidgetStateProperty<MouseCursor?>? mouseCursor =
        (enabledMouseCursor == null && disabledMouseCursor == null)
        ? null
        : _ElevatedButtonDefaultMouseCursor(
            enabledMouseCursor,
            disabledMouseCursor,
          );

    return ButtonStyle(
      textStyle: WidgetStatePropertyAll<TextStyle?>(textStyle),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      overlayColor: overlayColor,
      shadowColor: ButtonStyleButton.allOrNull<Color>(shadowColor),
      surfaceTintColor: ButtonStyleButton.allOrNull<Color>(surfaceTintColor),
      elevation: elevationValue,
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize),
      fixedSize: ButtonStyleButton.allOrNull<Size>(fixedSize),
      maximumSize: ButtonStyleButton.allOrNull<Size>(maximumSize),
      side: ButtonStyleButton.allOrNull<BorderSide>(side),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      mouseCursor: mouseCursor,
      visualDensity: visualDensity,
      tapTargetSize: tapTargetSize,
      animationDuration: animationDuration,
      enableFeedback: enableFeedback,
      alignment: alignment,
      splashFactory: splashFactory,
    );
  }

  /// Returns the [ElevatedButtonThemeData.style] of the closest
  /// [ElevatedButtonTheme] ancestor.
  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return ElevatedButtonTheme.of(context).style;
  }
}

EdgeInsetsGeometry _scaledPadding(BuildContext context) {
  final double defaultFontSize =
      Theme.of(context).textTheme.labelLarge?.fontSize ?? 14.0;
  final double effectiveTextScale =
      MediaQuery.textScalerOf(context).scale(defaultFontSize) / 14.0;
  return ButtonStyleButton.scaledPadding(
    const EdgeInsets.symmetric(horizontal: 16),
    const EdgeInsets.symmetric(horizontal: 8),
    const EdgeInsets.symmetric(horizontal: 4),
    effectiveTextScale,
  );
}

@immutable
class _ElevatedButtonDefaultBackground extends WidgetStateProperty<Color?>
    with Diagnosticable {
  _ElevatedButtonDefaultBackground(this.primary, this.onSurface);

  final Color? primary;
  final Color? onSurface;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return onSurface?.withValues(alpha: 0.12);
    }
    return primary;
  }
}

@immutable
class _ElevatedButtonDefaultForeground extends WidgetStateProperty<Color?>
    with Diagnosticable {
  _ElevatedButtonDefaultForeground(this.onPrimary, this.onSurface);

  final Color? onPrimary;
  final Color? onSurface;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return onSurface?.withValues(alpha: 0.38);
    }
    return onPrimary;
  }
}

@immutable
class _ElevatedButtonDefaultOverlay extends WidgetStateProperty<Color?>
    with Diagnosticable {
  _ElevatedButtonDefaultOverlay(this.onPrimary);

  final Color onPrimary;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.hovered)) {
      return onPrimary.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused) ||
        states.contains(WidgetState.pressed)) {
      return onPrimary.withValues(alpha: 0.24);
    }
    return null;
  }
}

@immutable
class _ElevatedButtonDefaultElevation extends WidgetStateProperty<double>
    with Diagnosticable {
  _ElevatedButtonDefaultElevation(this.elevation);

  final double elevation;

  @override
  double resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return 0;
    }
    return elevation;
  }
}

@immutable
class _ElevatedButtonDefaultMouseCursor
    extends WidgetStateProperty<MouseCursor?>
    with Diagnosticable {
  _ElevatedButtonDefaultMouseCursor(this.enabledCursor, this.disabledCursor);

  final MouseCursor? enabledCursor;
  final MouseCursor? disabledCursor;

  @override
  MouseCursor? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return disabledCursor;
    }
    return enabledCursor;
  }
}
