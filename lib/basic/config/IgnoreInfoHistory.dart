/// 自动全屏

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "ignoreInfoHistory";
late bool _ignoreInfoHistory;

Future<void> initIgnoreInfoHistory() async {
  _ignoreInfoHistory =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

bool currentIgnoreInfoHistory() {
  return _ignoreInfoHistory;
}

Widget ignoreInfoHistorySetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _ignoreInfoHistory,
        title: Text(tr("settings.ignore_info_history.title")),
        onChanged: (a) async {
          await method.saveProperty(_propertyName, "$a");
          _ignoreInfoHistory = a;
          setState(() {});
        },
      );
    },
  );
}
