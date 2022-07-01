import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';

import '../basic/Channels.dart';
import '../basic/Cross.dart';
import '../basic/Method.dart';
import '../basic/config/ExportRename.dart';
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
      return Center(child: Text("导出成功"));
    }
    return Center(
      child: MaterialButton(
        onPressed: _export,
        child: const Text("选择导出位置"),
      ),
    );
  }

  _export() async {
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
