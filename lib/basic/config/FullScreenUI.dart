/// 全屏操作

import 'dart:io';

import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Common.dart';
import '../Method.dart';

enum FullScreenUI {
  NO,
  HIDDEN_BOTTOM,
  ALL,
}

// Map<String, FullScreenUI> fullScreenUIMap = {
//   "不使用": FullScreenUI.NO,
//   "去除虚拟控制器": FullScreenUI.HIDDEN_BOTTOM,
//   "全屏": FullScreenUI.ALL,
// };

final Map<String, FullScreenUI> fullScreenUIMap = {};

const _propertyName = "fullScreenUI";
late FullScreenUI fullScreenUI;

Future<void> initFullScreenUI() async {
  fullScreenUIMap.addAll({
    tr("settings.full_screen_ui.no"): FullScreenUI.NO,
    tr("settings.full_screen_ui.hidden_bottom"): FullScreenUI.HIDDEN_BOTTOM,
    tr("settings.full_screen_ui.all"): FullScreenUI.ALL,
  });
  fullScreenUI = _fullScreenUIFromString(await method.loadProperty(
    _propertyName,
    FullScreenUI.NO.toString(),
  ));
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemStatusBarContrastEnforced: true,
    systemNavigationBarContrastEnforced: true,
  ));
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );
  switchFullScreenUI();
}

FullScreenUI _fullScreenUIFromString(String string) {
  for (var value in FullScreenUI.values) {
    if (string == value.toString()) {
      return value;
    }
  }
  return FullScreenUI.NO;
}

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
      await chooseMapDialog<FullScreenUI>(context, fullScreenUIMap, tr("settings.full_screen_ui.choose"));
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
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
      break;
    case FullScreenUI.ALL:
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
      break;
    case FullScreenUI.NO:
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
      break;
  }
  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: list,
    );
  }
}

Widget fullScreenUISetting() {
  if (Platform.isAndroid || Platform.isIOS) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text(tr("settings.full_screen_ui.title")),
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
