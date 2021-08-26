import 'package:flutter/material.dart';
import 'package:one_ui/src/physics/scroll_physics.dart';
import 'package:one_ui/src/widgets/appbar/appbar.dart';

const double _kPhoneExpandedAppBarHeightFactor = 0.3976;
const double _kTabletExpandedAppBarHeightFactor = 0.1878;
const BorderRadius _kRadius = BorderRadius.all(Radius.circular(26.0));

class OneUIView extends StatefulWidget {
  const OneUIView({
    Key? key,
    required this.title,
    this.largeTitle,
    this.actions,
    this.useOneUITextStyle = true,
    this.collapsedHeight = kToolbarHeight,
    this.expandedHeight,
    this.actionSpacing,
    this.backgroundColor,
    this.children,
    this.slivers,
    this.globalKey,
    this.initCollapsed = false,
  })  : assert(children != null || slivers != null),
        super(key: key);

  /// The text to display on expanded app bar.
  final Widget? largeTitle;

  /// The text to display on collapsed app bar.
  /// If null, it shows [largeTitle].
  final Widget title;

  /// {@macro oneui.appbar.actions}
  ///
  /// This property is used to configure an [OneUIAppBar].
  final List<Widget>? actions;

  /// If true, use default One UI text style.
  final bool useOneUITextStyle;

  /// The size of the app bar when it is fully expanded.
  ///
  /// This height should be big
  /// enough to accommodate whatever that widget contains.
  ///
  /// This does not include the status bar height (which will be automatically
  /// included if [primary] is true).
  ///
  /// | Ratation  | Phone                                 | Tablet                                |
  /// |-----------|---------------------------------------|---------------------------------------|
  /// | Portrait  | 0.3976 * [MediaQueryData.size.height] | 0.1878 * [MediaQueryData.size.height] |
  /// | Landscape | [collapsedHeight]                     | 0.1878 * [MediaQueryData.size.height] |
  final double? expandedHeight;

  /// Defines the height of the app bar when it is collapsed.
  ///
  /// By default, the collapsed height is [toolbarHeight]. If [bottom] widget is
  /// specified, then its height from [PreferredSizeWidget.preferredSize] is
  /// added to the height. If [primary] is true, then the [MediaQuery] top
  /// padding, [EdgeInsets.top] of [MediaQueryData.padding], is added as well.
  ///
  /// If [pinned] and [floating] are true, with [bottom] set, the default
  /// collapsed height is only the height of [PreferredSizeWidget.preferredSize]
  /// with the [MediaQuery] top padding.
  final double collapsedHeight;

  /// The space between [actions].
  final double? actionSpacing;

  /// The background color for app bar.
  final Color? backgroundColor;

  /// The slivers to place inside the viewport.
  final List<Widget>? children;

  /// The slivers to place inside the viewport.
  final List<Widget>? slivers;

  /// If true, display a default collapsed app bar.
  final bool initCollapsed;

  /// The globalKey that is used to get innerScrollController
  /// of [NestedScrollViewState].
  final GlobalKey<NestedScrollViewState>? globalKey;

  @override
  _OneUIViewState createState() => _OneUIViewState();
}

class _OneUIViewState extends State<OneUIView> {
  GlobalKey<NestedScrollViewState>? _nestedScrollViewStateKey;
  Future<void>? _scrollAnimate;
  bool _scrolling = false;

  double get expandedHeight {
    final Size size = MediaQuery.of(context).size;
    return size.width > 600
        ? size.height > 600
            ? _kTabletExpandedAppBarHeightFactor * size.height
            : collapsedHeight
        : _kPhoneExpandedAppBarHeightFactor * size.height;
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
      final snapOffset = (outerController.offset / range) > 0.5 ? range : 0.0;

      Future.microtask(() async => _snapAppBar(outerController, snapOffset));
    }
    return false;
  }

  double _expandRatio(BoxConstraints constraints) {
    double expandRatio = (constraints.maxHeight - collapsedHeight) /
        (expandedHeight - collapsedHeight);

    if (expandRatio > 1.0) return 1.0;
    if (expandRatio < 0.0) return 0.0;
    return expandRatio;
  }

  Widget _expandedTitle(Animation<double> animation) {
    Widget largeTitle = widget.largeTitle ?? widget.title;
    if (widget.useOneUITextStyle) {
      largeTitle = DefaultTextStyle(
        style: Theme.of(context).textTheme.headline6!.copyWith(
              fontWeight: FontWeight.w300,
              fontSize: 40.0,
            ),
        softWrap: false,
        child: largeTitle,
      );
    }

    return Expanded(
      child: FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
          ),
        ),
        child: Center(
          child: largeTitle,
        ),
      ),
    );
  }

  Widget _collapsedAppBar(Animation<double> animation) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: collapsedHeight,
        child: OneUIAppBar(
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
          actions: widget.actions,
        ),
      ),
    );
  }

  List<Widget> _appBar(BuildContext context, bool innerBoxIsScrolled) {
    return [
      SliverOverlapAbsorber(
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        sliver: SliverAppBar(
          pinned: true,
          floating: true,
          automaticallyImplyLeading: false,
          backgroundColor: widget.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
          expandedHeight: expandedHeight,
          toolbarHeight: collapsedHeight,
          elevation: 0,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final expandRatio = _expandRatio(constraints);
              final animation = AlwaysStoppedAnimation(expandRatio);
              return Column(
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
    final List<Widget> slivers = widget.slivers ??
        [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.children!.elementAt(index);
              },
              childCount: widget.children!.length,
            ),
          ),
        ];
    final Widget body = SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(top: collapsedHeight),
        child: Builder(
          builder: (BuildContext context) {
            return ClipRRect(
              borderRadius: _kRadius,
              child: CustomScrollView(
                slivers: slivers,
              ),
            );
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
