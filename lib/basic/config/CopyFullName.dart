import 'package:easy_localization/easy_localization.dart';
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
        title: Text(tr("settings.copy_full_name.title")),
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
