// 显示模式, 仅安卓有效

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Method.dart';

import '../Common.dart';

const _propertyName = "androidDisplayMode";
List<String> _modes = [];
String _androidDisplayMode = "";

Future initAndroidDisplayMode() async {
  if (Platform.isAndroid) {
    _androidDisplayMode = await method.loadProperty(_propertyName, "");
    _modes = await method.loadAndroidModes();
    await _changeMode();
  }
}

Future _changeMode() async {
  await method.setAndroidMode(_androidDisplayMode);
}

Future<void> _chooseAndroidDisplayMode(BuildContext context) async {
  if (Platform.isAndroid) {
    List<String> list = [""];
    list.addAll(_modes);
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
          subtitle: Text(_androidDisplayMode),
          onTap: () async {
            await _chooseAndroidDisplayMode(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
