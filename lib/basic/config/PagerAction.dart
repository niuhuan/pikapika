/// 列表页下一页的行为

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum PagerAction {
  CONTROLLER,
  STREAM,
}

// Map<String, PagerAction> _pagerActionMap = {
//   "使用按钮": PagerAction.CONTROLLER,
//   "瀑布流": PagerAction.STREAM,
// };

Map<String, PagerAction> _pagerActionMap = {};

const _propertyName = "pagerAction";
late PagerAction _pagerAction;

Future<void> initPagerAction() async {
  _pagerActionMap.addAll({
    tr("settings.pager_action.controller"): PagerAction.CONTROLLER,
    tr("settings.pager_action.stream"): PagerAction.STREAM,
  });
  _pagerAction = _pagerActionFromString(await method.loadProperty(
      _propertyName, PagerAction.CONTROLLER.toString()));
}

PagerAction currentPagerAction() {
  return _pagerAction;
}

PagerAction _pagerActionFromString(String string) {
  for (var value in PagerAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return PagerAction.CONTROLLER;
}

String _currentPagerActionName() {
  for (var e in _pagerActionMap.entries) {
    if (e.value == _pagerAction) {
      return e.key;
    }
  }
  return '';
}

Future<void> _choosePagerAction(BuildContext context) async {
  PagerAction? result =
      await chooseMapDialog<PagerAction>(context, _pagerActionMap, tr("settings.pager_action.choose"));
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    _pagerAction = result;
  }
}

Widget pagerActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.pager_action.title")),
        subtitle: Text(_currentPagerActionName()),
        onTap: () async {
          await _choosePagerAction(context);
          setState(() {});
        },
      );
    },
  );
}
