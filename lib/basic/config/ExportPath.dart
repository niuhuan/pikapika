/// 文件夹选择器的根路径

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Cross.dart';
import '../Method.dart';
import 'Platform.dart';

const _propertyName = "exportPath";
late String _exportPath;

Future<dynamic> initExportPath() async {
  _exportPath = await method.loadProperty(_propertyName, "");
  if (_exportPath.isEmpty) {
    if (Platform.isAndroid) {
      try {
        _exportPath = await method.androidDefaultExportsDir();
      } catch (e) {
        _exportPath = "/sdcard/Download/pikapika/exports";
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      _exportPath = await method.getHomeDir();
      if (Platform.isMacOS) {
        _exportPath = _exportPath + "/Downloads";
      }
    } else if (Platform.isWindows) {
      _exportPath = "exports";
    }
  }
}

Future<String> attachExportPath() async {
  late String path;
  if (Platform.isIOS) {
    path = await method.iosGetDocumentDir();
  } else {
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
    path = _exportPath;
  }
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await method.mkdirs(path);
  } else if (Platform.isAndroid) {
    await method.androidMkdirs(path);
  }
  return path;
}

String showExportPath() {
  if (Platform.isIOS) {
    return "\n\n随后可在文件管理中找到导出的内容";
  }
  return "\n\n$_exportPath";
}

Future _setExportPath(String folder) async {
  await method.saveProperty(_propertyName, folder);
  _exportPath = folder;
}

Widget displayExportPathInfo() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      if (Platform.isIOS) {
        return Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          color: (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
              .withOpacity(.01),
          child: const Text("您正在使用iOS设备:\n导出到文件的内容请打开系统自带文件管理进行浏览"),
        );
      }
      return Column(children: [
        MaterialButton(
          onPressed: () async {
            String? choose = await chooseFolder(context);
            if (choose != null) {
              _setExportPath(choose);
            }
            setState(() {});
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: constraints.maxWidth,
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                color: (Theme.of(context).textTheme.bodyText1?.color ??
                        Colors.black)
                    .withOpacity(.05),
                child: Text(
                  "导出路径 (点击可修改):\n"
                  "$_exportPath",
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
        ...Platform.isAndroid
            ? [
                Container(height: 15),
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  color: (Theme.of(context).textTheme.bodyText1?.color ??
                          Colors.black)
                      .withOpacity(.01),
                  child: const Text(
                    "您正在使用安卓设备:\n如果不能成功导出并且提示权限不足, 可以尝试在Download或Document下建立子目录进行导出",
                  ),
                ),
              ]
            : [],
      ]);
    },
  );
}
