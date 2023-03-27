/// 下载的同时导出到文件系统

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';

import '../../screens/ImportFromOffScreen.dart';
import '../Method.dart';
import 'ChooserRoot.dart';
import 'IconLoading.dart';

late String _downloadCachePath;

Future initDownloadCachePath() async {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    _downloadCachePath = await method.loadDownloadCachePath();
  }
}

Widget downloadCachePathSetting() {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("使用其他程序的缓存下载加速"),
          subtitle: Text(_downloadCachePath),
          onTap: () async {
            if (_downloadCachePath == "") {
              bool b = await confirmDialog(
                context,
                "使用其他程序的缓存下载加速",
                "您即将选择一个目录, 这个目录拷贝自以下目录才能使用。下载时将会作为缓存文件夹优先读取。 \n\n${String.fromCharCodes(base64Decode("L0FuZHJvaWQvZGF0YS9jb20ucGljYWNvbWljLmZyZWdhdGEvZmlsZXMv"))}",
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
                  await method.saveDownloadCachePath(folder);
                  _downloadCachePath = folder;
                  setState(() {});
                }
              }
            } else {
              bool b = await confirmDialog(
                context,
                "使用其他软件的下载内容加速",
                "您确定取消使用其他软件的下载内容加速的功能吗? 取消之后您可以再次点击设置",
              );
              if (b) {
                var folder = "";
                await method.saveDownloadCachePath(folder);
                _downloadCachePath = folder;
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

Widget importViewLogFromOff() {
  if (Platform.isWindows ||
      Platform.isMacOS ||
      Platform.isAndroid ||
      Platform.isLinux) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return ListTile(
          title: const Text("导入其他程序的历史记录"),
          subtitle: Text(_downloadCachePath),
          onTap: () async {
            bool b = await confirmDialog(
              context,
              "导入其他程序的历史记录",
              "您即将选择一个文件, 这个文件拷贝自以下路径才能使用。 \n\n${String.fromCharCodes(base64Decode("L2RhdGEvZGF0YS9jb20ucGljYWNvbWljLmdyZWdhdGEvZGF0YWJhc2VzL2NvbV9waWNhY29taWNfZnJlZ2F0YS5kYg=="))}",
            );
            if (b) {
              late String chooseRoot;
              try {
                chooseRoot = await currentChooserRoot();
              } catch (e) {
                defaultToast(context, "$e");
                return;
              }
              String? path;
              if (Platform.isAndroid) {
                path = await FilesystemPicker.open(
                  title: 'Open file',
                  context: context,
                  rootDirectory: Directory(chooseRoot),
                  fsType: FilesystemType.file,
                  folderIconColor: Colors.teal,
                  allowedExtensions: ['.db'],
                  fileTileSelectMode: FileTileSelectMode.wholeTile,
                );
              } else {
                var ls = await FilePicker.platform.pickFiles(
                  dialogTitle: '选择要导入的文件',
                  allowMultiple: false,
                  initialDirectory: chooseRoot,
                  type: FileType.custom,
                  allowedExtensions: ['db'],
                  allowCompression: false,
                );
                path = ls != null && ls.count > 0 ? ls.paths[0] : null;
              }
              if (path != null) {
                if (path.endsWith(".db")) {
                  Navigator.of(context).push(
                    mixRoute(
                      builder: (BuildContext context) =>
                          ImportFromOffScreen(dbPath: path!),
                    ),
                  );
                }
              }
            }
          },
        );
      },
    );
  }
  return Container();
}
