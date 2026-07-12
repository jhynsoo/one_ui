import 'package:flutter/widgets.dart';

class OneUIBottomNavigationBarItem {
  const OneUIBottomNavigationBarItem({this.title, this.label})
    : assert(
        (title == null) != (label == null),
        'Exactly one of title or label must be provided.',
      );

  /// The title of the item.
  ///
  /// This field is deprecated; use [label] instead.
  @Deprecated(
    'Use "label" instead, as it allows for an improved text-scaling experience.',
  )
  final Widget? title;

  /// The text label for this [OneUIBottomNavigationBarItem].
  ///
  /// This is used to create the [Text] widget in the bottom navigation bar.
  final String? label;
}
