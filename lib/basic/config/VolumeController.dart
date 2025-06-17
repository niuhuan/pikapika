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

Widget volumeControllerSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(builder:
        (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
          value: volumeController,
          title: const Text("阅读器音量键翻页"),
          onChanged: (target) async {
            await method.saveProperty(_propertyName, "$target");
            volumeController = target;
            setState(() {});
          });
    });
  }
  return Container();
}
