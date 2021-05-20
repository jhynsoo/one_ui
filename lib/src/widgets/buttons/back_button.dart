import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_ui/src/widgets/buttons/icon_button.dart';

class OneUIBackButton extends StatelessWidget {
  /// Creates an [OneUIIconButton] with back icon.
  const OneUIBackButton({
    Key? key,
    this.color,
    this.onPressed,
    this.size,
  }) : super(key: key);

  /// The color to use for the icon.
  ///
  /// Defaults to the [IconThemeData.color] specified in the ambient [IconTheme],
  /// which usually matches the ambient [Theme]'s [ThemeData.iconTheme].
  final Color? color;

  /// An override callback to perform instead of the default behavior which is
  /// to pop the [Navigator].
  ///
  /// It can, for instance, be used to pop the platform's navigation stack
  /// via [SystemNavigator] instead of Flutter's [Navigator] in add-to-app
  /// situations.
  ///
  /// Defaults to null.
  final VoidCallback? onPressed;

  final double? size;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return OneUIIconButton(
      splashRadius: 16,
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        size: size,
      ),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
