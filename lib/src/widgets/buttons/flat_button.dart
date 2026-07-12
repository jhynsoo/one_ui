import 'package:flutter/material.dart';
import 'package:one_ui/src/effects/ink_ripple.dart';
import 'package:one_ui/src/theme/theme.dart';

class OneUIFlatButton extends ButtonStyleButton {
  const OneUIFlatButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.none,
    required Widget super.child,
    this.useOneUISplashFactory = true,
  });

  final bool useOneUISplashFactory;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final OneUIColorScheme oneUIColorScheme = OneUIColorScheme.of(context);
    final InteractiveInkFeatureFactory splashFactory = useOneUISplashFactory
        ? OneUIInkRipple.splashFactory
        : theme.splashFactory;

    return TextButton.styleFrom(
      foregroundColor: oneUIColorScheme.primaryDark,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      shadowColor: theme.shadowColor,
      elevation: 0,
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

  /// Returns the [TextButtonThemeData.style] of the closest
  /// [TextButtonTheme] ancestor.
  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return TextButtonTheme.of(context).style;
  }
}

EdgeInsetsGeometry _scaledPadding(BuildContext context) {
  final double defaultFontSize =
      Theme.of(context).textTheme.labelLarge?.fontSize ?? 14.0;
  final double effectiveTextScale =
      MediaQuery.textScalerOf(context).scale(defaultFontSize) / defaultFontSize;
  return ButtonStyleButton.scaledPadding(
    const EdgeInsets.all(8),
    const EdgeInsets.symmetric(horizontal: 8),
    const EdgeInsets.symmetric(horizontal: 4),
    effectiveTextScale,
  );
}
