/// 自动全屏

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "autoFullScreen";
late bool _autoFullScreen;

Future<void> initAutoFullScreen() async {
  _autoFullScreen =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentAutoFullScreen() {
  return _autoFullScreen;
}

Widget autoFullScreenSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _autoFullScreen,
        title: Text(tr("settings.auto_full_screen.title")),
        onChanged: (a) async {
          await method.saveProperty(_propertyName, "$a");
          _autoFullScreen = a;
          setState(() {});
        },
      );
    },
  );
}
