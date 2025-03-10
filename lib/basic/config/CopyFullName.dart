import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "copyFullName";

late bool _copyFullName;

Future initCopyFullName() async {
  _copyFullName = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool copyFullName() {
  return _copyFullName;
}

Widget copyFullNameSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("复制漫画名称时包含作者"),
        value: _copyFullName,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _copyFullName = value;
          setState(() {});
        },
      );
    },
  );
}
