/// 全屏操作

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum FullScreenAction {
  CONTROLLER,
  TOUCH_ONCE,
}

Map<String, FullScreenAction> _fullScreenActionMap = {
  "使用控制器": FullScreenAction.CONTROLLER,
  "点击屏幕一次": FullScreenAction.TOUCH_ONCE,
};

const _propertyName = "fullScreenAction";
late FullScreenAction _fullScreenAction;

Future<void> initFullScreenAction() async {
  _fullScreenAction = _fullScreenActionFromString(await method.loadProperty(
    _propertyName,
    FullScreenAction.CONTROLLER.toString(),
  ));
}

FullScreenAction currentFullScreenAction() {
  return _fullScreenAction;
}

FullScreenAction _fullScreenActionFromString(String string) {
  for (var value in FullScreenAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return FullScreenAction.CONTROLLER;
}

String _currentFullScreenActionName() {
  for (var e in _fullScreenActionMap.entries) {
    if (e.value == _fullScreenAction) {
      return e.key;
    }
  }
  return '';
}

Future<void> _chooseFullScreenAction(BuildContext context) async {
  FullScreenAction? result = await chooseMapDialog<FullScreenAction>(
      context, _fullScreenActionMap, "选择进入全屏的方式");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _fullScreenAction = result;
  }
}

Widget fullScreenActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text("进入全屏的方式"),
        subtitle: Text(_currentFullScreenActionName()),
        onTap: () async {
          await _chooseFullScreenAction(context);
          setState(() {});
        },
      );
    },
  );
}
