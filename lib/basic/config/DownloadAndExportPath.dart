/// 下载的同时导出到文件系统

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';

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
          title: Text(tr("settings.download_and_export_path.title")),
          subtitle: Text(_downloadAndExportPath),
          onTap: () async {
            if (_downloadAndExportPath == "") {
              bool b = await confirmDialog(
                context,
                tr("settings.download_and_export_path.confirm"),
                tr("settings.download_and_export_path.desc"),
              );
              if (b) {
                late String? folder;
                try {
                  folder = await chooseFolder(context);
                } catch (e) {
                  defaultToast(context, "$e");
                  return;
                }
                if (folder != null) {
                  await method.saveDownloadAndExportPath(folder);
                  _downloadAndExportPath = folder;
                  setState(() {});
                }
              }
            } else {
              bool b = await confirmDialog(
                context,
                tr("settings.download_and_export_path.confirm"),
                tr("settings.download_and_export_path.desc"),
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
