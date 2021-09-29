import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';

import 'components/ContentError.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

class DownloadExportToSocketScreen extends StatefulWidget {
  final DownloadComic task;
  final String comicId;
  final String comicTitle;

  DownloadExportToSocketScreen({
    required this.task,
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<StatefulWidget> createState() => _DownloadExportToSocketScreenState();
}

class _DownloadExportToSocketScreenState
    extends State<DownloadExportToSocketScreen> {
  late Future<int> _future = method.exportComicUsingSocket(widget.comicId);
  late Future<String> _ipFuture = method.clientIpSet();

  late String exportMessage = "";

  @override
  void initState() {
    registerEvent(_onMessageChange, "EXPORT");
    super.initState();
  }

  @override
  void dispose() {
    method.exportComicUsingSocketExit();
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  void _onMessageChange(event) {
    if (event is String) {
      setState(() {
        exportMessage = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("网络导出 - " + widget.comicTitle),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) {
            return ContentError(
                error: snapshot.error,
                stackTrace: snapshot.stackTrace,
                onRefresh: () async {
                  setState(() {
                    _future = method.exportComicUsingSocket(widget.comicId);
                  });
                });
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }
          return ListView(
            children: [
              DownloadInfoCard(task: widget.task),
              Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                        'TIPS : 传输成功之前请不要退出页面, 一次只能导出到一个设备, 两台设备需要在同一网段或无限局域网中, 请另外一台设备输入 IP:端口 , 有一个IP时请选择无限局域网的IP, 通常是192.168开头'),
                    FutureBuilder(
                      future: _ipFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasError) {
                          return Text('获取IP失败');
                        }
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Text('正在获取IP');
                        }
                        return Text('${snapshot.data}');
                      },
                    ),
                    Text('端口号:${snapshot.data}'),
                    Text('$exportMessage'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
