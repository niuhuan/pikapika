import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Method.dart';
import 'package:pikapika/screens/components/ComicInfoCard.dart';
import 'package:pikapika/screens/components/RightClickPop.dart';

import '../basic/Entities.dart';
import '../basic/config/IconLoading.dart';
import 'ComicInfoScreen.dart';
import 'components/Images.dart';
import 'components/ListView.dart';

// 浏览记录
class ViewLogsScreen extends StatefulWidget {
  const ViewLogsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewLogsScreenState();
}

class _ViewLogsScreenState extends State<ViewLogsScreen> {
  static const _pageSize = 24;
  static const _scrollPhysics = AlwaysScrollableScrollPhysics(); // 即使不足一页仍可滚动

  final _scrollController = ScrollController();
  final _comicList = <ViewLog>[];

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
        _comicList.addAll(page);
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
    var entries = _comicList.map((e) {
      return InkWell(
        onTap: () {
          _chooseComic(e.id);
        },
        onLongPress: () {
          _clearOnce(e.id);
        },
        child: ViewInfoCard(
          fileServer: e.thumbFileServer,
          author: e.author,
          categories: _decodeCate(e.categories),
          path: e.thumbPath,
          title: e.title,
        ),
      );
    });

    final screen = NotificationListener(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('浏览记录'),
          actions: [
            IconButton(
                onPressed: _clearAll, icon: const Icon(Icons.auto_delete)),
          ],
        ),
        body: PikaListView(
          physics: _scrollPhysics,
          controller: _scrollController,
          children: entries.toList(),
        ),
      ),
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollStartNotification) {
          _handScroll();
        }
        return true;
      },
    );
    return rightClickPop(
      child: screen,
      context: context,
      canPop: true,
    );
  }

  void _chooseComic(String comicId) {
    Navigator.push(
      context,
      mixRoute(
        builder: (context) => ComicInfoScreen(
          comicId: comicId,
        ),
      ),
    );
  }

  List<String> _decodeCate(String categories) {
    try {
      var decode = jsonDecode(categories);
      if (decode is List) {
        return List.of(decode).cast();
      }
      return [decode];
    } catch (e) {
      return [categories];
    }
  }
}

class ViewInfoCard extends StatelessWidget {
  final String fileServer;
  final String path;
  final String title;
  final String author;
  final List<String> categories;

  const ViewInfoCard({
    Key? key,
    required this.fileServer,
    required this.path,
    required this.title,
    required this.author,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10),
            child: RemoteImage(
              key: Key("$fileServer:$path"),
              fileServer: fileServer,
              path: path,
              width: imageWidth,
              height: imageHeight,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle),
                      Container(height: 5),
                      Text(author, style: authorStyle),
                      Container(height: 5),
                      Text.rich(
                        TextSpan(text: "分类 : ${categories.join(' ')}"),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withAlpha(0xCC),
                        ),
                      ),
                      Container(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
