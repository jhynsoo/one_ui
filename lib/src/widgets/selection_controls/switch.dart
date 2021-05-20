import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  /// Creates a OneUI design switch.
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
    Key? key,
    required this.value,
    required this.onChanged,
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
  })  : assert(activeThumbImage != null || onActiveThumbImageError == null),
        assert(inactiveThumbImage != null || onInactiveThumbImageError == null),
        super(key: key);

  /// Whether this switch is on or off.
  /// 
  /// This property must not be null.
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

  /// If true, set [activeColor] as `Color(0xff3e91ff)`.
  /// 
  /// Must not be null. Defaults to false.
  final bool useOneUIColor;
  
  /// The color to use when this switch is on.
  ///
  /// Defaults to [ThemeData.toggleableActiveColor].
  ///
  /// If [useOneUIColor] returns true, OneUI Color will be used instead of this color.
  ///  Else if [trackColor] returns a non-null color in the [MaterialState.selected]
  /// state, it will be used instead of this color.
  final Color? activeColor;
  /// The color to use on the thumb when this switch is off.
  /// 
  /// Defaults to `Color(0xff828282)` if `Theme.of(context).brightness == Brightness.dark`, otherwise `Color(0xfffafafa)`.
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

  /// The color of this [Switch]'s thumb.
  ///
  /// Resolved in the following states:
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If null, then the value of [activeColor] is used in the selected
  /// state and [inactiveThumbColor] in the default state. If that is also null,
  /// then the value of [SwitchThemeData.thumbColor] is used. If that is also
  /// null, then the following colors are used:
  ///
  /// | State    | Light theme                       | Dark theme                        |
  /// |----------|-----------------------------------|-----------------------------------|
  /// | Default  | `Colors.grey.shade50`             | `Colors.grey.shade400`            |
  /// | Selected | [ThemeData.toggleableActiveColor] | [ThemeData.toggleableActiveColor] |
  /// | Disabled | `Colors.grey.shade400`            | `Colors.grey.shade800`            |
  final Color? thumbColor;

  /// The color of this [Switch]'s track.
  ///
  /// Resolved in the following states:
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If null, then the value of [activeTrackColor] is used in the selected
  /// state and [inactiveTrackColor] in the default state. If that is also null,
  /// then the value of [SwitchThemeData.trackColor] is used. If that is also
  /// null, then the following colors are used:
  ///
  /// | State    | Light theme            | Dark theme             |
  /// |----------|------------------------|------------------------|
  /// | Default  | `Colors.grey.shade50`  | `Colors.grey.shade400` |
  /// | Selected | [activeColor]          | [activeColor]          |
  /// | Disabled | `Color(0x52000000)`    | `Colors.white30`       |
  final MaterialStateProperty<Color?>? trackColor;

  /// The color of this [Switch]'s thumb border.
  ///
  /// Resolved in the following states:
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  /// 
  /// null, then the following colors are used:
  ///
  /// | State    | Light theme         | Dark theme       |
  /// |----------|---------------------|------------------|
  /// | Default  | `Color(0x52000000)` | `Colors.white30` |
  /// | Selected | `[activeColor]`     | `[activeColor]`  |
  /// | Disabled | `Colors.black12`    | `Colors.white10` |
  final MaterialStateProperty<Color?>? thumbBorderColor;

  /// The color of this [Switch]'s track border.
  ///
  /// Resolved in the following states:
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  /// 
  /// null, then the following colors are used:
  ///
  /// | State    | Light theme          | Dark theme           |
  /// |----------|----------------------|----------------------|
  /// | Default  | `Color(0x52000000)`  | `Colors.white30`     |
  /// | Selected | `Colors.transparent` | `Colors.transparent` |
  /// | Disabled | `Colors.black12`     | `Colors.white10`     |
  final MaterialStateProperty<Color?>? trackBorderColor;

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
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If null, then the value of [SwitchThemeData.mouseCursor] is used. If that
  /// is also null, then [MaterialStateMouseCursor.clickable] is used.
  final MouseCursor? mouseCursor;

  /// The color for the button's [Material] when it has the input focus.
  ///
  /// If [overlayColor] returns a non-null color in the [MaterialState.focused]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// focused state. If that is also null, then the value of
  /// [ThemeData.focusColor] is used.
  final Color? focusColor;

  /// The color for the button's [Material] when a pointer is hovering over it.
  ///
  /// If [overlayColor] returns a non-null color in the [MaterialState.hovered]
  /// state, it will be used instead.
  ///
  /// If null, then the value of [SwitchThemeData.overlayColor] is used in the
  /// hovered state. If that is also null, then the value of
  /// [ThemeData.hoverColor] is used.
  final Color? hoverColor;

  /// The color for the switch's [Material].
  ///
  /// Resolves in the following states:
  ///  * [MaterialState.pressed].
  ///  * [MaterialState.selected].
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///
  /// If null, then the value of [activeColor] with alpha
  /// [kRadialReactionAlpha], [focusColor] and [hoverColor] is used in the
  /// pressed, focused and hovered state. If that is also null,
  /// the value of [SwitchThemeData.overlayColor] is used. If that is
  /// also null, then the value of [ThemeData.toggleableActiveColor] with alpha
  /// [kRadialReactionAlpha], [ThemeData.focusColor] and [ThemeData.hoverColor]
  /// is used in the pressed, focused and hovered state.
  final MaterialStateProperty<Color?>? overlayColor;

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
  _OneUISwitchState createState() => _OneUISwitchState();
}

class _OneUISwitchState extends State<OneUISwitch>
    with TickerProviderStateMixin, ToggleableStateMixin {
  Size _getSwitchSize(ThemeData theme) {
    final MaterialTapTargetSize effectiveMaterialTapTargetSize =
        theme.switchTheme.materialTapTargetSize ?? theme.materialTapTargetSize;
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
      // During a drag we may have modified the curve, reset it if its possible
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

  MaterialStateProperty<Color> get _thumbColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return widget.disabledThumbColor ??
            (isDark ? Color(0xff828282) : Color(0xfffafafa));
      }
      return Colors.white;
    });
  }

  MaterialStateProperty<Color> get _trackColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        if (states.contains(MaterialState.selected)) {
          return isDark ? Colors.white10 : Colors.black12;
        }
        return Colors.transparent;
      }
      if (states.contains(MaterialState.selected)) {
        return widget.useOneUIColor
            ? Color(0xff3e91ff)
            : widget.activeColor ?? Theme.of(context).toggleableActiveColor;
      }
      return Colors.transparent;
    });
  }

  MaterialStateProperty<Color> get _thumbBorderColor {
    final ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const Color black32 = Color(0x52000000);

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return isDark ? Colors.white10 : Colors.black12;
      }
      if (states.contains(MaterialState.selected)) {
        return widget.useOneUIColor
            ? Color(0xff3e91ff)
            : widget.activeColor ?? Theme.of(context).toggleableActiveColor;
      }
      return isDark ? Colors.white30 : black32;
    });
  }

  MaterialStateProperty<Color> get _trackBorderColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color black32 = Color(0x52000000);

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return Colors.transparent;
      }
      if (states.contains(MaterialState.disabled)) {
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

    // Colors need to be resolved in selected and non selected states separately
    // so that they can be lerped between.
    final Set<MaterialState> activeStates = states..add(MaterialState.selected);
    final Set<MaterialState> inactiveStates = states
      ..remove(MaterialState.selected);
    final Color effectiveThumbColor =
        widget.thumbColor ?? _thumbColor.resolve(states);
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

    final Set<MaterialState> focusedStates = states..add(MaterialState.focused);
    final Color effectiveFocusOverlayColor =
        widget.overlayColor?.resolve(focusedStates) ??
            widget.focusColor ??
            theme.switchTheme.overlayColor?.resolve(focusedStates) ??
            theme.focusColor;

    final Set<MaterialState> hoveredStates = states..add(MaterialState.hovered);
    final Color effectiveHoverOverlayColor =
        widget.overlayColor?.resolve(hoveredStates) ??
            widget.hoverColor ??
            theme.switchTheme.overlayColor?.resolve(hoveredStates) ??
            theme.hoverColor;

    final Set<MaterialState> activePressedStates = activeStates
      ..add(MaterialState.pressed);
    final Color effectiveActivePressedOverlayColor =
        widget.overlayColor?.resolve(activePressedStates) ??
            theme.switchTheme.overlayColor?.resolve(activePressedStates) ??
            effectiveActiveTrackColor.withAlpha(kRadialReactionAlpha);

    final Set<MaterialState> inactivePressedStates = inactiveStates
      ..add(MaterialState.pressed);
    final Color effectiveInactivePressedOverlayColor =
        widget.overlayColor?.resolve(inactivePressedStates) ??
            theme.switchTheme.overlayColor?.resolve(inactivePressedStates) ??
            effectiveActiveTrackColor.withAlpha(kRadialReactionAlpha);

    final MaterialStateProperty<MouseCursor> effectiveMouseCursor =
        MaterialStateProperty.resolveWith<MouseCursor>(
            (Set<MaterialState> states) {
      return MaterialStateProperty.resolveAs<MouseCursor?>(
              widget.mouseCursor, states) ??
          theme.switchTheme.mouseCursor?.resolve(states) ??
          MaterialStateProperty.resolveAs<MouseCursor>(
              MaterialStateMouseCursor.clickable, states);
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
            ..splashRadius = widget.splashRadius ??
                theme.switchTheme.splashRadius ??
                kRadialReactionRadius
            ..downPosition = downPosition
            ..isFocused = states.contains(MaterialState.focused)
            ..isHovered = states.contains(MaterialState.hovered)
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
  ImageProvider? _cachedThumbImage;
  ImageErrorListener? _cachedThumbErrorListener;
  BoxPainter? _cachedThumbPainter;

  BoxDecoration _createDefaultThumbDecoration(Color color, Color borderColor,
      ImageProvider? image, ImageErrorListener? errorListener) {
    return BoxDecoration(
        color: color,
        image: image == null
            ? null
            : DecorationImage(image: image, onError: errorListener),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
        )
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

    final Color trackColor =
        Color.lerp(inactiveTrackColor, activeTrackColor, currentValue)!;
    final Color trackBorderColor = Color.lerp(
        inactiveTrackBorderColor, activeTrackBorderColor, currentValue)!;
    final Color thumbBorderColor =
        value ? activeThumbBorderColor : inactiveTrackBorderColor;

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
        trackRect, const Radius.circular(_kTrackRadius));
    final Rect trackBorderRect = Rect.fromLTWH(
        trackHorizontalPadding - .5,
        (size.height - _kTrackBorderHeight) / 2.0,
        size.width - 2.0 * trackHorizontalPadding + 1.0,
        _kTrackHeight + 1.0);
    final RRect trackBorderRRect = RRect.fromRectAndRadius(
        trackBorderRect, const Radius.circular(_kTrackBorderRadius));
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
          thumbImage != _cachedThumbImage ||
          thumbErrorListener != _cachedThumbErrorListener) {
            _cachedValue = value;
        _cachedThumbColor = thumbColor;
        _cachedThumbImage = thumbImage;
        _cachedThumbErrorListener = thumbErrorListener;
        _cachedThumbPainter = _createDefaultThumbDecoration(
                thumbColor, thumbBorderColor, thumbImage, thumbErrorListener)
            .createBoxPainter(_handleDecorationChanged);
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
}
