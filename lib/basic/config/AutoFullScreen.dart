/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

late bool gAutoFullScreen;

Future<void> initAutoFullScreen() async {
  gAutoFullScreen = await method.getAutoFullScreen();
}

String autoFullScreenName() {
  return gAutoFullScreen ? "是" : "否";
}

Future<void> chooseAutoFullScreen(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "进入阅读器自动全屏", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.setAutoFullScreen(target);
    gAutoFullScreen = target;
  }
}
