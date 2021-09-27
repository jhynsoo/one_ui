import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_ui/src/effects/ink_ripple.dart';

const double _kMinButtonSize = kMinInteractiveDimension;

class OneUIIconButton extends IconButton {
  const OneUIIconButton({
    Key? key,
    double iconSize = 24.0,
    VisualDensity? visualDensity,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    Alignment alignment = Alignment.center,
    double? splashRadius,
    Color? color,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Color? disabledColor,
    required void Function()? onPressed,
    MouseCursor mouseCursor = SystemMouseCursors.click,
    FocusNode? focusNode,
    bool autofocus = false,
    String? tooltip,
    bool enableFeedback = true,
    BoxConstraints? constraints,
    required Widget icon,
  })  : assert(splashRadius == null || splashRadius > 0),
        super(
          key: key,
          iconSize: iconSize,
          visualDensity: visualDensity,
          padding: padding,
          alignment: alignment,
          splashRadius: splashRadius,
          color: color,
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          disabledColor: disabledColor,
          onPressed: onPressed,
          mouseCursor: mouseCursor,
          focusNode: focusNode,
          autofocus: autofocus,
          tooltip: tooltip,
          enableFeedback: enableFeedback,
          constraints: constraints,
          icon: icon,
        );

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    Color? currentColor;
    if (onPressed != null) {
      currentColor = color;
    } else {
      currentColor = disabledColor ?? theme.disabledColor;
    }

    final VisualDensity effectiveVisualDensity =
        visualDensity ?? theme.visualDensity;

    final BoxConstraints unadjustedConstraints = constraints ??
        const BoxConstraints(
          minWidth: _kMinButtonSize,
          minHeight: _kMinButtonSize,
        );
    final BoxConstraints adjustedConstraints =
        effectiveVisualDensity.effectiveConstraints(unadjustedConstraints);

    Widget result = ConstrainedBox(
      constraints: adjustedConstraints,
      child: Padding(
        padding: padding,
        child: SizedBox(
          height: iconSize,
          width: iconSize,
          child: Align(
            alignment: alignment,
            child: IconTheme.merge(
              data: IconThemeData(
                size: iconSize,
                color: currentColor,
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      result = Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: InkResponse(
        focusNode: focusNode,
        autofocus: autofocus,
        canRequestFocus: onPressed != null,
        onTap: onPressed,
        mouseCursor: mouseCursor,
        enableFeedback: enableFeedback,
        child: result,
        focusColor: focusColor ?? theme.focusColor,
        hoverColor: hoverColor ?? theme.hoverColor,
        highlightColor: highlightColor ?? Colors.transparent,
        splashColor: splashColor ?? theme.splashColor,
        splashFactory: OneUIInkRipple.splashFactory,
        radius: splashRadius ??
            math.max(
              Material.defaultSplashRadius,
              (iconSize + math.min(padding.horizontal, padding.vertical)) * 0.7,
              // x 0.5 for diameter -> radius and + 40% overflow derived from other Material apps.
            ),
      ),
    );
  }
}
