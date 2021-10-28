import 'package:flutter/material.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Method.dart';

import 'ComicInfoScreen.dart';
import 'components/Images.dart';

// 浏览记录
class ViewLogsScreen extends StatefulWidget {
  const ViewLogsScreen();

  @override
  State<StatefulWidget> createState() => _ViewLogsScreenState();
}

class _ViewLogsScreenState extends State<ViewLogsScreen> {
  static const _pageSize = 24;
  static const _scrollPhysics = AlwaysScrollableScrollPhysics(); // 即使不足一页仍可滚动

  final _scrollController = ScrollController();
  final _comicList = <ViewLogWrapEntity>[];

  var _isLoading = false; // 是否加载中
  var _scrollOvered = false; // 滚动到最后
  var _offset = 0;

  Future _clearAll() async {
    if (await confirmDialog(
      context,
      "您要清除所有浏览记录吗? ",
      "将会同时删除浏览进度!",
    )) {
      await method.clearAllViewLog();
      setState(() {
        _comicList.clear();
        _isLoading = false;
        _scrollOvered = true;
        _offset = 0;
      });
    }
  }

  Future _clearOnce(String id) async {
    if (await confirmDialog(
      context,
      "您要清除这条浏览记录吗? ",
      "将会同时删除浏览进度!",
    )) {
      await method.deleteViewLog(id);
      setState(() {
        for (var i = 0; i < _comicList.length; i++) {
          if (_comicList[i].id == id) {
            _comicList.removeAt(i);
            _offset--;
            break;
          }
        }
      });
    }
  }

  // 加载一页
  Future<dynamic> _loadPage() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var page = await method.viewLogPage(_offset, _pageSize);
      if (page.isEmpty) {
        _scrollOvered = true;
      } else {
        _comicList.addAll(page.map((e) =>
            ViewLogWrapEntity(e.id, e.title, e.thumbFileServer, e.thumbPath)));
      }
      _offset += _pageSize;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 滚动事件
  void _handScroll() {
    if (_scrollController.position.pixels +
            MediaQuery.of(context).size.height / 2 <
        _scrollController.position.maxScrollExtent) {
      return;
    }
    if (_isLoading || _scrollOvered) return;
    _loadPage();
  }

  @override
  void initState() {
    _loadPage();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: Scaffold(
        appBar: AppBar(
          title: Text('浏览记录'),
          actions: [
            IconButton(onPressed: _clearAll, icon: Icon(Icons.auto_delete)),
          ],
        ),
        body: ListView(
          physics: _scrollPhysics,
          controller: _scrollController,
          children: [
            Container(height: 10),
            ViewLogWrap(
              onTapComic: _chooseComic,
              comics: _comicList,
              onDelete: _clearOnce,
            ),
          ],
        ),
      ),
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          _handScroll();
        }
        return true;
      },
    );
  }

  void _chooseComic(String comicId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicInfoScreen(
          comicId: comicId,
        ),
      ),
    );
  }
}

class ViewLogWrap extends StatelessWidget {
  final Function(String) onTapComic;
  final List<ViewLogWrapEntity> comics;
  final Function(String id) onDelete;

  const ViewLogWrap({
    Key? key,
    required this.onTapComic,
    required this.comics,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var min = size.width < size.height ? size.width : size.height;
    var width = (min - 45) / 4;

    var entries = comics.map((e) {
      return InkWell(
        key: e.key,
        onTap: () {
          onTapComic(e.id);
        },
        onLongPress: () {
          onDelete(e.id);
        },
        child: Card(
          child: Container(
            width: width,
            child: Column(
              children: [
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return RemoteImage(
                      width: constraints.maxWidth,
                      fileServer: e.fileServer,
                      path: e.path);
                }),
                Text(
                  e.title + '\n',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(height: 1.4),
                  strutStyle: StrutStyle(height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    });

    Map<int, List<Widget>> map = Map();
    for (var i = 0; i < entries.length; i++) {
      late List<Widget> list;
      if (i % 4 == 0) {
        list = [];
        map[i ~/ 4] = list;
      } else {
        list = map[i ~/ 4]!;
      }
      list.add(entries.elementAt(i));
    }

    return Column(
      children: map.values.map((e) => Wrap(
            alignment: WrapAlignment.spaceAround,
            children: e,
          )).toList(),
    );
  }
}

class ViewLogWrapEntity {
  final Key key = UniqueKey();
  final String id;
  final String title;
  final String fileServer;
  final String path;

  ViewLogWrapEntity(this.id, this.title, this.fileServer, this.path);
}
