import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Cross.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import 'package:pikapi/screens/DownloadExportToSocketScreen.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

// 导出
class DownloadExportToFileScreen extends StatefulWidget {
  final String comicId;
  final String comicTitle;

  DownloadExportToFileScreen({
    required this.comicId,
    required this.comicTitle,
  });

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
            return ContentLoading(label: '加载中');
          }
          return ListView(
            children: [
              DownloadInfoCard(task: _task),
              Container(
                padding: EdgeInsets.all(8),
                child: exportResult != "" ? Text(exportResult) : Container(),
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text('TIPS : 选择一个目录'),
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
    if (Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux ||
        Platform.isAndroid) {
      return [
        MaterialButton(
          onPressed: () async {
            String? path = await chooseFolder(context);
            print("path $path");
            if (path != null) {
              try {
                setState(() {
                  exporting = true;
                });
                await method.exportComicDownloadToJPG(
                  widget.comicId,
                  path,
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
        ),
        Container(height: 10),
        MaterialButton(
          onPressed: () async {
            String? path = await chooseFolder(context);
            print("path $path");
            if (path != null) {
              try {
                setState(() {
                  exporting = true;
                });
                await method.exportComicDownload(
                  widget.comicId,
                  path,
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
        ),
        Container(height: 10),
      ];
    }
    return [];
  }

  Widget _buildButtonInner(String text) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: EdgeInsets.only(top: 15, bottom: 15),
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
