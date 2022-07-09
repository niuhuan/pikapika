/// 音量键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "androidSecureFlag";

late bool _androidSecureFlag;

Future<void> initAndroidSecureFlag() async {
  if (Platform.isAndroid) {
    _androidSecureFlag =
        (await method.loadProperty(_propertyName, "false")) == "true";
    if (_androidSecureFlag) {
      await method.androidSecureFlag(true);
    }
  }
}

Future<void> _chooseAndroidSecureFlag(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "禁止截图/禁止显示在任务视图", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _androidSecureFlag = target;
    await method.androidSecureFlag(_androidSecureFlag);
  }
}

Widget androidSecureFlagSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
          title: Text(
            "禁止截图/禁止显示在任务视图" + (!isPro ? "(发电)" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            _androidSecureFlag ? "是" : "否",
          ),
          onTap: () async {
            if (!isPro) {
              defaultToast(context, "请先发电再使用");
              return;
            }
            await _chooseAndroidSecureFlag(context);
            setState(() {});
          });
    });
  }
  return Container();
}
