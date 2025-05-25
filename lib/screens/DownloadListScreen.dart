import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'components/flutter_search_bar.dart' as fsb;
import 'package:pikapika/basic/Channels.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/DownloadExportGroupScreen.dart';
import '../basic/config/IconLoading.dart';
import 'DownloadImportScreen.dart';
import 'DownloadInfoScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

// 下载列表
class DownloadListScreen extends StatefulWidget {
  const DownloadListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  String _search = "";
  bool _selecting = false;
  List<String> _selectingList = [];
  String _filterCustomFolder = "";
  List<String> _folderList = [];

  late final fsb.SearchBar _searchBar = fsb.SearchBar(
    hintText: '搜索下载',
    inBar: false,
    setState: setState,
    onSubmitted: (value) {
      _search = value;
      _reloadList();
      setState(() {});
      _searchBar.controller.text = value;
    },
    buildDefaultAppBar: (BuildContext context) {
      if (_selecting) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if (_selecting) {
                setState(() {
                  _selecting = false;
                  _selectingList = [];
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text("多选操作"),
          actions: [
            _selectingCancelButton(),
            _selectingMoveButton(),
            _selectingDeleteButton(),
          ],
        );
      }
      return AppBar(
        title: Text(_search == "" ? "下载列表" : ('搜索下载 - $_search')),
        actions: [
          //_searchBar.getSearchAction(context),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _searchBar.beginSearch(context);
            },
            child: Column(
              children: [
                Expanded(child: Container()),
                const Icon(
                  Icons.search,
                  size: 18,
                  color: Colors.white,
                ),
                const Text(
                  '搜索',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          _customFolderButton(),
          _toSelectingButton(),
          _fileButton(),
          Container(width: 10),
          pauseButton(),
        ],
      );
    },
  );

  DownloadComic? _downloading;
  late bool _downloadRunning = false;
  late Future<List<DownloadComic>> _f = method
      .allDownloads(_search, customFolder: _filterCustomFolder)
      .then((value) {
    setState(() {
      _selecting = false;
      _selectingList = [];
    });
    return value;
  });

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
    method.allCustomFolders().then((value) {
      setState(() {
        _folderList = value.where((e) => e.isNotEmpty).toList();
      });
    });
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

          if (_selecting) {
            return ListView(
              children: [
                ...data.map(selectingWidget),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _reloadList();
              setState(() {});
            },
            child: PikaListView(
              children: [
                ...data.map(downloadWidget),
              ],
            ),
          );
        },
      ),
    );
    var w = rightClickPop(
      child: screen,
      context: context,
      canPop: true,
    );
    return WillPopScope(
      onWillPop: () async {
        if (_selecting) {
          setState(() {
            _selecting = false;
            _selectingList = [];
          });
          return false;
        }
        return true;
      },
      child: w,
    );
  }

  Widget _customFolderButton() {
    return IconButton(
        onPressed: () async {
          String? choose = await chooseListDialog(context, "选择文件夹", [
            "全部",
            ..._folderList,
          ]);
          if (choose != null) {
            if (choose == "全部") {
              choose = "";
            }
            _filterCustomFolder = choose;
            _reloadList();
            setState(() {});
          }
        },
        icon: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.folder,
              size: 18,
              color: Colors.white,
            ),
            Text(
              _customFolderName(),
              style: const TextStyle(fontSize: 14, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  String _customFolderName() {
    if (_filterCustomFolder == "") {
      return "全部";
    }
    return _filterCustomFolder;
  }

  Widget downloadWidget(DownloadComic e) {
    return InkWell(
      onTap: () {
        if (e.deleting) {
          return;
        }
        Navigator.push(
          context,
          mixRoute(
            builder: (context) => DownloadInfoScreen(
              comicId: e.id,
              comicTitle: e.title,
            ),
          ),
        );
      },
      // onLongPress: () async {
      //   String? action = await chooseListDialog(context, e.title, ['删除']);
      //   if (action == '删除') {
      //     await method.deleteDownloadComic(e.id);
      //     setState(() => e.deleting = true);
      //   }
      // },
      child: DownloadInfoCard(
        task: e,
        downloading: _downloading != null && _downloading!.id == e.id,
      ),
    );
  }

  Widget selectingWidget(DownloadComic e) {
    return InkWell(
      onTap: () {
        if (e.deleting) {
          defaultToast(context, "该下载已经在删除队列中");
          return;
        } else {
          if (_selectingList.contains(e.id)) {
            setState(() {
              _selectingList.remove(e.id);
            });
          } else {
            setState(() {
              _selectingList.add(e.id);
            });
          }
        }
      },
      child: Stack(
        children: [
          DownloadInfoCard(
            task: e,
            downloading: _downloading != null && _downloading!.id == e.id,
          ),
          Icon(
            _selectingList.contains(e.id)
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _fileButton() {
    return PopupMenuButton<int>(
      itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
        const PopupMenuItem<int>(
          value: 0,
          child: ListTile(
            leading: Icon(Icons.read_more),
            title: Text("导入"),
          ),
        ),
        const PopupMenuItem<int>(
          value: 1,
          child: ListTile(
            leading: Icon(Icons.save_alt),
            title: Text("导出"),
          ),
        ),
      ],
      onSelected: (a) async {
        if (a == 0) {
          await Navigator.push(
            context,
            mixRoute(
              builder: (context) => const DownloadImportScreen(),
            ),
          );
          _reloadList();
          setState(() {});
        } else if (a == 1) {
          await Navigator.push(
            context,
            mixRoute(
              builder: (context) => const DownloadExportGroupScreen(),
            ),
          );
        }
      },
      child: Column(
        children: [
          Expanded(child: Container()),
          const Icon(
            Icons.drive_file_move,
            size: 18,
            color: Colors.white,
          ),
          const Text(
            '文件',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }

  Future<void> _onPauseChangeClick() async {
    await showDialog(
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
  }

  Widget pauseButton() {
    return PopupMenuButton<int>(
        itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: const Icon(Icons.compare_arrows_sharp),
                  title: Text(_downloadRunning ? "暂停下载" : "继续下载"),
                ),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.sync_problem),
                  title: Text("恢复失败"),
                ),
              ),
            ],
        onSelected: (a) async {
          if (a == 0) {
            await _onPauseChangeClick();
          } else if (a == 1) {
            await method.resetFailed();
            _reloadList();
            setState(() {});
            defaultToast(context, "所有失败的下载已经恢复");
          }
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

  void _reloadList() {
    _f = method
        .allDownloads(_search, customFolder: _filterCustomFolder)
        .then((value) {
      setState(() {
        _selecting = false;
        _selectingList = [];
      });
      return value;
    });
    method.allCustomFolders().then((value) {
      setState(() {
        _folderList = value.where((e) => e.isNotEmpty).toList();
      });
    });
  }

  Widget _selectingCancelButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _selecting = false;
          _selectingList = [];
        });
      },
      icon: const Icon(Icons.cancel),
    );
  }

  Widget _selectingMoveButton() {
    return IconButton(
      onPressed: () async {
        var tmp = _selectingList;
        _selecting = false;
        _selectingList = [];
        setState(() {});
        if (tmp.isEmpty) {
          defaultToast(context, "请选择要移动下载");
        } else {
          var moveToChoose = await chooseListDialog(
            context,
            "移动下载",
            ["全部", ..._folderList, "==> 输入名称 <=="],
            tips: "（空文件夹将会自动删除，下次需要手动输入）",
          );
          if (moveToChoose == null) {
            return;
          }
          if (moveToChoose == "==> 输入名称 <==") {
            String? name = await displayTextInputDialog(context,
                title: "文件夹名称", hint: "请输入文件夹名称");
            if (name != null) {
              if ("全部" != name && "==> 输入名称 <==" != name) {
                await method.moveDownloadComic(tmp, name);
                _reloadList();
                setState(() {});
              }
            }
          } else if (moveToChoose == "全部") {
            await method.moveDownloadComic(tmp, "");
            _reloadList();
            setState(() {});
          } else {
            await method.moveDownloadComic(tmp, moveToChoose);
            _reloadList();
            setState(() {});
          }
        }
      },
      icon: const Icon(Icons.move_down),
    );
  }

  Widget _selectingDeleteButton() {
    return IconButton(
      onPressed: () async {
        var tmp = _selectingList;
        _selecting = false;
        _selectingList = [];
        setState(() {});
        if (tmp.isEmpty) {
          defaultToast(context, "请选择要删除的下载");
        } else {
          if (await confirmDialog(context, "删除下载", "删除选中的下载吗?")) {
            for (var id in tmp) {
              await method.deleteDownloadComic(id);
            }
            _reloadList();
            setState(() {});
          }
        }
      },
      icon: const Icon(Icons.delete),
    );
  }

  Widget _toSelectingButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _selecting = true;
          _selectingList = [];
        });
      },
      icon: Column(
        children: [
          Expanded(child: Container()),
          const Icon(
            Icons.rule,
            size: 18,
            color: Colors.white,
          ),
          const Text(
            '多选',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
