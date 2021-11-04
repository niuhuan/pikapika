/// 自动全屏

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

Future<void> _chooseAutoFullScreen(BuildContext context) async {
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
        subtitle: Text(_autoFullScreen ? "是" : "否"),
        onTap: () async {
          await _chooseAutoFullScreen(context);
          setState(() {});
        },
      );
    },
  );
}
