import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Cross.dart';

import '../Method.dart';

late String _downloadAndExportPath;

Future initDownloadAndExportPath() async {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    _downloadAndExportPath = await method.loadDownloadAndExportPath();
  }
}

Widget downloadAndExportPathSetting() {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: Text("下载的同时导出到文件系统"),
          subtitle: Text(_downloadAndExportPath),
          onTap: () async {
            if (_downloadAndExportPath == "") {
              bool b = await confirmDialog(
                context,
                "下载的同时导出到文件系统",
                "您即将选择一个目录, 如果文件系统可写, 下载的同时会为您自动导出一份",
              );
              if (b) {
                String? folder = await chooseFolder(context);
                if (folder != null) {
                  await method.saveDownloadAndExportPath(folder);
                  _downloadAndExportPath = folder;
                  setState(() {});
                }
              }
            } else {
              bool b = await confirmDialog(
                context,
                "下载的同时导出到文件系统",
                "您确定取消下载并导出的功能吗? 取消之后您可以再次点击设置",
              );
              if (b) {
                var folder = "";
                await method.saveDownloadAndExportPath(folder);
                _downloadAndExportPath = folder;
                setState(() {});
              }
            }
          },
        );
      },
    );
  }
  return Container();
}
