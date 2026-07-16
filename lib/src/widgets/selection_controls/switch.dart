import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

const double _kTrackHeight = 16.0;
const double _kTrackBorderHeight = _kTrackHeight + 1.0;
const double _kTrackWidth = 33.0;
const double _kTrackRadius = _kTrackHeight / 2.0;
const double _kTrackBorderRadius = _kTrackBorderHeight / 2.0;
const double _kThumbRadius = 10.0;
const double _kSwitchMinSize = kMinInteractiveDimension - 8.0;
const double _kSwitchWidth = _kTrackWidth - 2 * _kTrackRadius + _kSwitchMinSize;
const double _kSwitchHeight = _kSwitchMinSize + 8.0;
const double _kSwitchHeightCollapsed = _kSwitchMinSize;

class OneUISwitch extends StatefulWidget {
  /// Creates a One UI-style switch.
  ///
  /// The switch itself does not maintain any state. Instead, when the state of
  /// the switch changes, the widget calls the [onChanged] callback. Most widgets
  /// that use a switch will listen for the [onChanged] callback and rebuild the
  /// switch with a new [value] to update the visual appearance of the switch.
  ///
  /// The following arguments are required:
  ///
  /// * [value] determines whether this switch is on or off.
  /// * [onChanged] is called when the user toggles the switch on or off.
  const OneUISwitch({
    super.key,
    required this.value,
    required this.onChanged,
    @Deprecated(
      'Use OneUIThemeData.colorMode instead. This parameter is ignored.',
    )
    this.useOneUIColor = false,
    this.activeColor,
    this.disabledThumbColor,
    this.activeThumbImage,
    this.onActiveThumbImageError,
    this.inactiveThumbImage,
    this.onInactiveThumbImageError,
    this.thumbColor,
    this.trackColor,
    this.thumbBorderColor,
    this.trackBorderColor,
    this.materialTapTargetSize,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.overlayColor,
    this.splashRadius,
    this.focusNode,
    this.autofocus = false,
  }) : assert(activeThumbImage != null || onActiveThumbImageError == null),
       assert(inactiveThumbImage != null || onInactiveThumbImageError == null);

  /// Whether this switch is on or off.
  ///
  final bool value;

  /// Called when the user toggles the switch on or off.
  ///
  /// The switch passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the switch with the new
  /// value.
  ///
  /// If null, the switch will be displayed as disabled.
  ///
  /// The callback provided to [onChanged] should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt.
  final ValueChanged<bool>? onChanged;

  /// This parameter is retained for source compatibility and is ignored.
  ///
  /// Configure [OneUIThemeData.colorMode] on the ambient [ThemeData] instead.
  @Deprecated(
    'Use OneUIThemeData.colorMode instead. This parameter is ignored.',
  )
  final bool useOneUIColor;

  /// The color to use when this switch is on.
  ///
  /// Defaults to the active color resolved from [OneUIThemeData.colorMode].
  ///
  /// If [trackColor] returns a non-null color in the [WidgetState.selected]
  /// state, it will be used instead of this color.
  final Color? activeColor;

  /// The color to use on the thumb when this switch is disabled.
  ///
  /// Used when [thumbColor] is null. If this is also null,
  /// [SwitchThemeData.thumbColor] is used before falling back to
  /// `Color(0xff828282)` in a dark theme or `Color(0xfffafafa)` in a light theme.
  final Color? disabledThumbColor;

  /// An image to use on the thumb of this switch when the switch is on.
  final ImageProvider? activeThumbImage;

  /// An optional error callback for errors emitted when loading
  /// [activeThumbImage].
  final ImageErrorListener? onActiveThumbImageError;

  /// An image to use on the thumb of this switch when the switch is off.
  final ImageProvider? inactiveThumbImage;

  /// An optional error callback for errors emitted when loading
  /// [inactiveThumbImage].
  final ImageErrorListener? onInactiveThumbImageError;

  /// The color of this [OneUISwitch]'s thumb in every state.
  ///
  /// If null, a disabled switch uses [disabledThumbColor], then
  /// [SwitchThemeData.thumbColor], then the built-in light or dark default. An
  /// enabled switch uses the theme thumb color, falling back to [Colors.white].
  final Color? thumbColor;

  /// The state-dependent color of this [OneUISwitch]'s track.
  ///
  /// Resolved in the following states:
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// A color resolved from this property takes precedence over every fallback.
  /// Otherwise, the following colors are used:
  ///
  /// * Selected and enabled: [activeColor], then
  ///   [SwitchThemeData.trackColor], then the active semantic One UI color.
  /// * Unselected and enabled: [SwitchThemeData.trackColor], then
  ///   [Colors.transparent].
  /// * Selected and disabled: [SwitchThemeData.trackColor], then
  ///   [Colors.black12] in a light theme or [Colors.white10] in a dark theme.
  /// * Unselected and disabled: [SwitchThemeData.trackColor], then
  ///   [Colors.transparent].
  final WidgetStateProperty<Color?>? trackColor;

  /// The state-dependent color of this [OneUISwitch]'s thumb border.
  ///
  /// Resolved in the following states:
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If null, a selected and enabled switch uses [activeColor] or the semantic
  /// One UI active color. An unselected and enabled switch uses
  /// `Color(0x52000000)` in a light theme or [Colors.white30] in a dark theme.
  /// A disabled switch uses [Colors.black12] in a light theme or
  /// [Colors.white10] in a dark theme.
  final WidgetStateProperty<Color?>? thumbBorderColor;

  /// The state-dependent color of this [OneUISwitch]'s track border.
  ///
  /// Resolved in the following states:
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If null, selected switches use [Colors.transparent], including when
  /// disabled. An enabled, unselected switch uses `Color(0x52000000)` in a
  /// light theme or [Colors.white30] in a dark theme. A disabled, unselected
  /// switch uses [Colors.black12] in a light theme or [Colors.white10] in a
  /// dark theme.
  final WidgetStateProperty<Color?>? trackBorderColor;

  /// Configures the minimum size of the tap target.
  ///
  /// If null, then the value of [SwitchThemeData.materialTapTargetSize] is
  /// used. If that is also null, then the value of
  /// [ThemeData.materialTapTargetSize] is used.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// {@macro flutter.cupertino.CupertinoSwitch.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [WidgetStateProperty<MouseCursor>],
  /// [WidgetStateProperty.resolve] is used for the following [WidgetState]s:
  ///
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///  * [WidgetState.disabled].
  ///
  /// If null, then the value of [SwitchThemeData.mouseCursor] is used. If that
  /// is also null, then [WidgetStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The color of the switch's ink response when it has input focus.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.focused]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// focused state. If that is also null, then the value of
  /// [ThemeData.focusColor] is used.
  final Color? focusColor;

  /// The color of the switch's ink response when a pointer is hovering over it.
  ///
  /// If [overlayColor] returns a non-null color in the [WidgetState.hovered]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// hovered state. If that is also null, then the value of
  /// [ThemeData.hoverColor] is used.
  final Color? hoverColor;

  /// The state-dependent color of the switch's ink response.
  ///
  /// Resolves in the following states:
  ///  * [WidgetState.pressed].
  ///  * [WidgetState.selected].
  ///  * [WidgetState.hovered].
  ///  * [WidgetState.focused].
  ///
  /// For pressed states, the fallback order is
  /// [SwitchThemeData.overlayColor] followed by the resolved track color with
  /// [kRadialReactionAlpha]. Focused and hovered states use [focusColor] or
  /// [hoverColor], then [SwitchThemeData.overlayColor], then the corresponding
  /// [ThemeData.focusColor] or [ThemeData.hoverColor].
  final WidgetStateProperty<Color?>? overlayColor;

  /// The splash radius of the circular [Material] ink response.
  ///
  /// If null, then the value of [SwitchThemeData.splashRadius] is used. If that
  /// is also null, then [kRadialReactionRadius] is used.
  final double? splashRadius;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  @override
  State<OneUISwitch> createState() => _OneUISwitchState();
}

class _OneUISwitchState extends State<OneUISwitch>
    with TickerProviderStateMixin, ToggleableStateMixin {
  Size _getSwitchSize(ThemeData theme) {
    final MaterialTapTargetSize effectiveMaterialTapTargetSize =
        widget.materialTapTargetSize ??
        theme.switchTheme.materialTapTargetSize ??
        theme.materialTapTargetSize;
    switch (effectiveMaterialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        return const Size(_kSwitchWidth, _kSwitchHeight);
      case MaterialTapTargetSize.shrinkWrap:
        return const Size(_kSwitchWidth, _kSwitchHeightCollapsed);
    }
  }

  final _SwitchPainter _painter = _SwitchPainter();

  @override
  void didUpdateWidget(OneUISwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // During a drag we may have modified the curve. Reset it when possible
      // to do without visual discontinuation.
      if (position.value == 0.0 || position.value == 1.0) {
        position
          ..curve = Curves.easeOutBack
          ..reverseCurve = Curves.easeInBack;
      }
      animateToValue();
    }
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  ValueChanged<bool?>? get onChanged =>
      widget.onChanged != null ? _handleChanged : null;

  @override
  bool get tristate => false;

  @override
  bool? get value => widget.value;

  WidgetStateProperty<Color> get _thumbColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return widget.disabledThumbColor ??
            (isDark ? const Color(0xff828282) : const Color(0xfffafafa));
      }
      return Colors.white;
    });
  }

  WidgetStateProperty<Color> get _trackColor {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final OneUIColorScheme oneUIColorScheme = OneUIColorScheme.of(context);

    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        final Color? themedColor = theme.switchTheme.trackColor?.resolve(
          states,
        );
        if (themedColor != null) {
          return themedColor;
        }
        if (states.contains(WidgetState.selected)) {
          return isDark ? Colors.white10 : Colors.black12;
        }
        return Colors.transparent;
      }
      if (states.contains(WidgetState.selected)) {
        return widget.activeColor ??
            theme.switchTheme.trackColor?.resolve(states) ??
            oneUIColorScheme.controlActivated;
      }
      return theme.switchTheme.trackColor?.resolve(states) ??
          Colors.transparent;
    });
  }

  WidgetStateProperty<Color> get _thumbBorderColor {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color black32 = Color(0x52000000);

    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return isDark ? Colors.white10 : Colors.black12;
      }
      if (states.contains(WidgetState.selected)) {
        return widget.activeColor ??
            OneUIColorScheme.of(context).controlActivated;
      }
      return isDark ? Colors.white30 : black32;
    });
  }

  WidgetStateProperty<Color> get _trackBorderColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color black32 = Color(0x52000000);

    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.disabled)) {
        return isDark ? Colors.white10 : Colors.black12;
      }
      return isDark ? Colors.white30 : black32;
    });
  }

  double get _trackInnerLength =>
      _getSwitchSize(Theme.of(context)).width - _kSwitchMinSize;

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) reactionController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      position
        ..curve = Curves.linear
        ..reverseCurve = null;
      final double delta = details.primaryDelta! / _trackInnerLength;
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          positionController.value -= delta;
          break;
        case TextDirection.ltr:
          positionController.value += delta;
          break;
      }
    }
  }

  bool _needsPositionAnimation = false;

  void _handleDragEnd(DragEndDetails details) {
    if (position.value >= 0.5 != widget.value) {
      widget.onChanged!(!widget.value);
      // Wait with finishing the animation until widget.value has changed to
      // !widget.value as part of the widget.onChanged call above.
      setState(() {
        _needsPositionAnimation = true;
      });
    } else {
      animateToValue();
    }
    reactionController.reverse();
  }

  void _handleChanged(bool? value) {
    assert(value != null);
    assert(widget.onChanged != null);
    widget.onChanged!(value!);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    if (_needsPositionAnimation) {
      _needsPositionAnimation = false;
      animateToValue();
    }

    final ThemeData theme = Theme.of(context);

    // Resolve colors separately for selected and unselected states
    // so that they can be lerped between.
    final Set<WidgetState> activeStates = states..add(WidgetState.selected);
    final Set<WidgetState> inactiveStates = states
      ..remove(WidgetState.selected);
    final Color effectiveThumbColor =
        widget.thumbColor ??
        (states.contains(WidgetState.disabled)
            ? widget.disabledThumbColor
            : null) ??
        theme.switchTheme.thumbColor?.resolve(states) ??
        _thumbColor.resolve(states);
    final Color effectiveActiveTrackColor =
        widget.trackColor?.resolve(activeStates) ??
        _trackColor.resolve(activeStates);
    final Color effectiveInactiveTrackColor =
        widget.trackColor?.resolve(inactiveStates) ??
        _trackColor.resolve(inactiveStates);

    final Color effectiveActiveThumbBorderColor =
        widget.thumbBorderColor?.resolve(activeStates) ??
        _thumbBorderColor.resolve(activeStates);
    final Color effectiveInactiveThumbBorderColor =
        widget.thumbBorderColor?.resolve(inactiveStates) ??
        _thumbBorderColor.resolve(inactiveStates);

    final Color effectiveActiveTrackBorderColor =
        widget.trackBorderColor?.resolve(activeStates) ??
        _trackBorderColor.resolve(activeStates);
    final Color effectiveInactiveTrackBorderColor =
        widget.trackBorderColor?.resolve(inactiveStates) ??
        _trackBorderColor.resolve(inactiveStates);

    final Set<WidgetState> focusedStates = states..add(WidgetState.focused);
    final Color effectiveFocusOverlayColor =
        widget.overlayColor?.resolve(focusedStates) ??
        widget.focusColor ??
        theme.switchTheme.overlayColor?.resolve(focusedStates) ??
        theme.focusColor;

    final Set<WidgetState> hoveredStates = states..add(WidgetState.hovered);
    final Color effectiveHoverOverlayColor =
        widget.overlayColor?.resolve(hoveredStates) ??
        widget.hoverColor ??
        theme.switchTheme.overlayColor?.resolve(hoveredStates) ??
        theme.hoverColor;

    final Set<WidgetState> activePressedStates = activeStates
      ..add(WidgetState.pressed);
    final Color effectiveActivePressedOverlayColor =
        widget.overlayColor?.resolve(activePressedStates) ??
        theme.switchTheme.overlayColor?.resolve(activePressedStates) ??
        effectiveActiveTrackColor.withAlpha(kRadialReactionAlpha);

    final Set<WidgetState> inactivePressedStates = inactiveStates
      ..add(WidgetState.pressed);
    final Color effectiveInactivePressedOverlayColor =
        widget.overlayColor?.resolve(inactivePressedStates) ??
        theme.switchTheme.overlayColor?.resolve(inactivePressedStates) ??
        effectiveActiveTrackColor.withAlpha(kRadialReactionAlpha);

    final WidgetStateProperty<MouseCursor> effectiveMouseCursor =
        WidgetStateProperty.resolveWith<MouseCursor>((Set<WidgetState> states) {
          return WidgetStateProperty.resolveAs<MouseCursor?>(
                widget.mouseCursor,
                states,
              ) ??
              theme.switchTheme.mouseCursor?.resolve(states) ??
              WidgetStateProperty.resolveAs<MouseCursor>(
                WidgetStateMouseCursor.clickable,
                states,
              );
        });

    return Semantics(
      toggled: widget.value,
      child: GestureDetector(
        excludeFromSemantics: true,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        dragStartBehavior: widget.dragStartBehavior,
        child: buildToggleable(
          mouseCursor: effectiveMouseCursor,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          size: _getSwitchSize(theme),
          painter: _painter
            ..value = value!
            ..position = position
            ..reaction = reaction
            ..reactionFocusFade = reactionFocusFade
            ..reactionHoverFade = reactionHoverFade
            ..inactiveReactionColor = effectiveInactivePressedOverlayColor
            ..reactionColor = effectiveActivePressedOverlayColor
            ..hoverColor = effectiveHoverOverlayColor
            ..focusColor = effectiveFocusOverlayColor
            ..splashRadius =
                widget.splashRadius ??
                theme.switchTheme.splashRadius ??
                kRadialReactionRadius
            ..downPosition = downPosition
            ..isFocused = states.contains(WidgetState.focused)
            ..isHovered = states.contains(WidgetState.hovered)
            ..activeColor = effectiveActiveTrackColor
            ..inactiveColor = effectiveInactiveTrackColor
            ..thumbColor = effectiveThumbColor
            ..activeThumbBorderColor = effectiveActiveThumbBorderColor
            ..inactiveThumbBorderColor = effectiveInactiveThumbBorderColor
            ..activeTrackBorderColor = effectiveActiveTrackBorderColor
            ..inactiveTrackBorderColor = effectiveInactiveTrackBorderColor
            ..activeThumbImage = widget.activeThumbImage
            ..onActiveThumbImageError = widget.onActiveThumbImageError
            ..inactiveThumbImage = widget.inactiveThumbImage
            ..onInactiveThumbImageError = widget.onInactiveThumbImageError
            ..activeTrackColor = effectiveActiveTrackColor
            ..inactiveTrackColor = effectiveInactiveTrackColor
            ..configuration = createLocalImageConfiguration(context)
            ..isInteractive = isInteractive
            ..trackInnerLength = _trackInnerLength
            ..textDirection = Directionality.of(context)
            ..surfaceColor = theme.colorScheme.surface,
        ),
      ),
    );
  }
}

class _SwitchPainter extends ToggleablePainter {
  bool get value => _value!;
  bool? _value;
  set value(bool value) {
    if (value == _value) return;
    _value = value;
    notifyListeners();
  }

  ImageProvider? get activeThumbImage => _activeThumbImage;
  ImageProvider? _activeThumbImage;
  set activeThumbImage(ImageProvider? value) {
    if (value == _activeThumbImage) return;
    _activeThumbImage = value;
    notifyListeners();
  }

  ImageErrorListener? get onActiveThumbImageError => _onActiveThumbImageError;
  ImageErrorListener? _onActiveThumbImageError;
  set onActiveThumbImageError(ImageErrorListener? value) {
    if (value == _onActiveThumbImageError) {
      return;
    }
    _onActiveThumbImageError = value;
    notifyListeners();
  }

  ImageProvider? get inactiveThumbImage => _inactiveThumbImage;
  ImageProvider? _inactiveThumbImage;
  set inactiveThumbImage(ImageProvider? value) {
    if (value == _inactiveThumbImage) return;
    _inactiveThumbImage = value;
    notifyListeners();
  }

  ImageErrorListener? get onInactiveThumbImageError =>
      _onInactiveThumbImageError;
  ImageErrorListener? _onInactiveThumbImageError;
  set onInactiveThumbImageError(ImageErrorListener? value) {
    if (value == _onInactiveThumbImageError) {
      return;
    }
    _onInactiveThumbImageError = value;
    notifyListeners();
  }

  Color get thumbColor => _thumbColor!;
  Color? _thumbColor;
  set thumbColor(Color value) {
    if (value == _thumbColor) return;
    _thumbColor = value;
    notifyListeners();
  }

  Color get activeTrackColor => _activeTrackColor!;
  Color? _activeTrackColor;
  set activeTrackColor(Color value) {
    if (value == _activeTrackColor) return;
    _activeTrackColor = value;
    notifyListeners();
  }

  Color get inactiveTrackColor => _inactiveTrackColor!;
  Color? _inactiveTrackColor;
  set inactiveTrackColor(Color value) {
    if (value == _inactiveTrackColor) return;
    _inactiveTrackColor = value;
    notifyListeners();
  }

  Color get activeThumbBorderColor => _activeThumbBorderColor!;
  Color? _activeThumbBorderColor;
  set activeThumbBorderColor(Color value) {
    if (value == _activeThumbBorderColor) return;
    _activeThumbBorderColor = value;
    notifyListeners();
  }

  Color get inactiveThumbBorderColor => _inactiveThumbBorderColor!;
  Color? _inactiveThumbBorderColor;
  set inactiveThumbBorderColor(Color value) {
    if (value == _inactiveThumbBorderColor) return;
    _inactiveThumbBorderColor = value;
    notifyListeners();
  }

  Color get activeTrackBorderColor => _activeTrackBorderColor!;
  Color? _activeTrackBorderColor;
  set activeTrackBorderColor(Color value) {
    if (value == _activeTrackBorderColor) return;
    _activeTrackBorderColor = value;
    notifyListeners();
  }

  Color get inactiveTrackBorderColor => _inactiveTrackBorderColor!;
  Color? _inactiveTrackBorderColor;
  set inactiveTrackBorderColor(Color value) {
    if (value == _inactiveTrackBorderColor) return;
    _inactiveTrackBorderColor = value;
    notifyListeners();
  }

  ImageConfiguration get configuration => _configuration!;
  ImageConfiguration? _configuration;
  set configuration(ImageConfiguration value) {
    if (value == _configuration) return;
    _configuration = value;
    notifyListeners();
  }

  TextDirection get textDirection => _textDirection!;
  TextDirection? _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    notifyListeners();
  }

  Color get surfaceColor => _surfaceColor!;
  Color? _surfaceColor;
  set surfaceColor(Color value) {
    if (value == _surfaceColor) return;
    _surfaceColor = value;
    notifyListeners();
  }

  bool get isInteractive => _isInteractive!;
  bool? _isInteractive;
  set isInteractive(bool value) {
    if (value == _isInteractive) {
      return;
    }
    _isInteractive = value;
    notifyListeners();
  }

  double get trackInnerLength => _trackInnerLength!;
  double? _trackInnerLength;
  set trackInnerLength(double value) {
    if (value == _trackInnerLength) {
      return;
    }
    _trackInnerLength = value;
    notifyListeners();
  }

  bool? _cachedValue;
  Color? _cachedThumbColor;
  Color? _cachedThumbBorderColor;
  ImageProvider? _cachedThumbImage;
  ImageErrorListener? _cachedThumbErrorListener;
  BoxPainter? _cachedThumbPainter;

  BoxDecoration _createDefaultThumbDecoration(
    Color color,
    Color borderColor,
    ImageProvider? image,
    ImageErrorListener? errorListener,
  ) {
    return BoxDecoration(
      color: color,
      image: image == null
          ? null
          : DecorationImage(image: image, onError: errorListener),
      shape: BoxShape.circle,
      border: Border.all(color: borderColor),
    );
  }

  bool _isPainting = false;

  void _handleDecorationChanged() {
    // If the image decoration is available synchronously, we'll get called here
    // during paint. There's no reason to mark ourselves as needing paint if we
    // are already in the middle of painting. (In fact, doing so would trigger
    // an assert).
    if (!_isPainting) notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bool isEnabled = isInteractive;
    final double currentValue = position.value;

    final double visualPosition;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - currentValue;
        break;
      case TextDirection.ltr:
        visualPosition = currentValue;
        break;
    }

    final Color trackColor = Color.lerp(
      inactiveTrackColor,
      activeTrackColor,
      currentValue,
    )!;
    final Color trackBorderColor = Color.lerp(
      inactiveTrackBorderColor,
      activeTrackBorderColor,
      currentValue,
    )!;
    final Color thumbBorderColor = value
        ? activeThumbBorderColor
        : inactiveThumbBorderColor;

    // Blend the thumb color against a `surfaceColor` background in case the

    final ImageProvider? thumbImage = isEnabled
        ? (currentValue < 0.5 ? inactiveThumbImage : activeThumbImage)
        : inactiveThumbImage;

    final ImageErrorListener? thumbErrorListener = isEnabled
        ? (currentValue < 0.5
              ? onInactiveThumbImageError
              : onActiveThumbImageError)
        : onInactiveThumbImageError;

    // Paint the track
    final Paint paint = Paint()..color = trackColor;
    final Paint borderPaint = Paint()
      ..color = trackBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    const double trackHorizontalPadding = kRadialReactionRadius - _kTrackRadius;
    final Rect trackRect = Rect.fromLTWH(
      trackHorizontalPadding,
      (size.height - _kTrackHeight) / 2.0,
      size.width - 2.0 * trackHorizontalPadding,
      _kTrackHeight,
    );
    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      const Radius.circular(_kTrackRadius),
    );
    final Rect trackBorderRect = Rect.fromLTWH(
      trackHorizontalPadding - .5,
      (size.height - _kTrackBorderHeight) / 2.0,
      size.width - 2.0 * trackHorizontalPadding + 1.0,
      _kTrackHeight + 1.0,
    );
    final RRect trackBorderRRect = RRect.fromRectAndRadius(
      trackBorderRect,
      const Radius.circular(_kTrackBorderRadius),
    );
    canvas.drawRRect(trackBorderRRect, borderPaint);
    canvas.drawRRect(trackRRect, paint);

    final Offset thumbPosition = Offset(
      kRadialReactionRadius + visualPosition * trackInnerLength,
      size.height / 2.0,
    );

    paintRadialReaction(canvas: canvas, origin: thumbPosition);

    try {
      _isPainting = true;
      if (_cachedThumbPainter == null ||
          value != _cachedValue ||
          thumbColor != _cachedThumbColor ||
          thumbBorderColor != _cachedThumbBorderColor ||
          thumbImage != _cachedThumbImage ||
          thumbErrorListener != _cachedThumbErrorListener) {
        _cachedValue = value;
        _cachedThumbColor = thumbColor;
        _cachedThumbBorderColor = thumbBorderColor;
        _cachedThumbImage = thumbImage;
        _cachedThumbErrorListener = thumbErrorListener;
        _cachedThumbPainter?.dispose();
        _cachedThumbPainter = _createDefaultThumbDecoration(
          thumbColor,
          thumbBorderColor,
          thumbImage,
          thumbErrorListener,
        ).createBoxPainter(_handleDecorationChanged);
      }
      final BoxPainter thumbPainter = _cachedThumbPainter!;

      // The thumb contracts slightly during the animation
      final double inset = 1.0 - (currentValue - 0.5).abs() * 2.0;
      final double radius = _kThumbRadius - inset;
      thumbPainter.paint(
        canvas,
        thumbPosition - Offset(radius, radius),
        configuration.copyWith(size: Size.fromRadius(radius)),
      );
    } finally {
      _isPainting = false;
    }
  }

  @override
  void dispose() {
    _cachedThumbPainter?.dispose();
    _cachedThumbPainter = null;
    super.dispose();
  }
}
