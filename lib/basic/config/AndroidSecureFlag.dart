/// 音量键翻页

import 'dart:io';

import 'package:pikapika/i18.dart';
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

Widget androidSecureFlagSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
          value: _androidSecureFlag,
          title: Text(
            tr("settings.android_secure_flag") + (!isPro ? "(${tr('settings.app.pro')})" : ""),
            style: TextStyle(
              color: !isPro ? Colors.grey : null,
            ),
          ),
          onChanged: (target) async {
            if (!isPro) {
              defaultToast(context, tr('app.pro_required'));
              return;
            }
            await method.saveProperty(_propertyName, "$target");
            _androidSecureFlag = target;
            await method.androidSecureFlag(_androidSecureFlag);
            setState(() {});
          });
    });
  }
  return Container();
}
