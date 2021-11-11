import 'package:flutter/material.dart';

class Badged extends StatelessWidget {
  final String? badge;
  final Widget child;

  const Badged({Key? key, required this.child, this.badge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (badge == null) {
      return child;
    }
    return Stack(
      children: [
        child,
        new Positioned(
          right: 0,
          child: new Container(
            padding: EdgeInsets.all(1),
            decoration: new BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: new Text(
              badge!,
              style: new TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
