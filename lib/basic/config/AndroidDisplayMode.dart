// 显示模式, 仅安卓有效

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Method.dart';

import '../Common.dart';

const _propertyName = "androidDisplayMode";

List<String> modes = [];
String _androidDisplayMode = "";

Future initAndroidDisplayMode() async {
  if (Platform.isAndroid) {
    _androidDisplayMode = await method.loadProperty(_propertyName, "");
    modes = await method.loadAndroidModes();
    await _changeMode();
  }
}

Future _changeMode() async {
  await method.setAndroidMode(_androidDisplayMode);
}

String androidDisplayModeName() {
  return _androidDisplayMode;
}

Future<void> chooseAndroidDisplayMode(BuildContext context) async {
  if (Platform.isAndroid) {
    List<String> list = [""];
    list.addAll(modes);
    String? result = await chooseListDialog<String>(context, "安卓屏幕刷新率", list);
    if (result != null) {
      await method.saveProperty(_propertyName, "$result");
      _androidDisplayMode = result;
      await _changeMode();
    }
  }
}

Widget androidDisplayModeSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text("屏幕刷新率(安卓)"),
          subtitle: Text(androidDisplayModeName()),
          onTap: () async {
            await chooseAndroidDisplayMode(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
