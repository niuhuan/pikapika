import 'dart:convert';
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
    String? result = await chooseListDialog<String>(context, "安卓屏幕刷新率 \n(若为置空操作重启应用生效)", list);
    if (result != null) {
      await method.saveProperty(_propertyName, "$result");
      _androidDisplayMode = result;
      await _changeMode();
    }
  }
}
