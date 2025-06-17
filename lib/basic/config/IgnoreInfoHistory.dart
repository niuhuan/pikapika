/// 自动全屏

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
        title: const Text("详情页不计入历史记录"),
        onChanged: (a) async {
          await method.saveProperty(_propertyName, "$a");
          _ignoreInfoHistory = a;
          setState(() {});
        },
      );
    },
  );
}
