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
        title: const Text("在首页连续按两下返回键才能退出APP"),
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
