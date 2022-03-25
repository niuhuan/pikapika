import 'package:flutter/material.dart';

import '../../basic/config/UsingRightClickPop.dart';

Widget rightClickPop({
  required Widget child,
  required BuildContext context,
  bool canPop = true,
}) =>
    currentUsingRightClickPop()
        ? GestureDetector(
            onSecondaryTap: () {
              if (canPop) {
                Navigator.of(context).pop();
              }
            },
            child: child,
          )
        : child;
