/// 自动全屏

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "usingRightClickPop";
late bool _usingRightClickPop;

Future<void> initUsingRightClickPop() async {
  _usingRightClickPop =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentUsingRightClickPop() {
  return _usingRightClickPop;
}

Widget usingRightClickPopSetting() {
  if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("鼠标右键返回上一页"),
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "${value ? "是" : "否"}");
          _usingRightClickPop = value;
          setState(() {});
        },
        value: _usingRightClickPop,
      );
    },
  );
}
