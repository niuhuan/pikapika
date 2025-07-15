import 'dart:io';

import 'package:pikapika/i18.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Common.dart';
import '../Method.dart';
import 'ChooserRoot.dart';

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

List<Widget> localHistorySyncTiles() => [
      localHistorySyncPathTile(),
      localHistorySyncAutoTile(),
      localHistorySyncManualTile(),
    ];

Widget localHistorySyncPathTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onLongPress: () async {
          bool? clean = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(tr("settings.local_history_sync.clear_path")),
                content: Text(tr("settings.local_history_sync.clear_path_desc")),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(tr("app.cancel")),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(tr("app.confirm")),
                  ),
                ],
              );
            },
          );
          if (clean != null && clean == true) {
            await method.saveProperty(_dirPathPropertyName, "");
            setState(() {
              _localHistorySyncRoot = "";
            });
          }
        },
        onTap: () async {
          if (Platform.isAndroid) {
            final pState = await Permission.manageExternalStorage.request();
            if (!pState.isGranted) {
              return;
            }
          }
          var dir = await FilePicker.platform.getDirectoryPath(
            dialogTitle: tr("settings.local_history_sync.choose_dir"),
            initialDirectory:
                Directory.fromUri(Uri.file(await currentChooserRoot()))
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
        title: Text(tr("settings.local_history_sync.sync_to_local")),
        subtitle: Text(_localHistorySyncRoot.isEmpty ? tr("settings.local_history_sync.not_set") : _localHistorySyncRoot),
      );
    },
  );
}

Widget localHistorySyncManualTile() {
  return StatefulBuilder(
    builder: (BuildContext context, void Function(void Function()) setState) {
      return ListTile(
        onTap: () async {
          if (_localHistorySyncRoot.isEmpty) {
            defaultToast(context, tr("settings.local_history_sync.not_set"));
            return;
          }
          try {
            await localSync();
            defaultToast(context, tr("settings.local_history_sync.sync_success"));
          } catch (e, s) {
            print("$e\n$s");
            defaultToast(context, tr("settings.local_history_sync.sync_failed"));
          }
        },
        title: Text(tr("settings.local_history_sync.sync_to_local")),
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
        title: Text(tr("settings.local_history_sync.auto_sync")),
        subtitle: Text(tr("settings.local_history_sync.auto_sync_desc")),
      );
    },
  );
}
