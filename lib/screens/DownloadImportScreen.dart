import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ChooserRoot.dart';

import '../basic/Cross.dart';
import '../basic/config/IconLoading.dart';
import '../basic/config/ImportNotice.dart';
import '../basic/config/IsPro.dart';
import 'PkzArchiveScreen.dart';
import 'components/ContentLoading.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

// 导入
class DownloadImportScreen extends StatefulWidget {
  const DownloadImportScreen({Key? key}) : super(key: key);

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
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: !_importing,
    );
  }

  Widget buildScreen(BuildContext context) {
    if (_importing) {
      return Scaffold(
        body: ContentLoading(label: _importMessage),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('导入'),
      ),
      body: PikaListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(_importMessage),
          ),
          Container(height: 20),
          importNotice(context),
          Container(height: 20),
          _fileImportButton(),
          Container(height: 20),
          _networkImportButton(),
          Container(height: 20),
          _importDirFilesZipButton(),
          Container(height: 40),
        ],
      ),
    );
  }

  Widget _fileImportButton() {
    return MaterialButton(
      height: 80,
      onPressed: () async {
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
            allowedExtensions: ['.pkz', '.zip', '.pki'],
            fileTileSelectMode: FileTileSelectMode.wholeTile,
          );
        } else {
          var ls = await FilePicker.platform.pickFiles(
            dialogTitle: '选择要导入的文件',
            allowMultiple: false,
            initialDirectory: chooseRoot,
            type: FileType.custom,
            allowedExtensions: ['pkz', 'zip', 'pki'],
            allowCompression: false,
          );
          path = ls != null && ls.count > 0 ? ls.paths[0] : null;
        }
        if (path != null) {
          if (path.endsWith(".pkz")) {
            Navigator.of(context).push(
              mixRoute(
                builder: (BuildContext context) =>
                    PkzArchiveScreen(pkzPath: path!),
              ),
            );
          } else if (path.endsWith(".zip") || path.endsWith(".pki")) {
            try {
              setState(() {
                _importing = true;
              });
              if (path.endsWith(".zip")) {
                await method.importComicDownload(path);
              } else if (path.endsWith(".pki")) {
                await method.importComicDownloadPki(path);
              }
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
        }
      },
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            color:
                (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                    .withOpacity(.05),
            child: const Text(
              '选择zip文件进行导入\n选择pki文件进行导入\n选择pkz文件进行阅读',
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _networkImportButton() {
    return MaterialButton(
      height: 80,
      onPressed: () async {
        var path =
            await inputString(context, '请输入导出设备提供的地址\n例如 "192.168.1.2:50000"');
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            color:
                (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                    .withOpacity(.05),
            child: const Text(
              '从其他设备导入',
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _importDirFilesZipButton() {
    return MaterialButton(
      height: 80,
      onPressed: () async {
        late String? path;
        try {
          path = await chooseFolder(context);
        } catch (e) {
          defaultToast(context, "$e");
          return;
        }
        if (path != null) {
          try {
            setState(() {
              _importing = true;
            });
            await method.importComicDownloadDir(path);
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            color:
                (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
                    .withOpacity(.05),
            child: Text(
              '选择文件夹\n(导入里面所有的zip/pki)' + (!isPro ? "\n(发电后使用)" : ""),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
