/// 音量键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';
import 'IsPro.dart';

const _propertyName = "ignoreUpgradeConfirm";

late bool _ignoreUpgradeConfirm;

bool get ignoreUpgradeConfirm => _ignoreUpgradeConfirm;

Future<void> initIgnoreUpgradeConfirm() async {
  _ignoreUpgradeConfirm =
      (await method.loadProperty(_propertyName, "false")) == "true";
  if (_ignoreUpgradeConfirm && !isPro) {
    _ignoreUpgradeConfirm = false;
    await method.saveProperty(_propertyName, "false");
  }
}

Widget ignoreUpgradeConfirmSetting() {
  return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
    return SwitchListTile(
        value: _ignoreUpgradeConfirm,
        title: Text(
          "关闭升级弹窗" + (!isPro ? "(发电)" : ""),
          style: TextStyle(
            color: !isPro ? Colors.grey : null,
          ),
        ),
        onChanged: (target) async {
          if (!isPro) {
            defaultToast(context, "请先发电再使用");
            return;
          }
          await method.saveProperty(_propertyName, "$target");
          _ignoreUpgradeConfirm = target;
          setState(() {});
        });
  });
}
