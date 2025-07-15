/// 全屏操作

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

enum ContentFailedReloadAction {
  PULL_DOWN,
  TOUCH_LOADER,
}

const _propertyName = "contentFailedReloadAction";
late ContentFailedReloadAction contentFailedReloadAction;
Map<String, ContentFailedReloadAction> _contentFailedReloadActionMap = {};
Future<void> initContentFailedReloadAction() async {
  _contentFailedReloadActionMap = {
    tr("settings.content_failed_reload_action.pull_down"):
        ContentFailedReloadAction.PULL_DOWN,
    tr("settings.content_failed_reload_action.touch_loader"):
        ContentFailedReloadAction.TOUCH_LOADER,
  };
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
          context, _contentFailedReloadActionMap, tr("settings.content_failed_reload_action.choose"));
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    contentFailedReloadAction = result;
  }
}

Widget contentFailedReloadActionSetting() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: Text(tr("settings.content_failed_reload_action.title")),
        subtitle: Text(_currentContentFailedReloadActionName()),
        onTap: () async {
          await _chooseContentFailedReloadAction(context);
          setState(() {});
        },
      );
    },
  );
}
