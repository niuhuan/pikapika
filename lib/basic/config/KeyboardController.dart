/// 上下键翻页

import 'dart:io';

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "keyboardController";

late bool keyboardController;

Future<void> initKeyboardController() async {
  keyboardController =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget keyboardControllerSetting() {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return SwitchListTile(
          value: keyboardController,
          title: Text(tr("settings.keyboard_controller.title")),
          onChanged: (target) async {
            await method.saveProperty(_propertyName, "$target");
            keyboardController = target;
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
