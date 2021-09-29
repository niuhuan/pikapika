/// 列表页下一页的行为

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum PagerAction {
  CONTROLLER,
  STREAM,
}

late PagerAction currentPagerAction;

const _propertyName = "pagerAction";

Future<void> initPagerAction() async {
  currentPagerAction = _pagerActionFromString(await method.loadProperty(
      _propertyName, PagerAction.CONTROLLER.toString()));
}

PagerAction _pagerActionFromString(String string) {
  for (var value in PagerAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return PagerAction.CONTROLLER;
}

Map<String, PagerAction> _pagerActionMap = {
  "使用按钮": PagerAction.CONTROLLER,
  "瀑布流": PagerAction.STREAM,
};

String currentPagerActionName() {
  for (var e in _pagerActionMap.entries) {
    if (e.value == currentPagerAction) {
      return e.key;
    }
  }
  return '';
}

Future<void> choosePagerAction(BuildContext context) async {
  PagerAction? result =
      await chooseMapDialog<PagerAction>(context, _pagerActionMap, "选择列表页加载方式");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    currentPagerAction = result;
  }
}
