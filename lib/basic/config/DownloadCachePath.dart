/// 下载的同时导出到文件系统

import 'dart:convert';
import 'dart:io';

import 'package:pikapika/i18.dart';
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
          title: Text(tr("settings.download_cache_path.title")),
          subtitle: Text(_downloadCachePath),
          onTap: () async {
            if (_downloadCachePath == "") {
              bool b = await confirmDialog(
                context,
                tr("settings.download_cache_path.confirm"),
                tr("settings.download_cache_path.desc") + "\n\n${String.fromCharCodes(base64Decode("L0FuZHJvaWQvZGF0YS9jb20ucGljYWNvbWljLmZyZWdhdGEvZmlsZXMv"))}",
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
                tr("settings.download_cache_path.confirm"),
                tr("settings.download_cache_path.cancel_desc"),
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
          title: Text(tr("settings.download_cache_path.import_view_log_from_off.title")),
          subtitle: Text(_downloadCachePath),
          onTap: () async {
            bool b = await confirmDialog(
              context,
              tr("settings.download_cache_path.import_view_log_from_off.title"),
              tr('settings.download_cache_path.import_view_log_from_off.desc')+ "\n\n${String.fromCharCodes(base64Decode("L2RhdGEvZGF0YS9jb20ucGljYWNvbWljLmdyZWdhdGEvZGF0YWJhc2VzL2NvbV9waWNhY29taWNfZnJlZ2F0YS5kYg=="))}",
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
                  dialogTitle: tr("settings.download_cache_path.import_view_log_from_off.choose_file_dialog_title"),
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
