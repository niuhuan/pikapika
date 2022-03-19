import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "noAnimation";

late bool _noAnimation;

Future initNoAnimation() async {
  _noAnimation = (await method.loadProperty(_propertyName, "false")) == "true";
}

bool noAnimation() {
  return _noAnimation;
}

Future<void> _chooseNoAnimation(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "取消键盘或音量翻页动画", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _noAnimation = target;
  }
}

Widget noAnimationSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("取消键盘或音量翻页动画"),
        subtitle: Text(_noAnimation ? "是" : "否"),
        onTap: () async {
          await _chooseNoAnimation(context);
          setState(() {});
        },
      );
    },
  );
}
