import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';

import '../basic/Channels.dart';
import '../basic/Cross.dart';
import '../basic/Method.dart';
import '../basic/config/ExportRename.dart';
import '../basic/config/IsPro.dart';
import 'components/ContentLoading.dart';

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
    return ListView(
      children: [
        Container(height: 20),
        MaterialButton(
          onPressed: _exportPkz,
          child: const Text("导出PKZ"),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportPkis,
          child: Text("分别导出PKI" + (!isPro ? "\n(发电后使用)" : "")),
        ),
        Container(height: 20),
        MaterialButton(
          onPressed: _exportZips,
          child: Text("分别导出ZIP" + (!isPro ? "\n(发电后使用)" : "")),
        ),
        Container(height: 20),
      ],
    );
  }

  _exportPkz() async {
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
        defaultValue: "${DateTime.now().millisecondsSinceEpoch}",
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
          widget.idList,
          path,
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
  }

  _exportPkis() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    late String? path;
    try {
      path = await chooseFolder(context);
    } catch (e) {
      defaultToast(context, "$e");
      return;
    }
    print("path $path");
    if (path != null) {
      try {
        setState(() {
          exporting = true;
        });
        await method.exportAnyComicDownloadsToPki(
          widget.idList,
          path,
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
  }

  _exportZips() async {
    if (!isPro) {
      defaultToast(context, "请先发电鸭");
      return;
    }
    late String? path;
    try {
      path = await chooseFolder(context);
    } catch (e) {
      defaultToast(context, "$e");
      return;
    }
    print("path $path");
    if (path != null) {
      try {
        setState(() {
          exporting = true;
        });
        await method.exportAnyComicDownloadsToZip(
          widget.idList,
          path,
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
}
