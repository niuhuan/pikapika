/// 文件夹选择器的根路径

import 'dart:io';

import 'package:flutter/material.dart';

import '../Common.dart';
import '../Method.dart';

const _propertyName = "chooserRoot";
late String _chooserRoot;

Future<String?> initChooserRoot() async {
  _chooserRoot = await method.loadProperty(_propertyName, "");
}

String currentChooserRoot() {
  if (_chooserRoot == "") {
    if (Platform.isWindows) {
      return '/';
    } else if (Platform.isMacOS) {
      return '/Users';
    } else if (Platform.isLinux) {
      return '/';
    } else if (Platform.isAndroid) {
      return '/storage/emulated/0';
    } else {
      throw 'error';
    }
  }
  return _chooserRoot;
}

Future<dynamic> inputChooserRoot(BuildContext context) async {
  String? input = await displayTextInputDialog(
    context,
    '文件夹选择器根路径',
    '请输入文件夹选择器根路径',
    _chooserRoot,
    "导出时选择目录的默认路径, 同时也是根路径, 不能正常导出时也可以尝试设置此选项。",
  );
  if (input != null) {
    await method.saveProperty(_propertyName, input);
    _chooserRoot = input;
  }
}
