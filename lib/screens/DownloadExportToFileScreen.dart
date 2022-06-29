import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Cross.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ExportRename.dart';
import 'package:pikapika/screens/DownloadExportToSocketScreen.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';
import 'components/RightClickPop.dart';

// 导出
class DownloadExportToFileScreen extends StatefulWidget {
  final String comicId;
  final String comicTitle;

  const DownloadExportToFileScreen({
    required this.comicId,
    required this.comicTitle,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadExportToFileScreenState();
}

class _DownloadExportToFileScreenState
    extends State<DownloadExportToFileScreen> {
  late DownloadComic _task;
  late Future _future = _load();
  late bool exporting = false;
  late String exportMessage = "导出中";
  late String exportResult = "";

  Future _load() async {
    _task = (await method.loadDownloadComic(widget.comicId))!;
  }

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
    setState(() {
      exportMessage = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: !exporting,
    );
  }

  Widget buildScreen(BuildContext context) {
    if (exporting) {
      return Scaffold(
        body: ContentLoading(label: exportMessage),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("导出 - " + widget.comicTitle),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = _load();
                  });
                });
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const ContentLoading(label: '加载中');
          }
          return ListView(
            children: [
              DownloadInfoCard(task: _task),
              Container(
                padding: const EdgeInsets.all(8),
                child: exportResult != "" ? Text(exportResult) : Container(),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: const Text('TIPS : 选择一个目录'),
              ),
              ..._buildExportToFileButtons(),
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DownloadExportToSocketScreen(
                        task: _task,
                        comicId: widget.comicId,
                        comicTitle: widget.comicTitle,
                      ),
                    ),
                  );
                },
                child: _buildButtonInner('传输到其他设备'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildExportToFileButtons() {
    List<Widget> widgets = [];
    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isAndroid) {
      widgets.add(MaterialButton(
        onPressed: () async {
          late String? path;
          try {
            path = await chooseFolder(context);
          } catch (e) {
            defaultToast(context, "$e");
            return;
          }
          var name = "";
          if (currentExportRename()) {
            var rename = await inputString(
              context,
              "请输入保存后的名称",
              defaultValue: _task.title,
            );
            if (rename != null && rename.isNotEmpty) {
              name = rename;
            } else {
              return;
            }
          }
          print("path $path");
          if (path != null) {
            try {
              setState(() {
                exporting = true;
              });
              await method.exportComicDownloadToJPG(
                widget.comicId,
                path,
                name,
              );
              setState(() {
                exportResult = "导出成功";
              });
            } catch (e) {
              setState(() {
                exportResult = "导出失败 $e";
              });
            } finally {
              setState(() {
                exporting = false;
              });
            }
          }
        },
        child: _buildButtonInner('导出到HTML+JPG\n(可直接在相册中打开观看)'),
      ));
      widgets.add(Container(height: 10));
      /////////////////////
      widgets.add(MaterialButton(
        onPressed: () async {
          late String? path;
          try {
            path = await chooseFolder(context);
          } catch (e) {
            defaultToast(context, "$e");
            return;
          }
          var name = "";
          if (currentExportRename()) {
            var rename = await inputString(
              context,
              "请输入保存后的名称",
              defaultValue: _task.title,
            );
            if (rename != null && rename.isNotEmpty) {
              name = rename;
            } else {
              return;
            }
          }
          print("path $path");
          if (path != null) {
            try {
              setState(() {
                exporting = true;
              });
              await method.exportComicDownloadToPkz(
                [widget.comicId],
                path,
                name,
              );
              setState(() {
                exportResult = "导出成功";
              });
            } catch (e) {
              setState(() {
                exportResult = "导出失败 $e";
              });
            } finally {
              setState(() {
                exporting = false;
              });
            }
          }
        },
        child:
            _buildButtonInner('导出到xxx.pkz\n(可直接打开观看的格式,不支持导入,可以躲避BD网盘或者TX的检测)'),
      ));
      widgets.add(Container(height: 10));
      /////////////////////
      widgets.add(MaterialButton(
        onPressed: () async {
          late String? path;
          try {
            path = await chooseFolder(context);
          } catch (e) {
            defaultToast(context, "$e");
            return;
          }
          var name = "";
          if (currentExportRename()) {
            var rename = await inputString(
              context,
              "请输入保存后的名称",
              defaultValue: _task.title,
            );
            if (rename != null && rename.isNotEmpty) {
              name = rename;
            } else {
              return;
            }
          }
          print("path $path");
          if (path != null) {
            try {
              setState(() {
                exporting = true;
              });
              await method.exportComicDownload(
                widget.comicId,
                path,
                name,
              );
              setState(() {
                exportResult = "导出成功";
              });
            } catch (e) {
              setState(() {
                exportResult = "导出失败 $e";
              });
            } finally {
              setState(() {
                exporting = false;
              });
            }
          }
        },
        child: _buildButtonInner('导出到HTML.zip\n(可从其他设备导入 / 解压后可阅读)'),
      ));
      widgets.add(Container(height: 10));
    }
    if (Platform.isIOS || Platform.isAndroid) {
      widgets.add(MaterialButton(
        onPressed: () async {
          if (!(await confirmDialog(context, "导出确认", "将本漫画所有图片到相册？"))) {
            return;
          }
          if (!(await Permission.storage.request()).isGranted) {
            return;
          }
          try {
            setState(() {
              exporting = true;
            });
            // 导出所有图片数据
            var count = 0;
            List<DownloadEp> eps = await method.downloadEpList(widget.comicId);
            for (var i = 0; i < eps.length; i++) {
              var pics = await method.downloadPicturesByEpId(eps[i].id);
              for (var j = 0; j < pics.length; j++) {
                setState(() {
                  exportMessage = "导出图片 ${count++} 张";
                });
                await saveImageQuiet(
                  await method.downloadImagePath(pics[j].localPath),
                  context,
                );
              }
            }
            setState(() {
              exportResult = "导出成功";
            });
          } catch (e) {
            setState(() {
              exportResult = "导出失败 $e";
            });
          } finally {
            setState(() {
              exporting = false;
            });
          }
        },
        child: _buildButtonInner('将所有图片导出到手机相册'),
      ));
      widgets.add(Container(height: 10));
    }
    return widgets;
  }

  Widget _buildButtonInner(String text) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          color: (Theme.of(context).textTheme.bodyText1?.color ?? Colors.black)
              .withOpacity(.05),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
