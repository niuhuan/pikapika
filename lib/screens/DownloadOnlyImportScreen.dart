import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pikapika/basic/Common.dart';

import '../basic/Channels.dart';
import '../basic/Method.dart';
import 'components/ContentLoading.dart';

class DownloadOnlyImportScreen extends StatefulWidget {
  final bool holdPkz;
  final String path;

  const DownloadOnlyImportScreen({
    Key? key,
    required this.path,
    this.holdPkz = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadOnlyImportScreenState();
}

class _DownloadOnlyImportScreenState extends State<DownloadOnlyImportScreen> {
  bool importing = false;
  bool imported = false;
  bool importFail = false;
  dynamic e;
  String importMessage = "正在导入";
  StreamSubscription<String?>? _linkSubscription;

  @override
  void initState() {
    if (widget.holdPkz) {
      _linkSubscription = linkSubscript(context);
    }
    registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(event) {
    setState(() {
      importMessage = event;
    });
  }

  Widget _body() {
    if (importing) {
      return ContentLoading(label: importMessage);
    }
    if (importFail) {
      return Center(child: Text("导入失败\n$e"));
    }
    if (imported) {
      return const Center(child: Text("导入成功"));
    }
    return Center(
      child: MaterialButton(
        onPressed: _import,
        child: Text("点击导入文件\n${p.basename(widget.path)}"),
      ),
    );
  }

  _import() async {
    try {
      setState(() {
        importing = true;
      });
      if (widget.path.endsWith(".zip")) {
        await method.importComicDownload(widget.path);
      } else if (widget.path.endsWith(".pki")) {
        await method.importComicDownloadPki(widget.path);
      }
      imported = true;
    } catch (err) {
      e = err;
      importFail = true;
    } finally {
      setState(() {
        importing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("导入"),
        ),
        body: _body(),
      ),
      onWillPop: () async {
        if (importing) {
          defaultToast(context, "导入中, 请稍后");
          return false;
        }
        return true;
      },
    );
  }
}
