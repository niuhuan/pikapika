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

Future<void> _chooseUsingRightClickPop(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "鼠标右键返回上一页", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _usingRightClickPop = target;
  }
}

Widget usingRightClickPopSetting() {
  if (!(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("鼠标右键返回上一页"),
        subtitle: Text(_usingRightClickPop ? "是" : "否"),
        onTap: () async {
          await _chooseUsingRightClickPop(context);
          setState(() {});
        },
      );
    },
  );
}
