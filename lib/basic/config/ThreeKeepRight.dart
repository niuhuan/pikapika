import 'package:flutter/material.dart';
import '../Method.dart';

const _propertyName = "threeKeepRight";

late bool _threeKeepRight;

bool get threeKeepRight => _threeKeepRight;

Future initThreeKeepRight() async {
  _threeKeepRight = (await method.loadProperty(_propertyName, "false")) == "true";
}

Widget threeKeepRightSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        title: const Text("三区域模式翻页始终为右侧下一页"),
        value: _threeKeepRight,
        onChanged: (value) async {
          await method.saveProperty(_propertyName, "$value");
          _threeKeepRight = value;
          setState(() {});
        },
      );
    },
  );
}
