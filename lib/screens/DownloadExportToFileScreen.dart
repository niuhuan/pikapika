import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/basic/config/ExportRename.dart';
import 'package:pikapika/screens/DownloadExportToSocketScreen.dart';
import '../basic/config/ExportPath.dart';
import '../basic/config/IconLoading.dart';
import '../basic/config/IsPro.dart';
import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';
import 'components/ListView.dart';
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
          return PikaListView(
            children: [
              DownloadInfoCard(task: _task),
              Container(
                padding: const EdgeInsets.all(8),
                child: exportResult != "" ? Text(exportResult) : Container(),
              ),
              displayExportPathInfo(),
              Container(height: 15),
              _exportPkzButton(),
              Container(height: 10),
              _exportPkiButton(),
              Container(height: 10),
              _exportHtmlZipButton(),
              Container(height: 10),
              _exportToHtmlJPEGButton(),
              Container(height: 10),
              _exportToHtmlPdfButton(),
              Container(height: 10),
              _exportToJPEGSZIPButton(),
              Container(height: 10),
              _exportToHtmlJPEGNotDownOverButton(),
              Container(height: 10),
              _exportComicDownloadToCbzsZipButton(),
              Container(height: 10),
              MaterialButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    mixRoute(
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
              Container(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _exportPkzButton() {
    return MaterialButton(
      onPressed: () async {
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出PKZ${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadToPkz(
            [widget.comicId],
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出到xxx.pkz\n(可直接打开观看的格式,不支持导入)\n(可以躲避网盘或者聊天软件的扫描)',
      ),
    );
  }

  Widget _exportPkiButton() {
    return MaterialButton(
      onPressed: () async {
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出PKI${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadToPki(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出到xxx.pki\n(只支持导入, 不支持直接阅读)\n(可以躲避网盘或者聊天软件的扫描)\n(后期版本可能支持直接阅读)',
      ),
    );
  }

  Widget _exportHtmlZipButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出HTML+ZIP${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownload(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出到HTML.zip\n(可从其他设备导入 / 解压后可阅读)' + (!isPro ? "\n(发电后使用)" : ""),
      ),
    );
  }

  Widget _exportToHtmlJPEGButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出HTML+JPEG${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadToJPG(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner('导出到HTML+JPG\n(可直接在相册中打开观看)'),
    );
  }

  Widget _exportToHtmlPdfButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出PDF${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadToPDF(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner('导出到PDF\n(可直接在相册中打开观看)'),
    );
  }

  Widget _exportToJPEGSZIPButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出JPEGS.zip${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadJpegZip(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出阅读器用JPGS.zip\n(不可再导入)' + (!isPro ? "\n(发电后使用)" : ""),
      ),
    );
  }

  Widget _exportToHtmlJPEGNotDownOverButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(context, "导出确认",
              "将您所选的漫画导出HTML+JPEGS(即使没有下载完成)${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicJpegsEvenNotFinish(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出到HTML+JPG\n(即使没有下载成功)' + (!isPro ? "\n(发电后使用)" : ""),
      ),
    );
  }

  Widget _exportComicDownloadToCbzsZipButton() {
    return MaterialButton(
      onPressed: () async {
        if (!isPro) {
          defaultToast(context, "请先发电鸭");
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
        } else {
          if (!await confirmDialog(
              context, "导出确认", "将您所选的漫画导出cbk.zip${showExportPath()}")) {
            return;
          }
        }
        try {
          setState(() {
            exporting = true;
          });
          await method.exportComicDownloadToCbzsZip(
            widget.comicId,
            await attachExportPath(),
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
      },
      child: _buildButtonInner(
        '导出阅读器用cbk.zip\n(暂时不能导入)' + (!isPro ? "\n(发电后使用)" : ""),
      ),
    );
  }

  Widget _buildButtonInner(String text) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(15),
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
