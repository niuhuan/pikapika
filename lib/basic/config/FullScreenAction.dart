/// 全屏操作

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum FullScreenAction {
  TOUCH_ONCE,
  CONTROLLER,
  TOUCH_DOUBLE,
  TOUCH_DOUBLE_ONCE_NEXT,
  THREE_AREA,
}

Map<String, FullScreenAction> _fullScreenActionMap = {
  "点击屏幕一次全屏": FullScreenAction.TOUCH_ONCE,
  "使用控制器全屏": FullScreenAction.CONTROLLER,
  "双击屏幕全屏": FullScreenAction.TOUCH_DOUBLE,
  "双击屏幕全屏 + 单击屏幕下一页": FullScreenAction.TOUCH_DOUBLE_ONCE_NEXT,
  "将屏幕划分成三个区域 (上一页, 下一页, 全屏)": FullScreenAction.THREE_AREA,
};

const _defaultController = FullScreenAction.TOUCH_ONCE;
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
  return _defaultController;
}

String currentFullScreenActionName() {
  for (var e in _fullScreenActionMap.entries) {
    if (e.value == _fullScreenAction) {
      return e.key;
    }
  }
  return '';
}

Future<void> chooseFullScreenAction(BuildContext context) async {
  FullScreenAction? result = await chooseMapDialog<FullScreenAction>(
      context, _fullScreenActionMap, "选择操控方式");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _fullScreenAction = result;
  }
}

Widget fullScreenActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("操控方式"),
        subtitle: Text(currentFullScreenActionName()),
        onTap: () async {
          await chooseFullScreenAction(context);
          setState(() {});
        },
      );
    },
  );
}
