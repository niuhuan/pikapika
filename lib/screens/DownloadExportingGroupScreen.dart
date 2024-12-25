import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import '../basic/Channels.dart';
import '../basic/Method.dart';
import '../basic/config/ExportPath.dart';
import '../basic/config/ExportRename.dart';
import '../basic/config/IsPro.dart';
import 'components/ContentLoading.dart';
import 'components/ListView.dart';

class DownloadExportingGroupScreen extends StatefulWidget {
  final List<String> idList;

  const DownloadExportingGroupScreen({Key? key, required this.idList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadExportingGroupScreenState();
}

class _DownloadExportingGroupScreenState
    extends State<DownloadExportingGroupScreen> {
  bool exporting = false;
  bool exported = false;
  bool exportFail = false;
  dynamic e;
  String exportMessage = "正在导出";

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

  Widget _body() {
    if (exporting) {
      return ContentLoading(label: exportMessage);
    }
    if (exportFail) {
      return Center(child: Text("导出失败\n$e"));
    }
    if (exported) {
      return const Center(child: Text("导出成功"));
    }
    return PikaListView(
      children: [
        Container(height: 20),
        displayExportPathInfo(),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportPkz,
          child: _buildButtonInner("导出成一个PKZ\n(加密模式,防止网盘检测,能用pikapika打开观看)"),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportPkis,
          child: _buildButtonInner("每部漫画都打包一个PKI\n(加密模式,防止网盘检测,能用pikapika导入)"),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportZips,
          child: _buildButtonInner(
              "每部漫画都打包一个ZIP\n(不加密模式,能用pikapika导入或网页浏览器观看)" +
                  (!isPro ? "\n(发电后使用)" : "")),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportToJPEGSZips,
          child: _buildButtonInner(
            "每部漫画都打包一个ZIP+JPEG\n(能直接使用其他阅读器看,不可再导入)" +
                (!isPro ? "\n(发电后使用)" : ""),
          ),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportToJPEGSFolders,
          child: _buildButtonInner(
            "每部漫画都导出成文件夹+JPEG" + (!isPro ? "\n(发电后使用)" : ""),
          ),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportToPdf,
          child: _buildButtonInner(
            "每部漫画都导出成PDF" + (!isPro ? "\n(发电后使用)" : ""),
          ),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportComicDownloadToCbzsZip,
          child: _buildButtonInner(
            "每部漫画都导出成cbz.zip" + (!isPro ? "\n(发电后使用)" : ""),
          ),
        ),
        Container(height: 20),
      ],
    );
  }

  _exportPkz() async {
    var name = "";
    if (currentExportRename()) {
      var rename = await inputString(
        context,
        "请输入保存后的名称",
        defaultValue: "${DateTime.now().millisecondsSinceEpoch}",
      );
      if (rename != null && rename.isNotEmpty) {
        name = rename;
      } else {
        return;
      }
    } else {
      if (!await confirmDialog(
          context, "导出确认", "将导出您所选的漫画为一个PKZ${showExportPath()}")) {
        return;
      }
    }
    try {
      setState(() {
        exporting = true;
      });
      await method.exportComicDownloadToPkz(
        widget.idList,
        await attachExportPath(),
        name,
      );
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportPkis() async {
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出成单独的PKI${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      await method.exportAnyComicDownloadsToPki(
        widget.idList,
        await attachExportPath(),
      );
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (!await confirmDialog(
        context, "导出确认", "将导出您所选的漫画分别导出ZIP${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      await method.exportAnyComicDownloadsToZip(
        widget.idList,
        await attachExportPath(),
      );
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportToJPEGSZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出ZIP+JPEG${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var id in widget.idList) {
        await method.exportComicDownloadJpegZip(
          id,
          path,
          "",
        );
      }
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportToJPEGSFolders() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出文件夹+JPEG${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var id in widget.idList) {
        await method.exportComicDownloadToJPG(
          id,
          path,
          "",
        );
      }
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportToPdf() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出PDF${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var id in widget.idList) {
        await method.exportComicDownloadToPDF(
          id,
          path,
          "",
        );
      }
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  _exportComicDownloadToCbzsZip() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    if (!await confirmDialog(
        context, "导出确认", "将您所选的漫画分别导出cbz.zip${showExportPath()}")) {
      return;
    }
    try {
      setState(() {
        exporting = true;
      });
      final path = await attachExportPath();
      for (var id in widget.idList) {
        await method.exportComicDownloadToCbzsZip(
          id,
          path,
          "",
        );
      }
      exported = true;
    } catch (err) {
      e = err;
      exportFail = true;
    } finally {
      setState(() {
        exporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("批量导出"),
        ),
        body: _body(),
      ),
      onWillPop: () async {
        if (exporting) {
          defaultToast(context, "导出中, 请稍后");
          return false;
        }
        return true;
      },
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
