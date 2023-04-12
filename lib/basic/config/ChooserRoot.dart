/// 文件夹选择器的根路径

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Common.dart';
import '../Method.dart';
import 'Platform.dart';

const _propertyName = "chooserRoot";
late String _chooserRoot;

Future<dynamic> initChooserRoot() async {
  _chooserRoot = await method.loadProperty(_propertyName, "");
  if (_chooserRoot.isEmpty) {
    if (Platform.isAndroid) {
      try {
        _chooserRoot = await method.androidStorageRoot();
      } catch (e) {
        _chooserRoot = "/sdcard";
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      _chooserRoot = await method.getHomeDir();
    } else if (Platform.isWindows) {
      _chooserRoot = "/";
    }
  }
}

Future<String> currentChooserRoot() async {
  if (Platform.isAndroid) {
    late bool g;
    if (androidVersion < 30) {
      g = await Permission.storage.request().isGranted;
    }else{
      g = await Permission.manageExternalStorage.request().isGranted;
    }
    if (!g) {
      throw Exception("申请权限被拒绝");
    }
  }
  return _chooserRoot;
}

Future<dynamic> _inputChooserRoot(BuildContext context) async {
  String? input = await displayTextInputDialog(
    context,
    src: _chooserRoot,
    title: '文件夹选择器根路径',
    hint: '请输入文件夹选择器根路径',
    desc: "导出时选择目录的默认路径, 同时也是根路径, 不能正常导出时也可以尝试设置此选项。",
  );
  if (input != null) {
    await method.saveProperty(_propertyName, input);
    _chooserRoot = input;
  }
}

Widget chooserRootSetting() {
  if (Platform.isIOS) {
    return Container();
  }
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        title: const Text("文件夹选择器默认路径"),
        subtitle: Text(_chooserRoot),
        onTap: () async {
          await _inputChooserRoot(context);
          setState(() {});
        },
      );
    },
  );
}
