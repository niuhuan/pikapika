import 'dart:async';
import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:pikapi/basic/config/ChooserRoot.dart';

import 'components/ContentLoading.dart';

// 导入
class DownloadImportScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadImportScreenState();
}

class _DownloadImportScreenState extends State<DownloadImportScreen> {
  bool _importing = false;
  String _importMessage = "";

  @override
  void initState() {
    registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(event) {
    if (event is String) {
      setState(() {
        _importMessage = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_importing) {
      return Scaffold(
        body: ContentLoading(label: _importMessage),
      );
    }

    List<Widget> actions = [];

    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isAndroid) {
      actions.add(_fileImportButton());
    }

    actions.add(_networkImportButton());

    return Scaffold(
      appBar: AppBar(
        title: Text('导入'),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(_importMessage),
          ),
          ...actions,
        ],
      ),
    );
  }

  Widget _fileImportButton() {
    return MaterialButton(
      height: 80,
      onPressed: () async {
        String? path = await FilesystemPicker.open(
          title: '选择要导入的文件',
          context: context,
          rootDirectory: Directory(currentChooserRoot()),
          fsType: FilesystemType.file,
          folderIconColor: Colors.teal,
          allowedExtensions: ['.zip'],
          fileTileSelectMode: FileTileSelectMode.wholeTile,
        );
        if (path != null) {
          try {
            setState(() {
              _importing = true;
            });
            await method.importComicDownload(path);
            setState(() {
              _importMessage = "导入成功";
            });
          } catch (e) {
            setState(() {
              _importMessage = "导入失败 $e";
            });
          } finally {
            setState(() {
              _importing = false;
            });
          }
        }
      },
      child: Text('选择zip文件进行导入'),
    );
  }

  Widget _networkImportButton() {
    return MaterialButton(
      height: 80,
      onPressed: () async {
        var path = await inputString(context, '请输入导出设备提供的地址\n例如 "192.168.1.2:50000"');
        if (path != null) {
          try {
            setState(() {
              _importing = true;
            });
            await method.importComicDownloadUsingSocket(path);
            setState(() {
              _importMessage = "导入成功";
            });
          } catch (e) {
            setState(() {
              _importMessage = "导入失败 $e";
            });
          } finally {
            setState(() {
              _importing = false;
            });
          }
        }
      },
      child: Text('从其他设备导入'),
    );
  }
}
