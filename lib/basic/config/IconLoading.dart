/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "iconLoading";
late bool _iconLoading;

Future<void> initIconLoading() async {
  _iconLoading = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentIconLoading() {
  return _iconLoading;
}

Widget iconLoadingSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("尽量减少UI动画"),
        value: _iconLoading,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _iconLoading = value;
        },
      );
    },
  );
}

Route<T> mixRoute<T>({required WidgetBuilder builder}) {
  if (currentIconLoading()) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => builder.call(context),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
  return MaterialPageRoute(builder: builder);
}
