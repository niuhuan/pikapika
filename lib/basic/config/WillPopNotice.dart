import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "willPopNotice";

late bool _willPopNotice;

Future initWillPopNotice() async {
  _willPopNotice = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool willPopNotice() {
  return _willPopNotice;
}

Widget willPopNoticeSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: Text(tr('settings.will_pop_notice')),
        value: _willPopNotice,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _willPopNotice = value;
          setState(() {});
        },
      );
    },
  );
}
