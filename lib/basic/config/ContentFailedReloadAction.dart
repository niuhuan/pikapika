/// 全屏操作

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum ContentFailedReloadAction {
  PULL_DOWN,
  TOUCH_LOADER,
}

const _propertyName = "contentFailedReloadAction";
late ContentFailedReloadAction contentFailedReloadAction;

Future<void> initContentFailedReloadAction() async {
  contentFailedReloadAction =
      _contentFailedReloadActionFromString(await method.loadProperty(
    _propertyName,
    ContentFailedReloadAction.PULL_DOWN.toString(),
  ));
}

ContentFailedReloadAction _contentFailedReloadActionFromString(String string) {
  for (var value in ContentFailedReloadAction.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return ContentFailedReloadAction.PULL_DOWN;
}

Map<String, ContentFailedReloadAction> _contentFailedReloadActionMap = {
  "下拉刷新": ContentFailedReloadAction.PULL_DOWN,
  "点击屏幕刷新": ContentFailedReloadAction.TOUCH_LOADER,
};

String _currentContentFailedReloadActionName() {
  for (var e in _contentFailedReloadActionMap.entries) {
    if (e.value == contentFailedReloadAction) {
      return e.key;
    }
  }
  return '';
}

Future<void> _chooseContentFailedReloadAction(BuildContext context) async {
  ContentFailedReloadAction? result =
      await chooseMapDialog<ContentFailedReloadAction>(
          context, _contentFailedReloadActionMap, "选择页面加载失败刷新的方式");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    contentFailedReloadAction = result;
  }
}

Widget contentFailedReloadActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("加载失败时"),
        subtitle: Text(_currentContentFailedReloadActionName()),
        onTap: () async {
          await _chooseContentFailedReloadAction(context);
          setState(() {});
        },
      );
    },
  );
}
