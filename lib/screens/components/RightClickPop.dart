import 'package:flutter/material.dart';

class RightClickPop extends StatelessWidget {
  final Widget child;

  const RightClickPop(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: () => Navigator.of(context).pop(),
      child: child,
    );
  }
}
