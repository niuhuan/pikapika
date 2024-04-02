import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "copySkipConfirm";

late bool _copySkipConfirm;

Future initCopySkipConfirm() async {
  _copySkipConfirm = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool copySkipConfirm() {
  return _copySkipConfirm;
}

Widget copySkipConfirmSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("长按复制不需要确认"),
        value: _copySkipConfirm,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _copySkipConfirm = value;
          setState(() {});
        },
      );
    },
  );
}
