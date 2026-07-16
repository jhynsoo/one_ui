import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:one_ui/src/widgets/buttons/flat_button.dart';

const EdgeInsets _defaultInsetPadding = EdgeInsets.symmetric(
  horizontal: 40.0,
  vertical: 24.0,
);

Future<T?> showOneUIDialog<T>({
  Key? key,
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final CapturedThemes themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    OneUIDialogRoute<T>(
      context: context,
      builder: (BuildContext context) =>
          KeyedSubtree(key: key, child: builder(context)),
      barrierColor: Colors.black54,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      settings: routeSettings,
      themes: themes,
    ),
  );
}

class OneUIDialogRoute<T> extends RawDialogRoute<T> {
  OneUIDialogRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    CapturedThemes? themes,
    super.barrierColor = Colors.black54,
    super.barrierDismissible = true,
    String? barrierLabel,
    bool useSafeArea = true,
    super.settings,
  }) : super(
         pageBuilder:
             (
               BuildContext buildContext,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) {
               final Widget pageChild = Builder(builder: builder);
               Widget dialog = themes?.wrap(pageChild) ?? pageChild;
               if (useSafeArea) {
                 dialog = SafeArea(child: dialog);
               }
               return dialog;
             },
         barrierLabel:
             barrierLabel ??
             MaterialLocalizations.of(context).modalBarrierDismissLabel,
         transitionDuration: const Duration(milliseconds: 200),
         transitionBuilder: _buildOneUIDialogTransitions,
       );

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 100);
}

Widget _buildOneUIDialogTransitions(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(.0, .025), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        ),
    child: FadeTransition(opacity: animation, child: child),
  );
}

class OneUIDialog extends StatelessWidget {
  const OneUIDialog({
    super.key,
    this.backgroundColor,
    this.elevation,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.insetPadding = _defaultInsetPadding,
    this.clipBehavior = Clip.none,
    this.shape,
    this.useOneUITheme = true,
    this.child,
  }) : _semanticsRole = SemanticsRole.dialog;

  const OneUIDialog._alert({
    this.backgroundColor,
    this.insetPadding = _defaultInsetPadding,
    this.clipBehavior = Clip.none,
    this.shape,
    this.useOneUITheme = true,
    this.child,
  }) : elevation = null,
       insetAnimationDuration = const Duration(milliseconds: 100),
       insetAnimationCurve = Curves.decelerate,
       _semanticsRole = SemanticsRole.alertDialog;

  /// {@template oneui.dialog.backgroundColor}
  /// The background color of the surface of this [OneUIDialog].
  ///
  /// This sets the [Material.color] on this [OneUIDialog]'s [Material].
  ///
  /// If null and [useOneUITheme] is true, the default One UI light or dark
  /// surface color is used. Otherwise, [DialogThemeData.backgroundColor] is
  /// used, falling back to [ColorScheme.surface].
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template oneui.dialog.elevation}
  /// The z-coordinate of this [OneUIDialog].
  ///
  /// If null, [DialogThemeData.elevation] is used. If that is also null, the
  /// elevation defaults to 2.0.
  /// {@endtemplate}
  /// {@macro flutter.material.material.elevation}
  final double? elevation;

  /// {@template oneui.dialog.insetAnimationDuration}
  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  /// {@endtemplate}
  final Duration insetAnimationDuration;

  /// {@template oneui.dialog.insetAnimationCurve}
  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.decelerate].
  /// {@endtemplate}
  final Curve insetAnimationCurve;

  /// {@template oneui.dialog.insetPadding}
  /// The amount of padding added to [MediaQueryData.viewInsets] on the outside
  /// of the dialog. This defines the minimum space between the screen's edges
  /// and the dialog.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0)`.
  /// {@endtemplate}
  final EdgeInsets? insetPadding;

  /// {@template oneui.dialog.clipBehavior}
  /// Controls how the contents of the dialog are clipped (or not) to the given
  /// [shape].
  ///
  /// See the enum [Clip] for details of all possible options and their common
  /// use cases.
  ///
  /// Defaults to [Clip.none].
  /// {@endtemplate}
  final Clip clipBehavior;

  /// {@template oneui.dialog.shape}
  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 24.0.
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template oneui.dialog.useOneUITheme}
  /// Whether to use the default One UI surface color and shape when explicit
  /// values are not provided.
  ///
  /// Defaults to true.
  /// {@endtemplate}
  final bool useOneUITheme;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  final SemanticsRole _semanticsRole;

  static const RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24.0)),
      );
  static const double _defaultElevation = 2.0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final DialogThemeData dialogTheme = DialogTheme.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets effectivePadding =
        mediaQuery.viewInsets + (insetPadding ?? EdgeInsets.zero);
    final double constraintsFactor =
        mediaQuery.orientation == Orientation.portrait
        ? mediaQuery.size.width > 600
              ? 0.6 // tablet portrait
              : 1.0 // phone portrait
        : mediaQuery.size.height > 600
        ? 0.375 // tablet landscape
        : 0.6; // phone landscape
    final BoxConstraints dialogConstraints = BoxConstraints(
      minWidth: mediaQuery.size.width * constraintsFactor,
    );

    return Semantics(
      role: _semanticsRole,
      child: AnimatedPadding(
        padding: effectivePadding,
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Align(
            alignment: const Alignment(0.0, 0.95),
            child: ConstrainedBox(
              constraints: dialogConstraints,
              child: Material(
                color:
                    backgroundColor ??
                    (useOneUITheme
                        ? isDark
                              ? const Color(0xff252525)
                              : const Color(0xfffcfcfc)
                        : dialogTheme.backgroundColor ??
                              Theme.of(context).colorScheme.surface),
                elevation:
                    elevation ?? dialogTheme.elevation ?? _defaultElevation,
                shape:
                    shape ??
                    (useOneUITheme
                        ? _defaultDialogShape
                        : dialogTheme.shape ?? _defaultDialogShape),
                type: MaterialType.card,
                clipBehavior: clipBehavior,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OneUIAlertDialog extends StatelessWidget {
  const OneUIAlertDialog({
    super.key,
    this.title,
    this.titlePadding,
    this.titleTextStyle,
    this.content,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.contentTextStyle,
    this.actions,
    this.actionsPadding = const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 16.0),
    this.actionsOverflowDirection,
    this.actionsOverflowButtonSpacing,
    this.buttonPadding,
    this.backgroundColor,
    this.semanticLabel,
    this.insetPadding = _defaultInsetPadding,
    this.clipBehavior = Clip.none,
    this.shape,
    this.scrollable = false,
    this.useOneUITheme = true,
  });

  /// The (optional) title of the dialog is displayed in a large font at the top
  /// of the dialog.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Padding around the title.
  ///
  /// If there is no title, no padding will be provided. Otherwise, this padding
  /// is used.
  ///
  /// This property defaults to providing 24 pixels on the top, left, and right
  /// of the title. If the [content] is not null, then no bottom padding is
  /// provided (but see [contentPadding]). If it _is_ null, then an extra 20
  /// pixels of bottom padding is added to separate the [title] from the
  /// [actions].
  final EdgeInsetsGeometry? titlePadding;

  /// Style for the text in the [title] of this [OneUIAlertDialog].
  ///
  /// If null, [DialogThemeData.titleTextStyle] is used. If that's null,
  /// defaults to [TextTheme.titleLarge] of [ThemeData.textTheme].
  final TextStyle? titleTextStyle;

  /// The (optional) content of the dialog is displayed in the center of the
  /// dialog in a lighter font.
  ///
  /// Typically this is a [SingleChildScrollView] that contains the dialog's
  /// message. As noted in the [AlertDialog] documentation, it's important
  /// to use a [SingleChildScrollView] if there's any risk that the content
  /// will not fit.
  final Widget? content;

  /// Padding around the content.
  ///
  /// If there is no content, no padding will be provided. Otherwise, padding of
  /// 20 pixels is provided above the content to separate the content from the
  /// title, and padding of 24 pixels is provided on the left, right, and bottom
  /// to separate the content from the other edges of the dialog.
  final EdgeInsetsGeometry contentPadding;

  /// Style for the text in the [content] of this [OneUIAlertDialog].
  ///
  /// If null, [DialogThemeData.contentTextStyle] is used. If that's null,
  /// defaults to [TextTheme.titleMedium] of [ThemeData.textTheme].
  final TextStyle? contentTextStyle;

  /// The (optional) set of actions that are displayed at the bottom of the
  /// dialog.
  ///
  /// Each [OneUIDialogAction] is rendered as a [OneUIFlatButton].
  ///
  /// These widgets will be wrapped in an [OverflowBar].
  ///
  /// If the [title] is not null but the [content] _is_ null, then an extra 20
  /// pixels of padding is added above the [OverflowBar] to separate the [title]
  /// from the [actions].
  final List<OneUIDialogAction>? actions;

  /// Padding around the set of [actions] at the bottom of the dialog.
  ///
  /// Typically used to provide padding to the button bar between the button bar
  /// and the edges of the dialog.
  ///
  /// If there are no [actions], no padding is included. The padding defaults to
  /// 24 pixels on the left and right and 16 pixels on the bottom. Note that
  /// [buttonPadding] may contribute to the padding on the edges of [actions] as
  /// well.
  final EdgeInsetsGeometry actionsPadding;

  /// The vertical direction of [actions] if the children overflow
  /// horizontally.
  ///
  /// If the dialog's [actions] do not fit into a single row, then they
  /// are arranged in a column. The first action is at the top of the
  /// column if this property is set to [VerticalDirection.down], since it
  /// "starts" at the top and "ends" at the bottom. On the other hand,
  /// the first action will be at the bottom of the column if this
  /// property is set to [VerticalDirection.up], since it "starts" at the
  /// bottom and "ends" at the top.
  ///
  /// If null, it defaults to [VerticalDirection.down].
  final VerticalDirection? actionsOverflowDirection;

  /// The spacing between [actions] when the button bar overflows.
  ///
  /// If the widgets in [actions] do not fit into a single row, they are
  /// arranged into a column. This parameter provides additional
  /// vertical space in between buttons when it does overflow.
  ///
  /// Note that the button spacing may appear to be more than
  /// the value provided. This is because most buttons adhere to the
  /// [MaterialTapTargetSize] of 48 logical pixels. Therefore, even when a button
  /// is visually 36 logical pixels high, it can occupy 48 logical pixels.
  ///
  /// If null, no spacing is added between buttons in
  /// an overflow state.
  final double? actionsOverflowButtonSpacing;

  /// The padding that surrounds each button in [actions].
  ///
  /// This is different from [actionsPadding], which defines the padding
  /// between the entire button bar and the edges of the dialog.
  ///
  /// If this property is null, no additional padding is added.
  final EdgeInsetsGeometry? buttonPadding;

  /// {@macro flutter.material.dialog.backgroundColor}
  final Color? backgroundColor;

  /// The semantic label of the dialog used by accessibility frameworks to
  /// announce screen transitions when the dialog is opened and closed.
  ///
  /// On iOS and macOS, [title] supplies the route semantics when this label is
  /// not provided.
  ///
  /// On other platforms, [MaterialLocalizations.alertDialogLabel] is used when
  /// this label is not provided.
  final String? semanticLabel;

  /// {@macro oneui.dialog.insetPadding}
  final EdgeInsets insetPadding;

  /// {@macro oneui.dialog.clipBehavior}
  final Clip clipBehavior;

  /// {@macro oneui.dialog.shape}
  final ShapeBorder? shape;

  /// Determines whether the [title] and [content] widgets are wrapped in a
  /// scrollable.
  ///
  /// This configuration is used when the [title] and [content] are expected
  /// to overflow. Both [title] and [content] are wrapped in a scroll view,
  /// allowing all overflowed content to be visible while still showing the
  /// button bar.
  final bool scrollable;

  /// {@macro oneui.dialog.useOneUITheme}
  final bool useOneUITheme;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DialogThemeData dialogTheme = DialogTheme.of(context);

    String? label = semanticLabel;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        label ??= MaterialLocalizations.of(context).alertDialogLabel;
    }

    // The paddingScaleFactor is used to adjust the padding of Dialog's
    // children.
    const double fontSizeToScale = 14.0;
    final double effectiveTextScale =
        MediaQuery.textScalerOf(context).scale(fontSizeToScale) /
        fontSizeToScale;
    final double paddingScaleFactor = _paddingScaleFactor(effectiveTextScale);
    final TextDirection? textDirection = Directionality.maybeOf(context);

    Widget? titleWidget;
    Widget? contentWidget;
    Widget? actionsWidget;
    List<Widget> actionsChildren = [];
    final bool hasActions = actions?.isNotEmpty ?? false;
    if (title != null) {
      final EdgeInsets defaultTitlePadding = EdgeInsets.fromLTRB(
        24.0,
        24.0,
        24.0,
        content == null ? 20.0 : 0.0,
      );
      final EdgeInsets effectiveTitlePadding =
          titlePadding?.resolve(textDirection) ?? defaultTitlePadding;
      titleWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveTitlePadding.left * paddingScaleFactor,
          right: effectiveTitlePadding.right * paddingScaleFactor,
          top: effectiveTitlePadding.top * paddingScaleFactor,
          bottom: effectiveTitlePadding.bottom * paddingScaleFactor,
        ),
        child: DefaultTextStyle(
          style:
              titleTextStyle ??
              dialogTheme.titleTextStyle ??
              theme.textTheme.titleLarge!,
          child: Semantics(
            namesRoute: label == null,
            container: true,
            child: title,
          ),
        ),
      );
    }

    if (content != null) {
      final EdgeInsets effectiveContentPadding = contentPadding.resolve(
        textDirection,
      );
      contentWidget = Padding(
        padding: EdgeInsets.only(
          left: effectiveContentPadding.left * paddingScaleFactor,
          right: effectiveContentPadding.right * paddingScaleFactor,
          top: title == null
              ? effectiveContentPadding.top * paddingScaleFactor
              : effectiveContentPadding.top,
          bottom: effectiveContentPadding.bottom,
        ),
        child: DefaultTextStyle(
          style:
              contentTextStyle ??
              dialogTheme.contentTextStyle ??
              theme.textTheme.titleMedium!,
          child: content!,
        ),
      );
    }

    if (hasActions) {
      for (OneUIDialogAction action in actions!) {
        final Widget actionWidget = Padding(
          padding: buttonPadding ?? EdgeInsets.zero,
          child: OneUIFlatButton(
            onPressed: action.onPressed,
            onLongPress: action.onLongPress,
            style: action.style,
            focusNode: action.focusNode,
            autofocus: action.autofocus,
            clipBehavior: action.clipBehavior,
            useOneUISplashFactory: action.useOneUISplashFactory,
            child: action.child,
          ),
        );
        actionsChildren.add(actionWidget);
      }
      actionsWidget = Padding(
        padding: actionsPadding,
        child: OverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          overflowAlignment: OverflowBarAlignment.center,
          overflowDirection: actionsOverflowDirection ?? VerticalDirection.down,
          overflowSpacing: actionsOverflowButtonSpacing ?? 0.0,
          children: actionsChildren,
        ),
      );
    }

    List<Widget> columnChildren;
    if (scrollable) {
      columnChildren = <Widget>[
        if (title != null || content != null)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (title != null) titleWidget!,
                  if (content != null) contentWidget!,
                ],
              ),
            ),
          ),
        if (hasActions) actionsWidget!,
      ];
    } else {
      columnChildren = <Widget>[
        if (title != null) titleWidget!,
        if (content != null) Flexible(child: contentWidget!),
        if (hasActions) actionsWidget!,
      ];
    }

    Widget dialogChild = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );

    if (label != null) {
      dialogChild = Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        namesRoute: true,
        label: label,
        child: dialogChild,
      );
    }

    return OneUIDialog._alert(
      backgroundColor: backgroundColor,
      insetPadding: insetPadding,
      clipBehavior: clipBehavior,
      shape: shape,
      useOneUITheme: useOneUITheme,
      child: dialogChild,
    );
  }
}

double _paddingScaleFactor(double textScaleFactor) {
  final double clampedTextScaleFactor = textScaleFactor
      .clamp(1.0, 2.0)
      .toDouble();
  return lerpDouble(1.0, 1.0 / 3.0, clampedTextScaleFactor - 1.0)!;
}

class OneUIDialogAction {
  const OneUIDialogAction({
    required this.onPressed,
    this.onLongPress,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    required this.child,
    this.useOneUISplashFactory = true,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;
  final bool useOneUISplashFactory;
}
