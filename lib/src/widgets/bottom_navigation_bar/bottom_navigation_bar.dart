import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:one_ui/src/effects/bottom_navigation_bar_ink_splash.dart';
import 'package:one_ui/src/widgets/bottom_navigation_bar/bottom_navigation_bar_item.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class OneUIBottomNavigationBar extends StatefulWidget {
  OneUIBottomNavigationBar({
    Key? key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
    Color? fixedColor,
    this.backgroundColor,
    Color? selectedItemColor,
    this.unselectedItemColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.mouseCursor,
    this.enableFeedback,
    this.fontSize = 14.0,
  })  : assert(items.length >= 2),
        assert(0 <= currentIndex && currentIndex < items.length),
        assert(selectedItemColor == null || fixedColor == null,
            'Either selectedItemColor or fixedColor can be specified, but not both'),
        assert(fontSize >= 0.0),
        selectedItemColor = selectedItemColor ?? fixedColor,
        super(key: key);

  final List<OneUIBottomNavigationBarItem> items;

  /// Called when one of the [items] is tapped.
  ///
  /// The stateful widget that creates the bottom navigation bar needs to keep
  /// track of the index of the selected [OneUIBottomNavigationBarItem] and call
  /// `setState` to rebuild the bottom navigation bar with the new [currentIndex].
  final ValueChanged<int>? onTap;

  /// The index into [items] for the current active [OneUIBottomNavigationBarItem].
  final int currentIndex;

  /// The value of [selectedItemColor].
  ///
  /// This getter only exists for backwards compatibility, the
  /// [selectedItemColor] property is preferred.
  Color? get fixedColor => selectedItemColor;

  /// The color of the [BottomNavigationBar] itself.
  final Color? backgroundColor;

  /// The color of the selected [OneUIBottomNavigationBarItem.label] and
  /// [OneUIBottomNavigationBarItem.title].
  ///
  /// If null then the [ThemeData.primaryColor] is used.
  final Color? selectedItemColor;

  /// The color of the unselected [OneUIBottomNavigationBarItem.label] and
  /// [OneUIBottomNavigationBarItem.title]s.
  ///
  /// If null then the [ThemeData.unselectedWidgetColor]'s color is used.
  final Color? unselectedItemColor;

  /// The [TextStyle] of the [OneUIBottomNavigationBarItem] labels when they are
  /// selected.
  final TextStyle? selectedLabelStyle;

  /// The [TextStyle] of the [OneUIBottomNavigationBarItem] labels when they are not
  /// selected.
  final TextStyle? unselectedLabelStyle;

  /// The font size of the [OneUIBottomNavigationBarItem] labels.
  ///
  /// Defaults to `14.0`.
  final double fontSize;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// tiles.
  ///
  /// If this property is null, [SystemMouseCursors.click] will be used.
  final MouseCursor? mouseCursor;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  final bool? enableFeedback;

  @override
  _OneUIBottomNavigationBarState createState() =>
      _OneUIBottomNavigationBarState();
}

class _OneUIBottomNavigationTile extends StatelessWidget {
  const _OneUIBottomNavigationTile({
    required this.item,
    required this.animation,
    this.onTap,
    this.colorTween,
    this.flex,
    this.selected = false,
    required this.selectedLabelStyle,
    required this.unselectedLabelStyle,
    this.indexLabel,
    required this.mouseCursor,
    required this.enableFeedback,
  });

  final OneUIBottomNavigationBarItem item;
  final Animation<double> animation;
  final VoidCallback? onTap;
  final ColorTween? colorTween;
  final double? flex;
  final bool selected;
  final TextStyle selectedLabelStyle;
  final TextStyle unselectedLabelStyle;
  final String? indexLabel;
  final MouseCursor mouseCursor;
  final bool enableFeedback;
  @override
  Widget build(BuildContext context) {
    final double selectedFontSize = selectedLabelStyle.fontSize!;

    return Expanded(
      child: Semantics(
        selected: selected,
        container: true,
        child: Stack(
          children: [
            InkResponse(
              splashFactory: OneUIBottomNavigationBarSplash.splashFactory,
              hoverColor: Colors.transparent,
              onTap: onTap,
              mouseCursor: mouseCursor,
              enableFeedback: enableFeedback,
              highlightShape: BoxShape.rectangle,
              containedInkWell: true,
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              child: SizedBox(
                height: 36.0,
                child: Center(
                  child: _Label(
                    selected: selected,
                    colorTween: colorTween!,
                    animation: animation,
                    item: item,
                    selectedLabelStyle: selectedLabelStyle,
                    unselectedLabelStyle: unselectedLabelStyle,
                  ),
                ),
              ),
            ),
            Semantics(label: indexLabel),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    Key? key,
    required this.selected,
    required this.colorTween,
    required this.animation,
    required this.item,
    required this.selectedLabelStyle,
    required this.unselectedLabelStyle,
  }) : super(key: key);

  final bool selected;
  final ColorTween colorTween;
  final Animation<double> animation;
  final OneUIBottomNavigationBarItem item;
  final TextStyle selectedLabelStyle;
  final TextStyle unselectedLabelStyle;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final double? selectedFontSize = selectedLabelStyle.fontSize;
    final double? unselectedFontSize = unselectedLabelStyle.fontSize;

    final TextStyle customStyle = TextStyle.lerp(
      unselectedLabelStyle,
      selectedLabelStyle,
      animation.value,
    )!;

    return MediaQuery(
      data: mediaQueryData.copyWith(
        textScaleFactor: math.min(1.0, mediaQueryData.textScaleFactor),
      ),
      child: Align(
        alignment: Alignment.center,
        // heightFactor: 1.0,
        child: Container(
          padding: const EdgeInsets.only(top: 2.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2.0,
                color: selected
                    ? colorTween.evaluate(animation)!
                    : Colors.transparent,
              ),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: customStyle.copyWith(
              fontSize: selectedFontSize,
              color: colorTween.evaluate(animation),
            ),
            child: Transform(
              transform: Matrix4.diagonal3(
                Vector3.all(
                  Tween<double>(
                    begin: unselectedFontSize! / selectedFontSize!,
                    end: 1.0,
                  ).evaluate(animation),
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: item.title ?? Text(item.label!),
            ),
          ),
        ),
      ),
    );
  }
}

class _OneUIBottomNavigationBarState extends State<OneUIBottomNavigationBar>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = <AnimationController>[];
  late List<CurvedAnimation> _animations;

  static final Animatable<double> _flexTween = Tween<double>(
    begin: 1.0,
    end: 1.5,
  );

  void _resetState() {
    for (final AnimationController controller in _controllers) {
      controller.dispose();
    }

    _controllers = List<AnimationController>.generate(
      widget.items.length,
      (int index) => AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      )..addListener(_rebuild),
    );
    _animations = List<CurvedAnimation>.generate(
      widget.items.length,
      (int index) => CurvedAnimation(
        parent: _controllers.elementAt(index),
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn.flipped,
      ),
    );
    _controllers.elementAt(widget.currentIndex).value = 1.0;
  }

  @override
  void initState() {
    super.initState();
    _resetState();
  }

  void _rebuild() {
    setState(() {
      // Rebuilding when any of the controllers tick, i.e. when the items are
      // animated.
    });
  }

  @override
  void dispose() {
    for (final AnimationController controller in _controllers)
      controller.dispose();
    super.dispose();
  }

  double _evaluateFlex(Animation<double> animation) =>
      _flexTween.evaluate(animation);

  @override
  void didUpdateWidget(OneUIBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // No animated segue if the length of the items list changes.
    if (widget.items.length != oldWidget.items.length) {
      _resetState();
      return;
    }

    if (widget.currentIndex != oldWidget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  // If the given [TextStyle] has a non-null `fontSize`, it should be used.
  // Otherwise, the [selectedFontSize] parameter should be used.
  static TextStyle _effectiveTextStyle(TextStyle? textStyle, double fontSize) {
    textStyle ??= const TextStyle();
    // Prefer the font size on textStyle if present.
    return textStyle.fontSize == null
        ? textStyle.copyWith(fontSize: fontSize)
        : textStyle;
  }

  List<Widget> _createTiles() {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final ThemeData themeData = Theme.of(context);
    final BottomNavigationBarThemeData bottomTheme =
        BottomNavigationBarTheme.of(context);

    final TextStyle effectiveSelectedLabelStyle = _effectiveTextStyle(
      widget.selectedLabelStyle ?? bottomTheme.selectedLabelStyle,
      widget.fontSize,
    );
    final TextStyle effectiveUnselectedLabelStyle = _effectiveTextStyle(
      widget.unselectedLabelStyle ?? bottomTheme.unselectedLabelStyle,
      widget.fontSize,
    );

    final Color themeColor;
    switch (themeData.brightness) {
      case Brightness.light:
        themeColor = themeData.colorScheme.primary;
        break;
      case Brightness.dark:
        themeColor = themeData.colorScheme.secondary;
        break;
    }

    final ColorTween colorTween;
    colorTween = ColorTween(
      begin: widget.unselectedItemColor ??
          bottomTheme.unselectedItemColor ??
          themeData.unselectedWidgetColor,
      end: widget.selectedItemColor ??
          bottomTheme.selectedItemColor ??
          widget.fixedColor ??
          themeColor,
    );
    final MouseCursor effectiveMouseCursor =
        widget.mouseCursor ?? SystemMouseCursors.click;

    final List<Widget> tiles = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      tiles.add(_OneUIBottomNavigationTile(
        item: widget.items[i],
        animation: _animations[i],
        selectedLabelStyle: effectiveSelectedLabelStyle,
        unselectedLabelStyle: effectiveUnselectedLabelStyle,
        enableFeedback:
            widget.enableFeedback ?? bottomTheme.enableFeedback ?? true,
        onTap: () {
          if (widget.onTap != null) widget.onTap!(i);
        },
        colorTween: colorTween,
        flex: _evaluateFlex(_animations[i]),
        selected: i == widget.currentIndex,
        indexLabel: localizations.tabLabel(
            tabIndex: i + 1, tabCount: widget.items.length),
        mouseCursor: effectiveMouseCursor,
      ));
    }
    return tiles;
  }

  Widget _createContainer(List<Widget> tiles) {
    return DefaultTextStyle.merge(
      overflow: TextOverflow.ellipsis,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: tiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMediaQuery(context));
    assert(Overlay.of(context, debugRequiredFor: widget) != null);

    final BottomNavigationBarThemeData bottomTheme =
        BottomNavigationBarTheme.of(context);
    final double additionalBottomPadding =
        MediaQuery.of(context).padding.bottom;
    Color? backgroundColor =
        widget.backgroundColor ?? bottomTheme.backgroundColor;

    return Semantics(
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minHeight: kBottomNavigationBarHeight + additionalBottomPadding),
        child: Material(
          color: backgroundColor,
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.only(bottom: additionalBottomPadding),
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: _createContainer(_createTiles()),
            ),
          ),
        ),
      ),
    );
  }
}
