/// 全屏操作

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Common.dart';
import '../Method.dart';

enum FullScreenUI {
  NO,
  HIDDEN_BOTTOM,
  ALL,
}

const _propertyName = "fullScreenUI";
late FullScreenUI fullScreenUI;

Future<void> initFullScreenUI() async {
  fullScreenUI = _fullScreenUIFromString(await method.loadProperty(
    _propertyName,
    FullScreenUI.NO.toString(),
  ));
}

FullScreenUI _fullScreenUIFromString(String string) {
  for (var value in FullScreenUI.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return FullScreenUI.NO;
}

Map<String, FullScreenUI> fullScreenUIMap = {
  "不使用": FullScreenUI.NO,
  "去除虚拟控制器": FullScreenUI.HIDDEN_BOTTOM,
  "全屏": FullScreenUI.ALL,
};

String currentFullScreenUIName() {
  for (var e in fullScreenUIMap.entries) {
    if (e.value == fullScreenUI) {
      return e.key;
    }
  }
  return '';
}

Future<void> chooseFullScreenUI(BuildContext context) async {
  FullScreenUI? result =
      await chooseMapDialog<FullScreenUI>(context, fullScreenUIMap, "选择全屏UI");
  if (result != null) {
    await method.saveProperty(_propertyName, result.toString());
    fullScreenUI = result;
    switchFullScreenUI();
  }
}

void switchFullScreenUI() {
  List<SystemUiOverlay> list = [...SystemUiOverlay.values];
  switch (fullScreenUI) {
    case FullScreenUI.HIDDEN_BOTTOM:
      list.remove(SystemUiOverlay.bottom);
      break;
    case FullScreenUI.ALL:
      list.clear();
      break;
    case FullScreenUI.NO:
      break;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIOverlays(list);
  }
}

Widget fullScreenUISetting() {
  if (Platform.isAndroid || Platform.isIOS) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("全屏UI"),
          subtitle: Text(currentFullScreenUIName()),
          onTap: () async {
            await chooseFullScreenUI(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
