/// 音量键翻页

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "volumeController";
late bool volumeController;

Future<void> initVolumeController() async {
  volumeController =
      (await method.loadProperty(_propertyName, "false")) == "true";
}

Future<void> _chooseVolumeController(BuildContext context) async {
  String? result =
      await chooseListDialog<String>(context, "音量键控制翻页", ["是", "否"]);
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    volumeController = target;
  }
}

Widget volumeControllerSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
          title: const Text("阅读器音量键翻页"),
          subtitle: Text(volumeController ? "是" : "否"),
          onTap: () async {
            await _chooseVolumeController(context);
            setState(() {});
          });
    });
  }
  return Container();
}
