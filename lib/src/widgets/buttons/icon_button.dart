import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:one_ui/src/effects/ink_ripple.dart';

const double _kMinButtonSize = kMinInteractiveDimension;

class OneUIIconButton extends IconButton {
  const OneUIIconButton({
    super.key,
    super.iconSize,
    super.visualDensity,
    EdgeInsetsGeometry super.padding = const EdgeInsets.all(8.0),
    Alignment super.alignment = Alignment.center,
    super.splashRadius,
    super.color,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.splashColor,
    super.disabledColor,
    required super.onPressed,
    MouseCursor super.mouseCursor = SystemMouseCursors.click,
    super.focusNode,
    super.autofocus = false,
    super.tooltip,
    bool super.enableFeedback = true,
    super.constraints,
    required super.icon,
  }) : assert(splashRadius == null || splashRadius > 0);

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
    final EdgeInsetsGeometry effectivePadding =
        padding ?? const EdgeInsets.all(8.0);
    final AlignmentGeometry effectiveAlignment = alignment ?? Alignment.center;
    final MouseCursor effectiveMouseCursor =
        mouseCursor ?? SystemMouseCursors.click;
    final bool effectiveEnableFeedback = enableFeedback ?? true;

    final BoxConstraints unadjustedConstraints =
        constraints ??
        const BoxConstraints(
          minWidth: _kMinButtonSize,
          minHeight: _kMinButtonSize,
        );
    final BoxConstraints adjustedConstraints = effectiveVisualDensity
        .effectiveConstraints(unadjustedConstraints);
    final double effectiveIconSize =
        iconSize ?? IconTheme.of(context).size ?? 24.0;

    Widget result = ConstrainedBox(
      constraints: adjustedConstraints,
      child: Padding(
        padding: effectivePadding,
        child: SizedBox(
          height: effectiveIconSize,
          width: effectiveIconSize,
          child: Align(
            alignment: effectiveAlignment,
            child: IconTheme.merge(
              data: IconThemeData(size: effectiveIconSize, color: currentColor),
              child: icon,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      result = Tooltip(message: tooltip!, child: result);
    }

    return Semantics(
      button: true,
      enabled: onPressed != null,
      child: InkResponse(
        focusNode: focusNode,
        autofocus: autofocus,
        canRequestFocus: onPressed != null,
        onTap: onPressed,
        mouseCursor: effectiveMouseCursor,
        enableFeedback: effectiveEnableFeedback,
        focusColor: focusColor ?? theme.focusColor,
        hoverColor: hoverColor ?? theme.hoverColor,
        highlightColor: highlightColor ?? Colors.transparent,
        splashColor: splashColor ?? theme.splashColor,
        splashFactory: OneUIInkRipple.splashFactory,
        radius:
            splashRadius ??
            math.max(
              20,
              (effectiveIconSize +
                      math.min(
                        effectivePadding.horizontal,
                        effectivePadding.vertical,
                      )) *
                  0.5,
            ),
        child: result,
      ),
    );
  }
}
