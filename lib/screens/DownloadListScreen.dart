import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/DownloadExportGroupScreen.dart';
import 'DownloadImportScreen.dart';
import 'DownloadInfoScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';
import 'components/RightClickPop.dart';

// 下载列表
class DownloadListScreen extends StatefulWidget {
  const DownloadListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  String _search = "";
  late final SearchBar _searchBar = SearchBar(
    hintText: '搜索下载',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        _search = value;
        _f = method.allDownloads(_search);
        _searchBar.controller.text = value;
      }
    },
    buildDefaultAppBar: (BuildContext context) {
      return AppBar(
        title: Text(_search == "" ? "下载列表" : ('搜索下载 - $_search')),
        actions: [
          _searchBar.getSearchAction(context),
          exportButton(),
          importButton(),
          resetFailedButton(),
          pauseButton(),
        ],
      );
    },
  );

  DownloadComic? _downloading;
  late bool _downloadRunning = false;
  late Future<List<DownloadComic>> _f = method.allDownloads(_search);

  void _onMessageChange(String event) {
    print("EVENT");
    print(event);
    try {
      setState(() {
        _downloading = DownloadComic.fromJson(json.decode(event));
      });
    } catch (e, s) {
      print(e);
      print(s);
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
    final screen = Scaffold(
      appBar: _searchBar.build(context),
      body: FutureBuilder(
        future: _f,
        builder: (BuildContext context,
            AsyncSnapshot<List<DownloadComic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const ContentLoading(label: '加载中');
          }

          if (snapshot.hasError) {
            print("${snapshot.error}");
            print("${snapshot.stackTrace}");
            return const Center(child: Text('加载失败'));
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
                _f = method.allDownloads(_search);
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
    return rightClickPop(
      child: screen,
      context: context,
      canPop: true,
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

  Widget exportButton() {
    return IconButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DownloadExportGroupScreen(),
            ),
          );
        },
        icon: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.send_to_mobile,
              size: 18,
              color: Colors.white,
            ),
            const Text(
              '导出',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget importButton() {
    return IconButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DownloadImportScreen(),
            ),
          );
          setState(() {
            _f = method.allDownloads(_search);
          });
        },
        icon: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.label_important,
              size: 18,
              color: Colors.white,
            ),
            const Text(
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
                title: const Text('下载任务'),
                content: Text(
                  _downloadRunning ? "暂停下载吗?" : "启动下载吗?",
                ),
                actions: [
                  MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
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
                    child: const Text('确认'),
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
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget resetFailedButton() {
    return IconButton(
        onPressed: () async {
          await method.resetFailed();
          setState(() {
            _f = method.allDownloads(_search);
          });
          defaultToast(context, "所有失败的下载已经恢复");
        },
        icon: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.sync_problem,
              size: 18,
              color: Colors.white,
            ),
            const Text(
              '恢复',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }
}
