import 'package:flutter/material.dart';
import 'package:one_ui/src/physics/scroll_physics.dart';
import 'package:one_ui/src/widgets/appbar/appbar.dart';

const double _kPhoneExpandedAppBarHeightFactor = 0.3976;
const double _kTabletExpandedAppBarHeightFactor = 0.1878;
const BorderRadius _kRadius = BorderRadius.all(Radius.circular(26.0));

class OneUIView extends StatefulWidget {
  /// Creates a One UI scroll view with a collapsible app bar.
  ///
  /// Exactly one of [child] or [slivers] must be provided.
  const OneUIView({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.largeTitle,
    this.largeTitleTextStyle,
    this.actions,
    this.useOneUITextStyle = true,
    this.collapsedHeight = kToolbarHeight,
    this.expandedHeight,
    this.expandedHeightRatio,
    this.actionSpacing,
    this.backgroundColor,
    this.child,
    this.slivers,
    this.globalKey,
    this.initCollapsed = false,
  }) : assert(
         (child == null) != (slivers == null),
         'Exactly one of child or slivers must be provided.',
       ),
       assert(
         expandedHeight == null || expandedHeightRatio == null,
         'expandedHeight and expandedHeightRatio cannot both be provided.',
       ),
       assert(
         actionSpacing == null || actionSpacing >= 0,
         'actionSpacing must be non-negative.',
       );

  /// The widget displayed in the expanded app bar.
  final Widget? largeTitle;

  /// The style to use for large title text when [useOneUITextStyle] is true.
  final TextStyle? largeTitleTextStyle;

  /// The widget displayed in the collapsed app bar.
  ///
  /// [largeTitle] falls back to this widget when it is null.
  final Widget title;

  /// {@macro oneui.appbar.actions}
  ///
  /// This property is used to configure a [OneUIAppBar].
  final List<Widget>? actions;

  /// {@macro oneui.appbar.automaticallyImplyLeading}
  ///
  /// This property is used to configure a [OneUIAppBar].
  final bool automaticallyImplyLeading;

  /// Whether to apply the default One UI text style to [largeTitle].
  final bool useOneUITextStyle;

  /// The height of the app bar when it is fully expanded.
  ///
  /// {@template oneui.view.expandedHeight}
  /// The value should be large enough to accommodate the expanded title.
  ///
  /// Do not set both [expandedHeight] and [expandedHeightRatio]. When both are
  /// null, the default is calculated from the screen dimensions:
  ///
  /// * At widths up to 600 logical pixels, the height is 39.76% of the screen
  ///   height.
  /// * Above 600 logical pixels in both dimensions, the height is 18.78% of the
  ///   screen height.
  /// * Above 600 logical pixels wide but no more than 600 logical pixels high,
  ///   the height is [collapsedHeight].
  /// {@endtemplate}
  final double? expandedHeight;

  /// The ratio of the expanded app-bar height to the screen height.
  ///
  /// {@macro oneui.view.expandedHeight}
  final double? expandedHeightRatio;

  /// The height of the app bar when it is collapsed.
  ///
  /// Defaults to [kToolbarHeight].
  final double collapsedHeight;

  /// The horizontal space inserted between adjacent [actions].
  ///
  /// No additional spacing is inserted when this is null. The value must be
  /// non-negative.
  final double? actionSpacing;

  /// The background color of the app bar.
  final Color? backgroundColor;

  /// The scrollable body displayed below the app bar.
  ///
  /// Exactly one of [child] or [slivers] must be provided.
  final Widget? child;

  /// The slivers used to build the scrollable body below the app bar.
  ///
  /// Exactly one of [child] or [slivers] must be provided.
  final List<Widget>? slivers;

  /// Whether the view should initially display its collapsed app bar.
  final bool initCollapsed;

  /// The key used to access the view's [NestedScrollViewState].
  final GlobalKey<NestedScrollViewState>? globalKey;

  @override
  State<OneUIView> createState() => _OneUIViewState();
}

class _OneUIViewState extends State<OneUIView> {
  GlobalKey<NestedScrollViewState>? _nestedScrollViewStateKey;
  Future<void>? _scrollAnimate;
  bool _scrolling = false;

  double get expandedHeight {
    final Size size = MediaQuery.of(context).size;
    return widget.expandedHeight ??
        (widget.expandedHeightRatio != null
            ? widget.expandedHeightRatio! * size.height
            : (size.width > 600
                  ? size.height > 600
                        ? _kTabletExpandedAppBarHeightFactor * size.height
                        : collapsedHeight
                  : _kPhoneExpandedAppBarHeightFactor * size.height));
  }

  double get collapsedHeight => widget.collapsedHeight;

  @override
  void initState() {
    super.initState();
    _nestedScrollViewStateKey = widget.globalKey ?? GlobalKey();
    if (widget.initCollapsed) {
      Future.microtask(() {
        final scrollViewState = _nestedScrollViewStateKey!.currentState;
        final outerController = scrollViewState!.outerController;

        outerController.jumpTo(expandedHeight - collapsedHeight);
      });
    }
  }

  void _snapAppBar(ScrollController controller, double snapOffset) async {
    _scrolling = false;
    if (_scrollAnimate != null) await _scrollAnimate;
    _scrollAnimate = controller.animateTo(
      snapOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      return _onEndNotification(notification);
    }
    if (notification is ScrollStartNotification) {
      return _onStartNotification(notification);
    }
    return false;
  }

  bool _onStartNotification(ScrollStartNotification notification) {
    if (notification.dragDetails != null) _scrolling = true;
    return false;
  }

  bool _onEndNotification(ScrollEndNotification notification) {
    final scrollViewState = _nestedScrollViewStateKey!.currentState;
    final outerController = scrollViewState!.outerController;

    if (_scrolling &&
        scrollViewState.innerController.position.pixels == 0 &&
        !outerController.position.atEdge) {
      final range = expandedHeight - collapsedHeight;
      if (range <= 0) {
        return false;
      }
      final snapOffset = (outerController.offset / range) > 0.5 ? range : 0.0;

      Future.microtask(() async => _snapAppBar(outerController, snapOffset));
    }
    return false;
  }

  double _expandRatio(BoxConstraints constraints) {
    final double range = expandedHeight - collapsedHeight;
    if (range <= 0) {
      return 0.0;
    }

    double expandRatio = (constraints.maxHeight - collapsedHeight) / range;

    if (expandRatio > 1.0) return 1.0;
    if (expandRatio < 0.0) return 0.0;
    return expandRatio;
  }

  Widget _expandedTitle(Animation<double> animation) {
    Widget largeTitle = widget.largeTitle ?? widget.title;
    if (widget.useOneUITextStyle) {
      largeTitle = DefaultTextStyle(
        style:
            widget.largeTitleTextStyle ??
            Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 40.0,
            ),
        softWrap: false,
        child: largeTitle,
      );
    }

    return FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: Center(child: largeTitle),
    );
  }

  Widget _collapsedAppBar(Animation<double> animation) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: collapsedHeight,
        child: OneUIAppBar(
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          backgroundColor: widget.backgroundColor,
          backwardsCompatibility: false,
          title: FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            ),
            child: widget.title,
          ),
          centerTitle: false,
          actions: _spacedActions,
        ),
      ),
    );
  }

  List<Widget>? get _spacedActions {
    final List<Widget>? actions = widget.actions;
    final double? spacing = widget.actionSpacing;
    if (actions == null ||
        actions.length < 2 ||
        spacing == null ||
        spacing == 0) {
      return actions;
    }

    return <Widget>[
      for (int index = 0; index < actions.length; index++) ...<Widget>[
        if (index > 0) SizedBox(width: spacing),
        actions[index],
      ],
    ];
  }

  List<Widget> _appBar(BuildContext context, bool innerBoxIsScrolled) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          pinned: true,
          floating: true,
          automaticallyImplyLeading: false,
          backgroundColor:
              widget.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          expandedHeight: expandedHeight,
          toolbarHeight: collapsedHeight,
          elevation: 0,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final expandRatio = _expandRatio(constraints);
              final animation = AlwaysStoppedAnimation(expandRatio);
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  _expandedTitle(animation),
                  _collapsedAppBar(animation),
                ],
              );
            },
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Widget child =
        widget.child ?? CustomScrollView(slivers: widget.slivers!);
    final Widget body = SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: collapsedHeight),
        child: Builder(
          builder: (BuildContext context) {
            return ClipRRect(borderRadius: _kRadius, child: child);
          },
        ),
      ),
    );

    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: NestedScrollView(
          key: _nestedScrollViewStateKey,
          physics: OneUIScrollPhysics(expandedHeight),
          headerSliverBuilder: _appBar,
          body: body,
        ),
      ),
    );
  }
}
