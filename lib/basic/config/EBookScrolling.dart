import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "eBookScrolling";

late bool _eBookScrolling;

bool get eBookScrolling => _eBookScrolling;

Future initEBookScrolling() async {
  _eBookScrolling = (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget eBookScrollingSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("电子书模式滚动UI"),
        value: _eBookScrolling,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _eBookScrolling = value;
          setState(() {});
        },
      );
    },
  );
}
