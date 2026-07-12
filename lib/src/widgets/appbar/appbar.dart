import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:one_ui/src/widgets/buttons/back_button.dart';

const double _kLeadingWidth = kToolbarHeight;
const double _kMaxTitleTextScaleFactor = 1.34;

class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
  const _ToolbarContainerLayout(this.toolbarHeight);

  final double toolbarHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(height: toolbarHeight);
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(constraints.maxWidth, toolbarHeight);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height);
  }

  @override
  bool shouldRelayout(_ToolbarContainerLayout oldDelegate) =>
      toolbarHeight != oldDelegate.toolbarHeight;
}

class OneUIAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// Creates a One UI design app bar.
  ///
  /// If [elevation] is specified, it must be non-negative.
  ///
  /// Typically used in the [Scaffold.appBar] property.
  OneUIAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.brightness,
    this.iconTheme,
    this.actionsIconTheme,
    this.textTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    this.backwardsCompatibility,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
  }) : assert(elevation == null || elevation >= 0.0),
       assert(toolbarOpacity >= 0.0 && toolbarOpacity <= 1.0),
       assert(bottomOpacity >= 0.0 && bottomOpacity <= 1.0),
       preferredSize = Size.fromHeight(
         (toolbarHeight ?? kToolbarHeight) +
             (bottom?.preferredSize.height ?? 0.0),
       );

  /// {@template oneui.appbar.leading}
  /// A widget to display before the toolbar's [title].
  ///
  /// Typically the [leading] widget is an [Icon] or an [IconButton].
  ///
  /// Becomes the leading component of the [NavigationToolbar] built
  /// by this widget. The [leading] widget's width and height are constrained to
  /// be no bigger than [leadingWidth] and [toolbarHeight] respectively.
  ///
  /// If this is null and [automaticallyImplyLeading] is set to true, the
  /// [OneUIAppBar] will imply an appropriate widget. For example, if the [OneUIAppBar] is
  /// in a [Scaffold] that also has a [Drawer], the [Scaffold] will fill this
  /// widget with an [IconButton] that opens the drawer (using [Icons.menu]). If
  /// there's no [Drawer] and the parent [Navigator] can go back, the [OneUIAppBar]
  /// will use a [OneUIBackButton], which calls [Navigator.maybePop].
  /// {@endtemplate}
  final Widget? leading;

  /// {@template oneui.appbar.automaticallyImplyLeading}
  /// Whether to infer a leading widget when [OneUIAppBar.leading] is null.
  ///
  /// When false, [title] may occupy the leading space. This property has no
  /// effect when [OneUIAppBar.leading] is provided.
  /// {@endtemplate}
  final bool automaticallyImplyLeading;

  /// {@template oneui.appbar.title}
  /// The primary widget displayed in the app bar.
  ///
  /// Becomes the middle component of the [NavigationToolbar] built by this widget.
  /// Typically a [Text] widget that contains a description of the current
  /// contents of the app.
  /// {@endtemplate}
  ///
  /// The [title]'s width is constrained to fit within the remaining space
  /// between the toolbar's [leading] and [actions] widgets. Its height is
  /// _not_ constrained. The [title] is vertically centered and clipped to fit
  /// within the toolbar, whose height is [toolbarHeight]. Typically this
  /// isn't noticeable because a simple [Text] [title] will fit within the
  /// toolbar by default. On the other hand, it is noticeable when a
  /// widget with an intrinsic height that is greater than [toolbarHeight]
  /// is used as the [title]. For example, when the height of an Image used
  /// as the [title] exceeds [toolbarHeight], it will be centered and
  /// clipped (top and bottom), which may be undesirable. In cases like this
  /// the height of the [title] widget can be constrained.
  final Widget? title;

  /// {@template oneui.appbar.actions}
  /// A list of widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [OneUIIconButton]s representing common operations.
  /// For less common operations, consider using a [OneUIPopupMenuButton] as the
  /// last action.
  ///
  /// The [actions] become the trailing component of the [NavigationToolbar] built
  /// by this widget. The height of each action is constrained to be no bigger
  /// than [OneUIAppBar.toolbarHeight].
  /// {@endtemplate}
  final List<Widget>? actions;

  /// {@template oneui.appbar.flexibleSpace}
  /// This widget is stacked behind the toolbar and the tab bar. Its height will
  /// be the same as the app bar's overall height.
  ///
  /// A flexible space isn't actually flexible unless the [OneUIAppBar]'s container
  /// changes the [OneUIAppBar]'s size.
  ///
  /// Typically a [FlexibleSpaceBar]. See [FlexibleSpaceBar] for details.
  /// {@endtemplate}
  final Widget? flexibleSpace;

  /// {@template oneui.appbar.bottom}
  /// This widget appears across the bottom of the app bar.
  ///
  /// Typically a [TabBar]. Only widgets that implement [PreferredSizeWidget] can
  /// be used at the bottom of an app bar.
  /// {@endtemplate}
  final PreferredSizeWidget? bottom;

  /// {@template oneui.appbar.elevation}
  /// The z-coordinate at which to place this app bar relative to its parent.
  ///
  /// This property controls the size of the shadow below the app bar.
  ///
  /// The value must be non-negative.
  ///
  /// If this property is null, then [AppBarTheme.elevation] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the
  /// default value is 0.
  /// {@endtemplate}
  final double? elevation;

  /// {@template oneui.appbar.shadowColor}
  /// The color of the shadow below the app bar.
  ///
  /// If this property is null, then [AppBarTheme.shadowColor] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default value
  /// is fully opaque black.
  /// {@endtemplate}
  final Color? shadowColor;

  /// {@template oneui.appbar.shape}
  /// The shape of the app bar's [Material] and its shadow.
  ///
  /// A shadow is only displayed if the [elevation] is greater than
  /// zero.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template oneui.appbar.backgroundColor}
  /// The fill color to use for an app bar's [Material].
  ///
  /// If null, [AppBarTheme.backgroundColor] is used. When both values are null,
  /// the ambient [ThemeData.canvasColor] is used. In backwards-compatible mode,
  /// [ThemeData.primaryColor] is used instead.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template oneui.appbar.foregroundColor}
  /// The default color for [Text] and [Icon] widgets within the app bar.
  ///
  /// If null, [AppBarTheme.foregroundColor] is used. When both values are null,
  /// the ambient icon and text theme colors are preserved.
  ///
  /// This property is ignored when [backwardsCompatibility] is true.
  ///
  /// This color is used to configure [DefaultTextStyle] that contains
  /// the toolbar's children, and the default [IconTheme] widgets that
  /// are created if [iconTheme] and [actionsIconTheme] are null.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template oneui.appbar.brightness}
  /// A legacy brightness override used only when [backwardsCompatibility] is
  /// true. Otherwise, this property is ignored in favor of [systemOverlayStyle].
  ///
  /// Determines the brightness of the [SystemUiOverlayStyle]: for
  /// [Brightness.dark], [SystemUiOverlayStyle.light] is used, and for
  /// [Brightness.light], [SystemUiOverlayStyle.dark] is used.
  ///
  /// If this value is null then overall theme's brightness is used.
  ///
  /// The app bar is built within an `AnnotatedRegion<SystemUiOverlayStyle>`,
  /// which causes [SystemChrome.setSystemUIOverlayStyle] to be called
  /// automatically. Apps should not enclose the app bar with
  /// their own [AnnotatedRegion].
  /// {@endtemplate}
  final Brightness? brightness;

  /// {@template oneui.appbar.iconTheme}
  /// The color, opacity, and size to use for toolbar icons.
  ///
  /// If null, [AppBarTheme.iconTheme] is used. If that is also null,
  /// [ThemeData.iconTheme] is used in modern mode and
  /// [ThemeData.primaryIconTheme] is used in backwards-compatible mode.
  /// {@endtemplate}
  final IconThemeData? iconTheme;

  /// {@template oneui.appbar.actionsIconTheme}
  /// The color, opacity, and size to use for the icons that appear in the app
  /// bar's [actions].
  ///
  /// This property should only be used when the [actions] should be
  /// themed differently than the icon that appears in the app bar's [leading]
  /// widget.
  ///
  /// If this property is null, then [AppBarTheme.actionsIconTheme] of
  /// [ThemeData.appBarTheme] is used. If that is also null, then the value of
  /// [iconTheme] is used.
  /// {@endtemplate}
  final IconThemeData? actionsIconTheme;

  /// {@template oneui.appbar.textTheme}
  /// The legacy typographic styles to use for text in the app bar. This is
  /// honored only when [backwardsCompatibility] is true.
  ///
  /// If this property is null, [ThemeData.primaryTextTheme] is used in
  /// backwards-compatible mode. Prefer [toolbarTextStyle] and [titleTextStyle]
  /// for new code.
  /// {@endtemplate}
  final TextTheme? textTheme;

  /// {@template oneui.appbar.primary}
  /// Whether this app bar is being displayed at the top of the screen.
  ///
  /// If true, the app bar's toolbar elements and [bottom] widget will be
  /// padded on top by the height of the system status bar. The layout
  /// of the [flexibleSpace] is not affected by the [primary] property.
  /// {@endtemplate}
  final bool primary;

  /// {@template oneui.appbar.centerTitle}
  /// Whether the title should be centered.
  ///
  /// If this property is null, then [AppBarTheme.centerTitle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default value
  /// is false.
  /// {@endtemplate}
  final bool? centerTitle;

  /// {@template oneui.appbar.excludeHeaderSemantics}
  /// Whether the title should be wrapped with header [Semantics].
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool excludeHeaderSemantics;

  /// {@template oneui.appbar.titleSpacing}
  /// The spacing around [title] content on the horizontal axis. This spacing is
  /// applied even if there is no [leading] content or [actions]. If you want
  /// [title] to take all the space available, set this value to 0.0.
  ///
  /// If this property is null, then [AppBarTheme.titleSpacing] of
  /// [ThemeData.appBarTheme] is used. If that is also null, then the
  /// default value is [NavigationToolbar.kMiddleSpacing].
  /// {@endtemplate}
  final double? titleSpacing;

  /// {@template oneui.appbar.toolbarOpacity}
  /// How opaque the toolbar part of the app bar is.
  ///
  /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
  /// The value must be between 0.0 and 1.0, inclusive.
  /// {@endtemplate}
  final double toolbarOpacity;

  /// {@template oneui.appbar.bottomOpacity}
  /// How opaque the bottom part of the app bar is.
  ///
  /// A value of 1.0 is fully opaque, and a value of 0.0 is fully transparent.
  /// The value must be between 0.0 and 1.0, inclusive.
  /// {@endtemplate}
  final double bottomOpacity;

  /// {@template oneui.appbar.preferredSize}
  /// A size whose height is the sum of [toolbarHeight] and the [bottom] widget's
  /// preferred height.
  ///
  /// [Scaffold] uses this size to set its app bar's height.
  /// {@endtemplate}
  @override
  final Size preferredSize;

  /// {@template oneui.appbar.toolbarHeight}
  /// Defines the height of the toolbar component of a [OneUIAppBar].
  ///
  /// By default, the value of `toolbarHeight` is [kToolbarHeight].
  /// {@endtemplate}
  final double? toolbarHeight;

  /// {@template oneui.appbar.leadingWidth}
  /// Defines the width of the [leading] widget.
  ///
  /// Defaults to [kToolbarHeight].
  /// {@endtemplate}
  final double? leadingWidth;

  /// {@template oneui.appbar.backwardsCompatibility}
  /// Whether to use the legacy app-bar color, icon, text, and system-overlay
  /// defaults.
  ///
  /// Null is treated as false. Prefer [foregroundColor], [toolbarTextStyle],
  /// [titleTextStyle], and [systemOverlayStyle] for new code.
  /// {@endtemplate}
  final bool? backwardsCompatibility;

  /// {@template oneui.appbar.toolbarTextStyle}
  /// The default text style for the app bar's [leading] and
  /// [actions] widgets, but not its [title].
  ///
  /// If this property is null, then [AppBarTheme.toolbarTextStyle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default
  /// value is a copy of the overall theme's [TextTheme.bodyMedium]
  /// [TextStyle], with color set to the app bar's [foregroundColor].
  /// {@endtemplate}
  final TextStyle? toolbarTextStyle;

  /// {@template oneui.appbar.titleTextStyle}
  /// The default text style for the [title] widget in this app bar.
  ///
  /// If this property is null, then [AppBarTheme.titleTextStyle] of
  /// [ThemeData.appBarTheme] is used. If that is also null, the default
  /// value is a copy of the overall theme's [TextTheme.titleLarge]
  /// [TextStyle], with color set to the app bar's [foregroundColor].
  /// {@endtemplate}
  final TextStyle? titleTextStyle;

  /// {@template oneui.appbar.systemOverlayStyle}
  /// Specifies the style for system overlays that overlap the app bar.
  ///
  /// If null, [AppBarTheme.systemOverlayStyle] is used. If that is also null,
  /// [SystemUiOverlayStyle.light] is used for a dark color scheme and
  /// [SystemUiOverlayStyle.dark] for a light color scheme. This property is
  /// ignored when [backwardsCompatibility] is true.
  ///
  /// The app bar's descendants are built within an
  /// `AnnotatedRegion<SystemUiOverlayStyle>` widget, which causes
  /// [SystemChrome.setSystemUIOverlayStyle] to be called
  /// automatically. Apps should not enclose the app bar with their
  /// own [AnnotatedRegion].
  /// {@endtemplate}
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  State<OneUIAppBar> createState() => _OneUIAppBarState();
}

class _OneUIAppBarState extends State<OneUIAppBar> {
  static const double _defaultElevation = .0;
  static const Color _defaultShadowColor = Color(0xFF000000);

  void _handleDrawerButton() {
    Scaffold.of(context).openDrawer();
  }

  void _handleDrawerButtonEnd() {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    assert(!widget.primary || debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppBarThemeData appBarTheme = AppBarTheme.of(context);
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    final double toolbarHeight = widget.toolbarHeight ?? kToolbarHeight;
    final bool backwardsCompatibility = widget.backwardsCompatibility ?? false;

    final Color? backgroundColor = backwardsCompatibility
        ? widget.backgroundColor ??
              appBarTheme.backgroundColor ??
              theme.primaryColor
        : widget.backgroundColor ?? appBarTheme.backgroundColor;

    final Color? foregroundColor =
        widget.foregroundColor ?? appBarTheme.foregroundColor;

    IconThemeData overallIconTheme = backwardsCompatibility
        ? widget.iconTheme ?? appBarTheme.iconTheme ?? theme.primaryIconTheme
        : widget.iconTheme ??
              appBarTheme.iconTheme ??
              theme.iconTheme.copyWith(color: foregroundColor);

    IconThemeData actionsIconTheme =
        widget.actionsIconTheme ??
        appBarTheme.actionsIconTheme ??
        overallIconTheme;

    TextStyle? toolbarTextStyle = backwardsCompatibility
        ? widget.textTheme?.bodyMedium ??
              appBarTheme.toolbarTextStyle ??
              theme.primaryTextTheme.bodyMedium
        : widget.toolbarTextStyle ??
              appBarTheme.toolbarTextStyle ??
              theme.textTheme.bodyMedium?.copyWith(color: foregroundColor);

    TextStyle? titleTextStyle = backwardsCompatibility
        ? widget.textTheme?.titleLarge ??
              appBarTheme.titleTextStyle ??
              theme.primaryTextTheme.titleLarge
        : widget.titleTextStyle ??
              appBarTheme.titleTextStyle ??
              theme.textTheme.titleLarge?.copyWith(color: foregroundColor);

    if (widget.toolbarOpacity != 1.0) {
      final double opacity = const Interval(
        0.25,
        1.0,
        curve: Curves.fastOutSlowIn,
      ).transform(widget.toolbarOpacity);
      if (titleTextStyle?.color != null) {
        titleTextStyle = titleTextStyle!.copyWith(
          color: titleTextStyle.color!.withValues(alpha: opacity),
        );
      }
      if (toolbarTextStyle?.color != null) {
        toolbarTextStyle = toolbarTextStyle!.copyWith(
          color: toolbarTextStyle.color!.withValues(alpha: opacity),
        );
      }
      overallIconTheme = overallIconTheme.copyWith(
        opacity: opacity * (overallIconTheme.opacity ?? 1.0),
      );
      actionsIconTheme = actionsIconTheme.copyWith(
        opacity: opacity * (actionsIconTheme.opacity ?? 1.0),
      );
    }

    Widget? leading = widget.leading;
    if (leading == null && widget.automaticallyImplyLeading) {
      if (hasDrawer) {
        leading = IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _handleDrawerButton,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (!hasEndDrawer && canPop) {
          leading = useCloseButton
              ? const CloseButton()
              : const OneUIBackButton();
        }
      }
    }
    if (leading != null) {
      leading = ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: widget.leadingWidth ?? _kLeadingWidth,
        ),
        child: leading,
      );
    }

    Widget? title = widget.title;
    if (title != null) {
      bool? namesRoute;
      switch (theme.platform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          namesRoute = true;
          break;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          break;
      }

      title = _AppBarTitleBox(child: title);
      if (!widget.excludeHeaderSemantics) {
        title = Semantics(namesRoute: namesRoute, header: true, child: title);
      }

      title = DefaultTextStyle(
        style: titleTextStyle!,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );

      // Set maximum text scale factor to [_kMaxTitleTextScaleFactor] for the
      // title to keep the visual hierarchy the same even with larger font
      // sizes. To opt out, wrap the [title] widget in a [MediaQuery] with a
      // different [TextScaler].
      title = MediaQuery.withClampedTextScaling(
        maxScaleFactor: _kMaxTitleTextScaleFactor,
        child: title,
      );
    }

    Widget? actions;
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.actions!,
      );
    } else if (hasEndDrawer) {
      actions = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: _handleDrawerButtonEnd,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    }

    // Allow the trailing actions to have their own theme if necessary.
    if (actions != null) {
      actions = IconTheme.merge(data: actionsIconTheme, child: actions);
    }

    final Widget toolbar = NavigationToolbar(
      leading: leading,
      middle: title,
      trailing: actions,
      centerMiddle: widget.centerTitle ?? appBarTheme.centerTitle ?? false,
      middleSpacing:
          widget.titleSpacing ??
          appBarTheme.titleSpacing ??
          NavigationToolbar.kMiddleSpacing,
    );

    // If the toolbar is allocated less than toolbarHeight make it
    // appear to scroll upwards within its shrinking container.
    Widget appBar = ClipRect(
      child: CustomSingleChildLayout(
        delegate: _ToolbarContainerLayout(toolbarHeight),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: DefaultTextStyle(style: toolbarTextStyle!, child: toolbar),
        ),
      ),
    );
    if (widget.bottom != null) {
      appBar = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: toolbarHeight),
              child: appBar,
            ),
          ),
          if (widget.bottomOpacity == 1.0)
            widget.bottom!
          else
            Opacity(
              opacity: const Interval(
                0.25,
                1.0,
                curve: Curves.fastOutSlowIn,
              ).transform(widget.bottomOpacity),
              child: widget.bottom,
            ),
        ],
      );
    }

    // The padding applies to the toolbar and tabbar, not the flexible space.
    if (widget.primary) {
      appBar = SafeArea(bottom: false, top: true, child: appBar);
    }

    appBar = Align(alignment: Alignment.topCenter, child: appBar);

    if (widget.flexibleSpace != null) {
      appBar = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          Semantics(
            sortKey: const OrdinalSortKey(1.0),
            explicitChildNodes: true,
            child: widget.flexibleSpace,
          ),
          Semantics(
            sortKey: const OrdinalSortKey(0.0),
            explicitChildNodes: true,
            // Creates a material widget to prevent the flexibleSpace from
            // obscuring the ink splashes produced by appBar children.
            child: Material(type: MaterialType.transparency, child: appBar),
          ),
        ],
      );
    }

    final Brightness overlayStyleBrightness =
        widget.brightness ?? colorScheme.brightness;
    final SystemUiOverlayStyle overlayStyle = backwardsCompatibility
        ? (overlayStyleBrightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
        : widget.systemOverlayStyle ??
              appBarTheme.systemOverlayStyle ??
              (colorScheme.brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark);

    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Material(
          color: backgroundColor,
          elevation:
              widget.elevation ?? appBarTheme.elevation ?? _defaultElevation,
          shadowColor:
              widget.shadowColor ??
              appBarTheme.shadowColor ??
              _defaultShadowColor,
          shape: widget.shape,
          child: Semantics(explicitChildNodes: true, child: appBar),
        ),
      ),
    );
  }
}

class _AppBarTitleBox extends SingleChildRenderObjectWidget {
  const _AppBarTitleBox({required super.child});

  @override
  _RenderAppBarTitleBox createRenderObject(BuildContext context) {
    return _RenderAppBarTitleBox(textDirection: Directionality.of(context));
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAppBarTitleBox renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _RenderAppBarTitleBox extends RenderAligningShiftedBox {
  _RenderAppBarTitleBox({super.textDirection})
    : super(alignment: Alignment.center);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints innerConstraints = constraints.copyWith(
      maxHeight: double.infinity,
    );
    final Size childSize = child!.getDryLayout(innerConstraints);
    return constraints.constrain(childSize);
  }

  @override
  void performLayout() {
    final BoxConstraints innerConstraints = constraints.copyWith(
      maxHeight: double.infinity,
    );
    child!.layout(innerConstraints, parentUsesSize: true);
    size = constraints.constrain(child!.size);
    alignChild();
  }
}
