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
        title: const Text("取消翻页动画（点按屏幕、音量键、键盘）"),
        onChanged: (target) async {
          await method.saveProperty(_propertyName, "$target");
          _noAnimation = target;
          setState(() {});
        },
      );
    },
  );
}
