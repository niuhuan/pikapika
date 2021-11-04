/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

late bool _autoFullScreen;

bool currentAutoFullScreen() {
  return _autoFullScreen;
}

const _propertyName = "autoFullScreen";

Future<void> initAutoFullScreen() async {
  _autoFullScreen =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

String autoFullScreenName() {
  return _autoFullScreen ? "是" : "否";
}

Future<void> chooseAutoFullScreen(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "进入阅读器自动全屏", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _autoFullScreen = target;
  }
}

Widget autoFullScreenSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("进入阅读器自动全屏"),
        subtitle: Text(autoFullScreenName()),
        onTap: () async {
          await chooseAutoFullScreen(context);
          setState(() {});
        },
      );
    },
  );
}
