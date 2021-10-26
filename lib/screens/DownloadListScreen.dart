import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Method.dart';
import 'DownloadImportScreen.dart';
import 'DownloadInfoScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

// 下载列表
class DownloadListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  DownloadComic? _downloading;
  late bool _downloadRunning = false;
  late Future<List<DownloadComic>> _f = method.allDownloads();

  void _onMessageChange(String event) {
    print("EVENT");
    print(event);
    if (event is String) {
      try {
        setState(() {
          _downloading = DownloadComic.fromJson(json.decode(event));
        });
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  }

  @override
  void initState() {
    registerEvent(_onMessageChange, "DOWNLOAD");
    method
        .downloadRunning()
        .then((val) => setState(() => _downloadRunning = val));
    super.initState();
  }

  @override
  void dispose() {
    unregisterEvent(_onMessageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载列表'),
        actions: [
          importButton(),
          pauseButton(),
          resetFailedButton(),
        ],
      ),
      body: FutureBuilder(
        future: _f,
        builder: (BuildContext context,
            AsyncSnapshot<List<DownloadComic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }

          if (snapshot.hasError) {
            print("${snapshot.error}");
            print("${snapshot.stackTrace}");
            return Center(child: Text('加载失败'));
          }

          var data = snapshot.data!;
          if (_downloading != null) {
            try {
              for (var i = 0; i < data.length; i++) {
                if (_downloading!.id == data[i].id) {
                  data[i].copy(_downloading!);
                }
              }
            } catch (e, s) {
              print(e);
              print(s);
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _f = method.allDownloads();
              });
            },
            child: ListView(
              children: [
                ...data.map(downloadWidget),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget downloadWidget(DownloadComic e) {
    return InkWell(
      onTap: () {
        if (e.deleting) {
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DownloadInfoScreen(
              comicId: e.id,
              comicTitle: e.title,
            ),
          ),
        );
      },
      onLongPress: () async {
        String? action = await chooseListDialog(context, e.title, ['删除']);
        if (action == '删除') {
          await method.deleteDownloadComic(e.id);
          setState(() => e.deleting = true);
        }
      },
      child: DownloadInfoCard(
        task: e,
        downloading: _downloading != null && _downloading!.id == e.id,
      ),
    );
  }

  Widget importButton() {
    return MaterialButton(
        minWidth: 0,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DownloadImportScreen(),
            ),
          );
          setState(() {
            _f = method.allDownloads();
          });
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            Icon(
              Icons.label_important,
              size: 18,
              color: Colors.white,
            ),
            Text(
              '导入',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget pauseButton() {
    return MaterialButton(
        minWidth: 0,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('下载任务'),
                content: Text(
                  _downloadRunning ? "暂停下载吗?" : "启动下载吗?",
                ),
                actions: [
                  MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text('取消'),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      var to = !_downloadRunning;
                      await method.setDownloadRunning(to);
                      setState(() {
                        _downloadRunning = to;
                      });
                    },
                    child: Text('确认'),
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            Icon(
              _downloadRunning
                  ? Icons.compare_arrows_sharp
                  : Icons.schedule_send,
              size: 18,
              color: Colors.white,
            ),
            Text(
              _downloadRunning ? '下载中' : '暂停中',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget resetFailedButton() {
    return MaterialButton(
        minWidth: 0,
        onPressed: () async {
          await method.resetFailed();
          setState(() {
            _f = method.allDownloads();
          });
          defaultToast(context, "所有失败的下载已经恢复");
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            Icon(
              Icons.sync_problem,
              size: 18,
              color: Colors.white,
            ),
            Text(
              '恢复',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }
}
