import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Common.dart';
import '../Method.dart';
import 'ChooserRoot.dart';
import 'IsPro.dart';

const _dirPathPropertyName = "localHistorySyncRoot";
const _autoSavePropertyName = "localHistorySyncAuto";

late String _localHistorySyncRoot;
late bool _localHistorySyncAuto;

Future initLocalHistorySync() async {
  _localHistorySyncRoot = await method.loadProperty(
    _dirPathPropertyName,
    "",
  );
  _localHistorySyncAuto = await method.loadProperty(
    _autoSavePropertyName,
    "false",
  ) ==
      "true";
  if (_localHistorySyncAuto) {
    localSync();
  }
}

Future localSync() async {
  if (_localHistorySyncRoot.isEmpty) {
    return;
  }
  return await method.mergeHistoriesFromLocal(join(
    _localHistorySyncRoot,
    "pk.histories",
  ));
}

List<Widget> localHistorySyncTiles() =>
    [
      localHistorySyncPathTile(),
      localHistorySyncManualTile(),
      localHistorySyncAutoTile(),
    ];

Widget localHistorySyncPathTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          if (Platform.isAndroid) {
            final pState = await Permission.manageExternalStorage.request();
            if (!pState.isGranted) {
              return;
            }
          }
          var dir = await FilePicker.platform.getDirectoryPath(
            dialogTitle: "选择一个文件夹, 将历史记录文件保存到这里",
            initialDirectory:
            Directory
                .fromUri(Uri.file(await currentChooserRoot()))
                .absolute
                .path,
          );
          if (dir != null) {
            await method.saveProperty(_dirPathPropertyName, dir);
            setState(() {
              _localHistorySyncRoot = dir;
            });
          }
        },
        title: const Text(
          "同步历史记录到本地路径",
        ),
        subtitle:
        Text(_localHistorySyncRoot.isEmpty ? "未设置" : _localHistorySyncRoot),
      );
    },
  );
}

Widget localHistorySyncManualTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          try {
            await localSync();
            defaultToast(context, "同步成功");
          } catch (e, s) {
            print("$e\n$s");
            defaultToast(context, "没有同步成功\n$e");
          }
        },
        title: const Text(
          "立即同步浏览记录到本地",
        ),
      );
    },
  );
}

Widget localHistorySyncAutoTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return SwitchListTile(
        value: _localHistorySyncAuto,
        onChanged: (bool value) async {
          await method.saveProperty(
            _autoSavePropertyName,
            value ? "true" : "false",
          );
          setState(() {
            _localHistorySyncAuto = value;
          });
          if (value) {
            localSync();
          }
        },
        title: const Text(
          "自动同步历史记录到本地",
        ),
        subtitle: const Text(
          "开启后每次打开应用会自动备份历史记录",
        ),
      );
    },
  );
}
