/// 自动全屏

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "guiAnimation";
late bool _guiAnimation;

Future<void> initGuiAnimation() async {
  _guiAnimation = (await method.loadProperty(_propertyName, "true")) == "true";
}

bool currentGuiAnimation() {
  return _guiAnimation;
}

Future<void> _chooseGuiAnimation(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "进入阅读器自动全屏", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _guiAnimation = target;
  }
}

Widget guiAnimationSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("软件界面动画"),
        subtitle: Text(_guiAnimation ? "是" : "否"),
        onTap: () async {
          await _chooseGuiAnimation(context);
          setState(() {});
        },
      );
    },
  );
}
