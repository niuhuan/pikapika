/// 上下键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "keyboardController";

late bool keyboardController;

Future<void> initKeyboardController() async {
  keyboardController =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

String keyboardControllerName() {
  return keyboardController ? "是" : "否";
}

Future<void> chooseKeyboardController(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "键盘控制翻页", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    keyboardController = target;
  }
}

Widget keyboardControllerSetting() {
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text("阅读器键盘翻页(仅PC)"),
          subtitle: Text(keyboardControllerName()),
          onTap: () async {
            await chooseKeyboardController(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
