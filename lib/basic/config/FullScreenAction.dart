/// 全屏操作

import 'package:easy_localization/easy_localization.dart';
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

// Map<String, FullScreenAction> _fullScreenActionMap = {
//   "点击屏幕一次全屏": FullScreenAction.TOUCH_ONCE,
//   "使用控制器全屏": FullScreenAction.CONTROLLER,
//   "双击屏幕全屏": FullScreenAction.TOUCH_DOUBLE,
//   "双击屏幕全屏 + 单击屏幕下一页": FullScreenAction.TOUCH_DOUBLE_ONCE_NEXT,
//   "将屏幕划分成三个区域 (上一页, 下一页, 全屏)": FullScreenAction.THREE_AREA,
// };

Map<String, FullScreenAction> _fullScreenActionMap = {};

const _defaultController = FullScreenAction.TOUCH_ONCE;
const _propertyName = "fullScreenAction";
late FullScreenAction _fullScreenAction;

Future<void> initFullScreenAction() async {
  _fullScreenActionMap.addAll({
    tr("settings.full_screen_action.touch_once"): FullScreenAction.TOUCH_ONCE,
    tr("settings.full_screen_action.controller"): FullScreenAction.CONTROLLER,
    tr("settings.full_screen_action.touch_double"): FullScreenAction.TOUCH_DOUBLE,
    tr("settings.full_screen_action.touch_double_once_next"): FullScreenAction.TOUCH_DOUBLE_ONCE_NEXT,
    tr("settings.full_screen_action.three_area"): FullScreenAction.THREE_AREA,
  });
  _fullScreenAction = _fullScreenActionFromString(await method.loadProperty(
    _propertyName,
    FullScreenAction.TOUCH_ONCE.toString(),
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
      context, _fullScreenActionMap, tr("settings.full_screen_action.choose"));
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _fullScreenAction = result;
  }
}

Widget fullScreenActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.full_screen_action.title")),
        subtitle: Text(currentFullScreenActionName()),
        onTap: () async {
          await chooseFullScreenAction(context);
          setState(() {});
        },
      );
    },
  );
}
