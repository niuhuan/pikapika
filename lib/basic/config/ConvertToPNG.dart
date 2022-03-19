import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "convertToPNG";
var _convertToPNG = false;

Future initConvertToPNG() async {
  if (Platform.isAndroid) {
    _convertToPNG =
        (await method.loadProperty(_propertyName, "false")) == "true";
  }
}

bool convertToPNG() {
  return _convertToPNG;
}

Future<void> _chooseConvertToPNGSetting(BuildContext context) async {
  String? result = await chooseListDialog<String>(context, "超大图片缩放", ["是", "否"],
      tips: "会增加耗电\n可以解决部分漫画崩溃的问题");
  if (result != null) {
    var target = result == "是";
    await method.saveProperty(_propertyName, "$target");
    _convertToPNG = target;
  }
}

Widget convertToPNGSetting() {
  if (Platform.isAndroid) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("读取到超大图片时进行缩放(防止崩溃)"),
          subtitle: Text(_convertToPNG ? "是" : "否"),
          onTap: () async {
            await _chooseConvertToPNGSetting(context);
            setState(() {});
          },
        );
      },
    );
  }
  return Container();
}
