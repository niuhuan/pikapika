import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:pikapika/basic/Entities.dart';
import 'package:pikapika/screens/components/ContentLoading.dart';
import 'package:pikapika/basic/Method.dart';

import 'components/ComicInfoCard.dart';
import 'components/ListView.dart';
import 'components/RightClickPop.dart';

// 确认下载
class DownloadConfirmScreen extends StatefulWidget {
  final ComicInfo comicInfo;
  final List<Ep> epList;

  const DownloadConfirmScreen({
    Key? key,
    required this.comicInfo,
    required this.epList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadConfirmScreenState();
}

class _DownloadConfirmScreenState extends State<DownloadConfirmScreen> {
  DownloadComic? _task; // 之前的下载任务
  final List<int> _taskedEps = []; // 已经下载的EP
  final List<int> _selectedEps = []; // 选中的EP
  late Future f = _load();

  Future<dynamic> _load() async {
    _taskedEps.clear();
    _task = await method.loadDownloadComic(widget.comicInfo.id);
    if (_task != null) {
      var epList = await method.downloadEpList(widget.comicInfo.id);
      _taskedEps.addAll(epList.map((e) => e.epOrder));
    }
  }

  void _selectAll() {
    setState(() {
      _selectedEps.clear();
      for (var element in widget.epList) {
        if (!_taskedEps.contains(element.order)) {
          _selectedEps.add(element.order);
        }
      }
    });
  }

  Future<dynamic> _download() async {
    // 必须选中才能下载
    if (_selectedEps.isEmpty) {
      defaultToast(context, "请选择下载的EP");
      return;
    }
    // 下载对象
    Map<String, dynamic> create = {
      "id": widget.comicInfo.id,
      "createdAt": widget.comicInfo.createdAt,
      "updatedAt": widget.comicInfo.updatedAt,
      "title": widget.comicInfo.title,
      "author": widget.comicInfo.author,
      "pagesCount": widget.comicInfo.pagesCount,
      "epsCount": widget.comicInfo.epsCount,
      "finished": widget.comicInfo.finished,
      "categories": json.encode(widget.comicInfo.categories),
      "thumbOriginalName": widget.comicInfo.thumb.originalName,
      "thumbFileServer": widget.comicInfo.thumb.fileServer,
      "thumbPath": widget.comicInfo.thumb.path,
      "description": widget.comicInfo.description,
      "chineseTeam": widget.comicInfo.chineseTeam,
      "tags": json.encode(widget.comicInfo.tags),
    };
    // 下载EP列表
    List<Map<String, dynamic>> list = [];
    for (var element in widget.epList) {
      if (_selectedEps.contains(element.order)) {
        list.add({
          "comicId": widget.comicInfo.id,
          "id": element.id,
          "updatedAt": element.updatedAt,
          "epOrder": element.order,
          "title": element.title,
        });
      }
    }
    try {
      // 如果之前下载过就将EP加入下载
      // 如果之前没有下载过就创建下载
      if (_task != null) {
        await method.addDownload(create, list);
      } else {
        await method.createDownload(create, list);
      }
      // 退出
      defaultToast(context, "已经加入下载列表");
      Navigator.pop(context);
    } catch (e, s) {
      defaultToast(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return rightClickPop(
      child: buildScreen(context),
      context: context,
      canPop: true,
    );
  }

  Widget buildScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载 - ${widget.comicInfo.title}"),
      ),
      body: FutureBuilder(
        future: f,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            print(snapshot.stackTrace);
            return const Text('error');
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const ContentLoading(label: '加载中');
          }
          return PikaListView(
            children: [
              ComicInfoCard(widget.comicInfo),
              _buildButtons(),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                runSpacing: 10,
                spacing: 10,
                children: [
                  ...widget.epList.map((e) {
                    return Container(
                      padding: const EdgeInsets.all(5),
                      child: MaterialButton(
                        onPressed: () {
                          _clickOfEp(e);
                        },
                        color: _colorOfEp(e),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _iconOfEp(e),
                            Container(
                              width: 10,
                            ),
                            Text(e.title,
                                style: const TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButtons() {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.spaceAround,
        children: [
          MaterialButton(
            color: theme.colorScheme.secondary,
            textColor: Colors.white,
            onPressed: _selectAll,
            child: const Text('全选'),
          ),
          MaterialButton(
            color: theme.colorScheme.secondary,
            textColor: Colors.white,
            onPressed: _download,
            child: const Text('确定下载'),
          ),
        ],
      ),
    );
  }

  Color _colorOfEp(Ep e) {
    if (_taskedEps.contains(e.order)) {
      return Colors.grey.shade300;
    }
    if (_selectedEps.contains(e.order)) {
      return Colors.blueGrey.shade300;
    }
    return Colors.grey.shade200;
  }

  Icon _iconOfEp(Ep e) {
    if (_taskedEps.contains(e.order)) {
      return const Icon(Icons.download_rounded, color: Colors.black);
    }
    if (_selectedEps.contains(e.order)) {
      return const Icon(Icons.check_box, color: Colors.black);
    }
    return const Icon(Icons.check_box_outline_blank, color: Colors.black);
  }

  void _clickOfEp(Ep e) {
    if (_taskedEps.contains(e.order)) {
      return;
    }
    if (_selectedEps.contains(e.order)) {
      setState(() {
        _selectedEps.remove(e.order);
      });
    } else {
      setState(() {
        _selectedEps.add(e.order);
      });
    }
  }
}
