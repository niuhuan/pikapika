import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "noAnimation";

late bool _noAnimation;

Future initNoAnimation() async {
  _noAnimation = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool noAnimation() {
  return _noAnimation;
}

Widget noAnimationSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _noAnimation,
        title: Text(tr("settings.no_animation.title")),
        onChanged: (target) async {
          await method.saveProperty(_propertyName, "$target");
          _noAnimation = target;
          setState(() {});
        },
      );
    },
  );
}
