/// 音量键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const propertyName = "androidSecureFlag";

late bool androidSecureFlag;

Future<void> initAndroidSecureFlag() async {
  if (Platform.isAndroid) {
    androidSecureFlag =
        (await method.loadProperty(propertyName, "false")) == "true";
    if (androidSecureFlag) {
      await method.androidSecureFlag(true);
    }
  }
}

String androidSecureFlagName() {
  return androidSecureFlag ? "是" : "否";
}

Future<void> chooseAndroidSecureFlag(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "禁止截图/禁止显示在任务视图", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(propertyName, "$target");
    androidSecureFlag = target;
    await method.androidSecureFlag(androidSecureFlag);
  }
}

Widget androidSecureFlagSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
          title: Text("禁止截图/禁止显示在任务视图(仅安卓)"),
          subtitle: Text(androidSecureFlagName()),
          onTap: () async {
            await chooseAndroidSecureFlag(context);
            setState(() {});
          });
    });
  }
  return Container();
}
